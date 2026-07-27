const admin = require('firebase-admin');
const User = require('../models/user.model');

// Initializes lazily and only if all three FIREBASE_* vars are present (see
// backend/.env.example) - every send function below no-ops quietly if not
// configured, so the rest of the app works normally without a Firebase
// project set up. This mirrors the same graceful-degradation pattern used
// for Google Maps (services/maps.service.js).
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
    console.error('[notification.service] Firebase Admin init failed:', err.message);
    initFailed = true;
  }
  return initialized;
}

// Sends to a single user's stored FCM token (User.fcmToken). Silently does
// nothing if Firebase isn't configured, the user has no token, or the send
// fails for any reason - a push notification failure should never break
// the underlying action (order accepted, status updated, etc.) it's
// attached to.
async function sendToUser(userId, { title, body, data = {} }) {
  if (!ensureInitialized()) return;

  try {
    const user = await User.findById(userId).select('fcmToken');
    if (!user?.fcmToken) return;

    await admin.messaging().send({
      token: user.fcmToken,
      notification: { title, body },
      data: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])), // FCM data payload values must be strings
    });
  } catch (err) {
    console.error(`[notification.service] Failed to send to user ${userId}:`, err.message);
  }
}

// Sends to every user matching a role filter (e.g. all approved online
// drivers of a given vehicle type) - used for 'new job available' blasts.
// Best-effort per-recipient: one failed token doesn't stop the others.
async function sendToUsers(userIds, { title, body, data = {} }) {
  if (!ensureInitialized() || userIds.length === 0) return;

  const users = await User.find({ _id: { $in: userIds }, fcmToken: { $exists: true, $ne: null } }).select('fcmToken');
  const tokens = users.map((u) => u.fcmToken);
  if (tokens.length === 0) return;

  try {
    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
    });
  } catch (err) {
    console.error('[notification.service] Multicast send failed:', err.message);
  }
}

module.exports = { sendToUser, sendToUsers, isConfigured: ensureInitialized };
