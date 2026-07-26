const mongoose = require('mongoose');

// Records admin-sent announcements. Actual push delivery via FCM is a
// follow-up (needs Firebase Admin SDK credentials wired in
// services/otp.service.js's sibling notification service) - this stores
// the record and marks it 'queued' so the UI has something real to show.
const notificationSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    body: { type: String, required: true },
    audience: { type: String, enum: ['all', 'customer', 'driver'], default: 'all' },
    sentBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    status: { type: String, enum: ['queued', 'sent', 'failed'], default: 'queued' },
    recipientCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Notification', notificationSchema);
