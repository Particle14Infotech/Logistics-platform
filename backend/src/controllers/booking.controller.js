const { catchAsync, success } = require('../utils/apiResponse');
// TODO: implement using bookingService (price calc, driver allocation trigger, etc.)

exports.estimate = catchAsync(async (req, res) => {
  // body: { pickupLocation, dropLocation, vehicleType, weightKg }
  return success(res, { estimatedPrice: null, distanceKm: null }, 'Not implemented yet', 501);
});

exports.create = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.getById = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.listByUser = catchAsync(async (req, res) => {
  return success(res, [], 'Not implemented yet', 501);
});

exports.cancel = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.track = catchAsync(async (req, res) => {
  return success(res, { location: null }, 'Not implemented yet', 501);
});
