const mongoose = require('mongoose');

const driverSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    fleetId: { type: mongoose.Schema.Types.ObjectId, ref: 'Fleet', default: null }, // null = independent driver, set = fleet-owned vehicle
    // Set when this driver registered with an enterprise's driver invite
    // code (Enterprise.driverInviteCode) - null = drives for the public
    // marketplace. driver.controller.js's availableOrders/acceptOrder
    // partition strictly on this: an enterprise-linked driver only ever
    // sees/accepts that same enterprise's own orders, never the public
    // pool, and vice versa - a dedicated private fleet, not a preference.
    enterpriseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Enterprise', default: null },
    // A category slug from VehicleCategory.vehicleType (e.g. 'flat_bed_20ft')
    // - the specific truck spec this driver actually owns/drives. No longer
    // a fixed enum (the catalog is admin-manageable); validated at the
    // controller layer against active VehicleCategory docs instead of by
    // Mongoose, since the valid set changes at runtime.
    vehicleType: { type: String, required: true },
    vehicleNumber: { type: String, required: true },
    licenseNumber: { type: String, required: true },
    currentLocation: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], default: [0, 0] }, // [lng, lat]
    },
    isAvailable: { type: Boolean, default: false },
    // rating is only meaningful once ratingCount > 0 - see
    // booking.controller.js's submitReview, which is the only writer of
    // both fields (recomputed from real Review documents, never fabricated).
    // A driver with ratingCount 0 has no real feedback yet; display should
    // treat that as "new driver", not show the default 5 as an earned score.
    rating: { type: Number, default: 5, min: 1, max: 5 },
    ratingCount: { type: Number, default: 0 },
    totalTrips: { type: Number, default: 0 },
    totalEarnings: { type: Number, default: 0 },
    // Spendable/payable-out balance - unlike totalEarnings (a lifetime
    // counter that never decreases), this drops on each payout. Kept
    // denormalized here for fast reads; walletTransaction.model.js is the
    // source-of-truth ledger this is derived from.
    walletBalance: { type: Number, default: 0 },
    documents: {
      licenseUrl: String,
      licenseBackUrl: String,
      rcUrl: String,
      rcBackUrl: String,
      aadhaarUrl: String,
      aadhaarBackUrl: String,
      photoUrl: String,
      insuranceUrl: String,
      permitUrl: String,
      pollutionCertUrl: String,
      panCardUrl: String,
      chequeUrl: String,
    },
    bankDetails: {
      accountNumber: String,
      ifsc: String,
      accountHolderName: String,
    },
    isApproved: { type: Boolean, default: false },
  },
  { timestamps: true }
);

driverSchema.index({ currentLocation: '2dsphere' });

module.exports = mongoose.model('Driver', driverSchema);
