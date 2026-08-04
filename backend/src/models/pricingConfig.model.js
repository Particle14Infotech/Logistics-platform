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
    // Admin-editable max load weight for this vehicle type. Unset on older
    // docs (predating this field) - callers fall back to
    // config/vehicleCapacity.js's hardcoded defaults when this is null/undefined.
    maxWeightKg: { type: Number },
    surgeMultiplier: { type: Number, default: 1.0 }, // 1.0 = no surge
    isSurgeActive: { type: Boolean, default: false },
    // Whether this vehicle type carries an upfront advance at booking (both
    // cod and online) - see backend/src/utils/pricingRules.js. advanceValue
    // means % of order price (0-100) when advanceMode is 'percentage', or a
    // flat ₹ amount when 'fixed'.
    advanceRequired: { type: Boolean, default: false },
    advanceMode: { type: String, enum: ['percentage', 'fixed'], default: 'percentage' },
    advanceValue: { type: Number, default: 30 },
    updatedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('PricingConfig', pricingConfigSchema);
