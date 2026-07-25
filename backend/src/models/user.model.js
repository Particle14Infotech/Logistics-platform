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
    passwordHash: { type: String, select: false },
    role: {
      type: String,
      enum: ['customer', 'driver', 'admin', 'enterprise_admin', 'enterprise_user'],
      default: 'customer',
    },
    isVerified: { type: Boolean, default: false },
    isBlocked: { type: Boolean, default: false },
    fcmToken: String,
    savedAddresses: [addressSchema],
    enterpriseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Enterprise', default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);
