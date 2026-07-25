const mongoose = require('mongoose');

// One document per vehicle type. Admin-editable via GET/PUT /admin/pricing.
const pricingConfigSchema = new mongoose.Schema(
  {
    vehicleType: {
      type: String,
      enum: ['bike', 'auto', 'mini_truck', 'medium_truck', 'large_truck'],
      required: true,
      unique: true,
    },
    baseFare: { type: Number, required: true, default: 0 }, // flat starting charge (INR)
    perKmRate: { type: Number, required: true, default: 0 }, // INR per km
    perKgRate: { type: Number, default: 0 }, // optional INR per kg over a free allowance
    surgeMultiplier: { type: Number, default: 1.0 }, // 1.0 = no surge
    isSurgeActive: { type: Boolean, default: false },
    updatedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('PricingConfig', pricingConfigSchema);
