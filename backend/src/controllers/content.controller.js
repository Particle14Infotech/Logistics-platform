const { catchAsync, success } = require('../utils/apiResponse');
const Faq = require('../models/faq.model');
const Banner = require('../models/banner.model');

// GET /api/v1/content/faqs - public, no auth required (Help & Support
// screens in both mobile apps). Admin's listFaqs (admin.controller.js)
// returns everything including inactive ones for management; this only
// ever returns what's actually meant to be shown to end users.
exports.listFaqs = catchAsync(async (req, res) => {
  const faqs = await Faq.find({ isActive: true }).sort({ sortOrder: 1, createdAt: 1 });
  return success(res, { faqs });
});

// GET /api/v1/content/banners - public, no auth required. Same active-only
// pattern as listFaqs above - the admin panel could create/manage banners
// via GET/POST/PUT/DELETE /admin/banners, but until this existed nothing
// downstream ever consumed them.
exports.listBanners = catchAsync(async (req, res) => {
  const banners = await Banner.find({ isActive: true }).sort({ sortOrder: 1, createdAt: -1 });
  return success(res, { banners });
});
