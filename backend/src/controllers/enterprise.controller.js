const { catchAsync, success } = require('../utils/apiResponse');
// TODO: implement enterprise account, bulk booking (CSV), invoicing logic

exports.createAccount = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.dashboard = catchAsync(async (req, res) => {
  return success(res, {}, 'Not implemented yet', 501);
});

exports.bulkBooking = catchAsync(async (req, res) => {
  return success(res, { created: 0, failed: 0 }, 'Not implemented yet', 501);
});

exports.inviteUser = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});

exports.listInvoices = catchAsync(async (req, res) => {
  return success(res, [], 'Not implemented yet', 501);
});

exports.downloadInvoicePdf = catchAsync(async (req, res) => {
  return success(res, null, 'Not implemented yet', 501);
});
