const { catchAsync, success } = require('../utils/apiResponse');
// TODO: implement admin CRUD + analytics aggregation pipelines

exports.listOrders = catchAsync(async (req, res) => {
  return success(res, [], 'Not implemented yet', 501);
});

exports.assignDriver = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.listDrivers = catchAsync(async (req, res) => {
  return success(res, [], 'Not implemented yet', 501);
});

exports.updateDriverStatus = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.analytics = catchAsync(async (req, res) => {
  return success(res, {}, 'Not implemented yet', 501);
});

exports.updatePricing = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});
