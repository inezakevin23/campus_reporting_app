const fs = require("node:fs");
const path = require("node:path");

const {
  before,
  after,
  beforeEach,
  test,
} = require("node:test");

const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");

const {
  doc,
  setDoc,
  updateDoc,
  getDoc,
  writeBatch,
  serverTimestamp,
} = require("firebase/firestore");

let testEnv;

// INITIALIZE FIRESTORE EMULATOR
before(async () => {

  testEnv = await initializeTestEnvironment({

    projectId: "demo-campus-alert",

    firestore: {
      host: "127.0.0.1",
      port: 8080,

      rules: fs.readFileSync(
        path.join(__dirname, "../firestore.rules"),
        "utf8"
      ),
    },
  });
});


after(async () => {

  await testEnv.cleanup();

});


beforeEach(async () => {

  await testEnv.clearFirestore();

});

// CREATE TEST USERS AND INCIDENT
async function seedData() {

  await testEnv.withSecurityRulesDisabled(async (context) => {

    const db = context.firestore();

    await setDoc(doc(db, "users/student-1"), {
      fullName: "Test Student",
      email: "student@alueducation.com",
      role: "student",
      createdAt: new Date(),
    });

    await setDoc(doc(db, "users/staff-1"), {
      fullName: "Test Staff",
      email: "staff@alueducation.com",
      role: "staff",
      createdAt: new Date(),
    });

    await setDoc(doc(db, "incidents/incident-1"), {

      title: "Water shortage",

      description: "No water supply in Block A.",

      category: "water",

      location: "Block A",

      priority: "high",

      status: "submitted",

      reporterId: "student-1",

      imagePath: null,

      createdAt: new Date(),

      updatedAt: new Date(),

      lastStatusUpdateId: "initial-history",

    });

  });
}

// TEST 1: UNVERIFIED USER CANNOT READ INCIDENTS
test("Unverified ALU user cannot access incidents", async () => {

  await seedData();

  const db = testEnv
    .authenticatedContext("student-1", {
      email: "student@alueducation.com",
      email_verified: false,
    })
    .firestore();

  await assertFails(
    getDoc(doc(db, "incidents/incident-1"))
  );
});

// TEST 2: STUDENT CANNOT UPDATE STATUS
test("Verified student cannot update incident status", async () => {

  await seedData();

  const db = testEnv
    .authenticatedContext("student-1", {
      email: "student@aluestudent.com",
      email_verified: true,
    })
    .firestore();

  await assertFails(
    updateDoc(
      doc(db, "incidents/incident-1"),
      {
        status: "in_progress",
        updatedAt: serverTimestamp(),
      }
    )
  );

});

// TEST 3: STAFF CAN UPDATE WITH MATCHING HISTORY
test("Verified staff can update incident with history", async () => {

  await seedData();

  const db = testEnv
    .authenticatedContext("staff-1", {
      email: "staff@alueducation.com",
      email_verified: true,
    })
    .firestore();

  const incidentRef = doc(
    db,
    "incidents/incident-1"
  );

  const historyRef = doc(
    db,
    "incidents/incident-1/statusHistory/history-2"
  );

  const batch = writeBatch(db);

  batch.update(incidentRef, {

    status: "in_progress",

    updatedAt: serverTimestamp(),

    lastStatusUpdateId: "history-2",

  });

  batch.set(historyRef, {

    status: "in_progress",

    note: "Maintenance team has been notified.",

    changedByUid: "staff-1",

    createdAt: serverTimestamp(),

  });

  await assertSucceeds(batch.commit());

});

// TEST 4: STUDENT CANNOT PROMOTE THEMSELVES
test("Student cannot change their role to staff", async () => {

  await seedData();

  const db = testEnv
    .authenticatedContext("student-1", {
      email: "student@aluestudent.com",
      email_verified: true,
    })
    .firestore();

  await assertFails(
    updateDoc(
      doc(db, "users/student-1"),
      {
        role: "staff",
      }
    )
  );

});