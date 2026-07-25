const mongoose = require('mongoose');

const driverSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    vehicleType: {
      type: String,
      enum: ['bike', 'auto', 'mini_truck', 'medium_truck', 'large_truck'],
      required: true,
    },
    vehicleNumber: { type: String, required: true },
    licenseNumber: { type: String, required: true },
    currentLocation: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], default: [0, 0] }, // [lng, lat]
    },
    isAvailable: { type: Boolean, default: false },
    rating: { type: Number, default: 5, min: 1, max: 5 },
    totalTrips: { type: Number, default: 0 },
    totalEarnings: { type: Number, default: 0 },
    documents: {
      licenseUrl: String,
      rcUrl: String,
      aadhaarUrl: String,
      photoUrl: String,
      insuranceUrl: String,
      permitUrl: String,
      pollutionCertUrl: String,
      panCardUrl: String,
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
