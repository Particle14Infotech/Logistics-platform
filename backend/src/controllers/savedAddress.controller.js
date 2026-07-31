const { catchAsync, success, AppError } = require('../utils/apiResponse');
const SavedAddress = require('../models/savedAddress.model');

// GET /api/v1/saved-addresses
exports.list = catchAsync(async (req, res) => {
  const addresses = await SavedAddress.find({ userId: req.user.id }).sort({ createdAt: -1 });
  return success(res, { addresses });
});

// POST /api/v1/saved-addresses  { label, address, lat?, lng? }
exports.create = catchAsync(async (req, res) => {
  const { label, address, lat, lng } = req.body;
  if (!label || !address) throw new AppError('label and address are required', 400);

  const saved = await SavedAddress.create({ userId: req.user.id, label, address, lat, lng });
  return success(res, { address: saved }, 'Address saved', 201);
});

// PUT /api/v1/saved-addresses/:id  { label?, address?, lat?, lng? }
exports.update = catchAsync(async (req, res) => {
  const { label, address, lat, lng } = req.body;
  const saved = await SavedAddress.findOneAndUpdate(
    { _id: req.params.id, userId: req.user.id },
    { label, address, lat, lng },
    { new: true }
  );
  if (!saved) throw new AppError('Address not found', 404);
  return success(res, { address: saved }, 'Address updated');
});

// DELETE /api/v1/saved-addresses/:id
exports.remove = catchAsync(async (req, res) => {
  const deleted = await SavedAddress.findOneAndDelete({ _id: req.params.id, userId: req.user.id });
  if (!deleted) throw new AppError('Address not found', 404);
  return success(res, null, 'Address removed');
});
