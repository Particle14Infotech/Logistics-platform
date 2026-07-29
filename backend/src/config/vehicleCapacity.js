// Single source of truth for max load weight per vehicle type - used by
// booking.controller.js (customer bookings) and enterprise.controller.js
// (bulk booking). Mirrored on the
// customer app's lib/core/constants/vehicle_types.dart for instant
// client-side feedback before this server-side check ever runs.
const VEHICLE_MAX_WEIGHT_KG = {
  bike: 20,
  auto: 250,
  mini_truck: 750,
  medium_truck: 2500,
  large_truck: 10000,
};

module.exports = { VEHICLE_MAX_WEIGHT_KG };
