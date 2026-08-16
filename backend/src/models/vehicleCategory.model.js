const mongoose = require('mongoose');

// Supersedes pricingConfig.model.js's rigid 5-value vehicleType enum with an
// admin-manageable catalog: body type (top-level filter, e.g. 'open',
// 'container', 'trailer') -> sub type (the specific truck build, e.g.
// 'flat_bed', 'low_bed') -> a concrete length/tonnage/price combination.
// `vehicleType` is still the field name every other collection (Driver,
// Order) stores and matches on - it's just a stable slug now (e.g.
// 'flat_bed_20ft') instead of one of 5 hardcoded literals, so
// driver.controller.js's exact-match logic (availableOrders/acceptOrder)
// needed zero changes: a driver's registered category IS the specific
// truck spec a customer picked, same as before.
const vehicleCategorySchema = new mongoose.Schema(
  {
    vehicleType: { type: String, required: true, unique: true, trim: true },
    // Top-level filter chip in both apps' category picker.
    bodyType: { type: String, required: true, trim: true },
    // The specific build within that body type - drives which bundled
    // illustration (imageKey) and behavior a category gets.
    subType: { type: String, required: true, trim: true },
    name: { type: String, required: true, trim: true },
    lengthFt: { type: Number },
    maxWeightKg: { type: Number, required: true },
    // Maps to one of the fixed bundled illustrations in both apps'
    // assets/images/vehicles/ - not a free-text/upload field, so every
    // category stays visually consistent. See ../constants/vehicleImageKeys.js
    // for the closed set of valid values.
    imageKey: { type: String, required: true },
    baseFare: { type: Number, required: true, default: 0 },
    perKmRate: { type: Number, required: true, default: 0 },
    perKgRate: { type: Number, default: 0 },
    surgeMultiplier: { type: Number, default: 1.0 },
    isSurgeActive: { type: Boolean, default: false },
    // Whether this category carries an upfront advance at booking (both cod
    // and online) - see backend/src/utils/pricingRules.js. advanceValue
    // means % of order price (0-100) when advanceMode is 'percentage', or a
    // flat ₹ amount when 'fixed'.
    advanceRequired: { type: Boolean, default: false },
    advanceMode: { type: String, enum: ['percentage', 'fixed'], default: 'percentage' },
    advanceValue: { type: Number, default: 30 },
    // Inactive categories stay out of the customer-facing catalog and the
    // driver registration picker, but existing Drivers/Orders already using
    // that slug keep working - deactivating isn't the same as deleting.
    isActive: { type: Boolean, default: true },
    // Display order within a bodyType group in both apps' picker.
    sortOrder: { type: Number, default: 0 },
    updatedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('VehicleCategory', vehicleCategorySchema);
