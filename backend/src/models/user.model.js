const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema(
  {
    label: String, // e.g. "Home", "Warehouse"
    address: String,
    location: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], default: [0, 0] }, // [lng, lat]
    },
  },
  { _id: false }
);

const userSchema = new mongoose.Schema(
  {
    name: { type: String, trim: true },
    phone: { type: String, unique: true, sparse: true, index: true },
    email: { type: String, unique: true, sparse: true, lowercase: true, trim: true },
    dob: Date,
    passwordHash: { type: String, select: false },
    firebaseUid: { type: String, unique: true, sparse: true, index: true },
    role: {
      type: String,
      enum: ['customer', 'driver', 'fleet_owner', 'admin', 'enterprise_admin', 'enterprise_user'],
      default: 'customer',
    },
    // Only meaningful for role 'enterprise_user' - 'manager' can do
    // everything an enterprise_user route allows (bulk booking, invoices);
    // 'viewer' is read-only (invoices/tracking only, no bulk booking) - see
    // web-portal-enterprise/src/App.jsx's route gating.
    enterpriseRole: { type: String, enum: ['manager', 'viewer'], default: 'manager' },
    isVerified: { type: Boolean, default: false },
    isBlocked: { type: Boolean, default: false },
    fcmToken: String,
    notificationsEnabled: { type: Boolean, default: true },
    savedAddresses: [addressSchema],
    enterpriseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Enterprise', default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);
