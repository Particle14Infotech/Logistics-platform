const UserNotification = require('../models/userNotification.model');
const { catchAsync, success, AppError } = require('../utils/apiResponse');

// GET /api/v1/notifications?page=&limit=
// The signed-in user's personal notification inbox - see
// userNotification.model.js for why this is distinct from the admin
// broadcast-campaign Notification model.
exports.list = catchAsync(async (req, res) => {
  const { page = 1, limit = 20 } = req.query;
  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(50, Math.max(1, parseInt(limit, 10) || 20));

  const [notifications, total, unreadCount] = await Promise.all([
    UserNotification.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum),
    UserNotification.countDocuments({ userId: req.user.id }),
    UserNotification.countDocuments({ userId: req.user.id, isRead: false }),
  ]);

  return success(res, {
    notifications,
    unreadCount,
    pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) },
  });
});

// PUT /api/v1/notifications/:id/read
exports.markRead = catchAsync(async (req, res) => {
  const notification = await UserNotification.findOneAndUpdate(
    { _id: req.params.id, userId: req.user.id },
    { isRead: true },
    { new: true }
  );
  if (!notification) throw new AppError('Notification not found', 404);
  return success(res, { notification });
});

// PUT /api/v1/notifications/read-all
exports.markAllRead = catchAsync(async (req, res) => {
  await UserNotification.updateMany({ userId: req.user.id, isRead: false }, { isRead: true });
  return success(res, {}, 'All notifications marked read');
});
