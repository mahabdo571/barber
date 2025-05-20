// set_user_role.js

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const [, , uid, role] = process.argv;

if (!uid || !role) {
  console.error("Usage: node set_user_role.js <UID> <merchant|customer>");
  process.exit(1);
}

// تعيين الـ custom claim
admin
  .auth()
  .setCustomUserClaims(uid, { role })
  .then(() => {
    console.log(`✅ role="${role}" set for user ${uid}`);
    process.exit(0);
  })
  .catch((err) => {
    console.error("❌ Error:", err);
    process.exit(1);
  });
