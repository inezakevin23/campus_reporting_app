const admin = require("firebase-admin");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function setSupabaseClaim() {
  let nextPageToken;

  do {
    const result = await admin.auth().listUsers(
      1000,
      nextPageToken
    );

    for (const user of result.users) {
      const existingClaims = user.customClaims || {};

      await admin.auth().setCustomUserClaims(
        user.uid,
        {
          ...existingClaims,
          role: "authenticated",
        }
      );

      console.log(`Updated claims for ${user.uid}`);
    }

    nextPageToken = result.pageToken;

  } while (nextPageToken);

  console.log("Finished assigning Supabase claims.");

  await admin.app().delete();
}

setSupabaseClaim().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});