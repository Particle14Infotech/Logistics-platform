const admin = require('firebase-admin');

// Initializes lazily and only if all three FIREBASE_* vars are present (see
// backend/.env.example). Shared by notification.service.js (FCM push) and
// auth.controller.js (Firebase Auth ID token verification) so there's a
// single admin.initializeApp() call instead of each caller racing to init
// its own copy.
let initialized = false;
let initFailed = false;

function ensureInitialized() {
  if (initialized || initFailed) return initialized;

  const { FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY } = process.env;
  if (!FIREBASE_PROJECT_ID || !FIREBASE_CLIENT_EMAIL || !FIREBASE_PRIVATE_KEY) {
    initFailed = true;
    return false;
  }

  try {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: FIREBASE_PROJECT_ID,
        clientEmail: FIREBASE_CLIENT_EMAIL,
        // .env files can't hold real newlines - the private key is stored
        // with literal \n escape sequences and needs converting back.
        privateKey: FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      }),
    });
    initialized = true;
  } catch (err) {
    console.error('[firebaseAdmin] init failed:', err.message);
    initFailed = true;
  }
  return initialized;
}

module.exports = { admin, ensureInitialized };
