const { catchAsync, success } = require('../utils/apiResponse');
const Faq = require('../models/faq.model');

// GET /api/v1/content/faqs - public, no auth required (Help & Support
// screens in both mobile apps). Admin's listFaqs (admin.controller.js)
// returns everything including inactive ones for management; this only
// ever returns what's actually meant to be shown to end users.
exports.listFaqs = catchAsync(async (req, res) => {
  const faqs = await Faq.find({ isActive: true }).sort({ sortOrder: 1, createdAt: 1 });
  return success(res, { faqs });
});
