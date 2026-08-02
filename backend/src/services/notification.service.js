const { admin, ensureInitialized } = require('../config/firebaseAdmin');
const User = require('../models/user.model');
const UserNotification = require('../models/userNotification.model');
const Driver = require('../models/driver.model');

// Every send function below no-ops quietly if Firebase isn't configured, so
// the rest of the app works normally without a Firebase project set up.
// This mirrors the same graceful-degradation pattern used for Google Maps
// (services/maps.service.js).

// Sends to a single user's stored FCM token (User.fcmToken). Silently does
// nothing if Firebase isn't configured, the user has no token, or the send
// fails for any reason - a push notification failure should never break
// the underlying action (order accepted, status updated, etc.) it's
// attached to.
async function sendToUser(userId, { title, body, data = {} }) {
  // Persisted unconditionally - the in-app inbox (UserNotification) is a
  // separate surface from the push itself, and should show something even
  // when the push silently no-ops below (no token, muted, Firebase unset).
  UserNotification.create({ userId, title, body, data }).catch((err) =>
    console.error(`[notification.service] Failed to persist inbox entry for ${userId}:`, err.message)
  );

  if (!ensureInitialized()) return;

  try {
    const user = await User.findById(userId).select('fcmToken notificationsEnabled');
    if (!user?.fcmToken || user.notificationsEnabled === false) return;

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
  if (userIds.length === 0) return;

  UserNotification.insertMany(userIds.map((userId) => ({ userId, title, body, data }))).catch((err) =>
    console.error('[notification.service] Failed to persist inbox entries:', err.message)
  );

  if (!ensureInitialized()) return;

  const users = await User.find({
    _id: { $in: userIds },
    fcmToken: { $exists: true, $ne: null },
    notificationsEnabled: { $ne: false },
  }).select('fcmToken');
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

// Shared "new job available" blast, used both right after a booking is
// created (booking.controller.js) and again once a gated cod order's
// advance gets paid (payment.controller.js) - a gated cod order isn't
// visible to any driver until that advance is paid (see
// driver.controller.js's availableOrders), so drivers need notifying at
// whichever of those two moments is when the order actually becomes visible,
// not always at creation. Must mirror availableOrders' own eligibility
// filter exactly - enterpriseId scoping in particular - so a driver is never
// notified about a job that then doesn't show up in their own Jobs list.
async function notifyEligibleDriversOfNewJob(order) {
  const eligibleDrivers = await Driver.find({
    vehicleType: order.vehicleType,
    isAvailable: true,
    isApproved: true,
    enterpriseId: order.enterpriseId ?? null,
  }).select('userId');
  const userIds = eligibleDrivers.map((d) => d.userId);
  return sendToUsers(userIds, {
    title: 'New job available',
    body: `${order.pickupLocation.address} → ${order.dropLocation.address}`,
    data: { bookingId: String(order._id) },
  });
}

module.exports = { sendToUser, sendToUsers, notifyEligibleDriversOfNewJob, isConfigured: ensureInitialized };
