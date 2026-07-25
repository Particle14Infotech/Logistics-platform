const { catchAsync, success } = require('../utils/apiResponse');
// TODO: implement using Razorpay SDK (see services/payment.service.js)

exports.createOrder = catchAsync(async (req, res) => {
  return success(res, { razorpayOrderId: null }, 'Not implemented yet', 501);
});

exports.verify = catchAsync(async (req, res) => {
  // Verify Razorpay signature via webhook or client callback
  return success(res, null, 'Not implemented yet', 501);
});

exports.refund = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.history = catchAsync(async (req, res) => {
  return success(res, [], 'Not implemented yet', 501);
});
