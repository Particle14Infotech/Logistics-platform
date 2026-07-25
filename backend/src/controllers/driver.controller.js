const { catchAsync, success } = require('../utils/apiResponse');
// TODO: implement using driverService + geospatial queries on Driver.currentLocation

exports.availableOrders = catchAsync(async (req, res) => {
  return success(res, [], 'Not implemented yet', 501);
});

exports.acceptOrder = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.rejectOrder = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.updateStatus = catchAsync(async (req, res) => {
  // body: { isAvailable: boolean }
  return success(res, null, 'Not implemented yet', 501);
});

exports.uploadPod = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.earnings = catchAsync(async (req, res) => {
  return success(res, { total: 0, breakdown: [] }, 'Not implemented yet', 501);
});
