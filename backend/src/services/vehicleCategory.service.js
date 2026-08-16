const { AppError } = require('../utils/apiResponse');
const VehicleCategory = require('../models/vehicleCategory.model');

// Driver.vehicleType is a free string (see driver.model.js's comment), not
// a fixed Mongoose enum - the valid set is the admin-managed VehicleCategory
// catalog, which changes at runtime, so it has to be checked here instead.
// Shared by driver.controller.js (createProfile/updateVehicle) and
// fleet.controller.js (addVehicle) - every path that lets someone
// self-report a vehicleType needs the same guard, or a typo/retired-
// category slug silently saves and only surfaces later as an "orphan"
// type nothing else in the app recognizes (missing from admin filters,
// never matched by availableOrders' exact-vehicleType lookup).
async function assertValidVehicleType(vehicleType) {
  const category = await VehicleCategory.findOne({ vehicleType, isActive: true });
  if (!category) throw new AppError(`"${vehicleType}" is not a valid, active vehicle category`, 400);
}

// Real display name for a vehicleType slug (e.g. 'flat_bed_22ft' -> "Flat
// Bed"), falling back to a de-slugified version of the raw value for
// anything not found (a deleted category, or genuinely bad data) rather
// than throwing - this is for display copy (notifications, PDFs), not
// validation, so it must never be the thing that breaks a request.
// `.replace(/_/g, ' ')` (global), not a single-underscore `.replace()` -
// the old single-replace left literal underscores in multi-word slugs
// like 'flat_bed_22ft' -> "flat bed_22ft".
async function getVehicleCategoryName(vehicleType) {
  const category = await VehicleCategory.findOne({ vehicleType }).select('name');
  return category?.name ?? vehicleType.replace(/_/g, ' ');
}

module.exports = { assertValidVehicleType, getVehicleCategoryName };
