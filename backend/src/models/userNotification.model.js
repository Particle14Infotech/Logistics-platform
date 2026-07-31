const mongoose = require('mongoose');

// Personal, per-recipient notification inbox - one row per user per
// notification actually addressed to them (both individual sends like
// 'your order was picked up' and admin broadcasts from Notification/
// notification.service.js's sendToUsers). Distinct from models/
// notification.model.js, which is one row per admin broadcast *campaign*,
// not per-recipient. Persisted independent of whether the FCM push itself
// reached the device - this is what backs the in-app inbox, which should
// still show something even when push delivery silently no-ops (no
// token, muted, Firebase not configured).
const userNotificationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true },
    body: { type: String, required: true },
    data: { type: mongoose.Schema.Types.Mixed, default: {} },
    isRead: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model('UserNotification', userNotificationSchema);
