const admin = require("firebase-admin");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function setSupabaseClaim() {

  let nextPageToken;

  let updatedCount = 0;

  do {

    const result = await admin.auth().listUsers(
      1000,
      nextPageToken
    );

    nextPageToken = result.pageToken;

    for (const user of result.users) {

      
      const existingClaims = user.customClaims || {};

      await admin.auth().setCustomUserClaims(
        user.uid,
        {
          ...existingClaims,
          role: "authenticated",
        }
      );

      console.log(
        `Enabled Supabase access for: ${user.email}`
      );

      updatedCount++;
    }

  } while (nextPageToken);

  console.log(
    `Successfully updated ${updatedCount} Firebase accounts.`
  );
}

setSupabaseClaim()
  .then(() => {
    return admin.app().delete();
  })
  .catch((error) => {
    console.error("Failed to update claims:", error);
    process.exitCode = 1;
  });