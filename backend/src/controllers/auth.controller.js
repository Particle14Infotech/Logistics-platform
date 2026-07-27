const jwt = require('jsonwebtoken');
const User = require('../models/user.model');
const { success, AppError, catchAsync } = require('../utils/apiResponse');
const otpService = require('../services/otp.service');

const signAccessToken = (user) =>
  jwt.sign({ id: user._id, role: user.role }, process.env.JWT_ACCESS_SECRET, {
    expiresIn: process.env.JWT_ACCESS_EXPIRY || '15m',
  });

const signRefreshToken = (user) =>
  jwt.sign({ id: user._id }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRY || '30d',
  });

// POST /api/v1/auth/send-otp
exports.sendOtp = catchAsync(async (req, res) => {
  const { phone } = req.body;
  if (!phone) throw new AppError('Phone number is required', 400);
  await otpService.sendOtp(phone);
  return success(res, null, 'OTP sent successfully');
});

// POST /api/v1/auth/verify-otp
exports.verifyOtp = catchAsync(async (req, res) => {
  const { phone, otp } = req.body;
  const isValid = await otpService.verifyOtp(phone, otp);
  if (!isValid) throw new AppError('Invalid or expired OTP', 400);

  let user = await User.findOne({ phone });
  let isNewUser = false;
  if (!user) {
    user = await User.create({ phone, role: 'customer', isVerified: true });
    isNewUser = true;
  } else {
    user.isVerified = true;
    await user.save();
  }

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);

  return success(res, { user, accessToken, refreshToken, isNewUser }, 'OTP verified');
});

// POST /api/v1/auth/register  (complete profile after OTP verification)
// Issues fresh tokens reflecting any role change, not just the profile
// update - a role is baked into the JWT payload at sign time (see
// signAccessToken above), so if this only updated the DB and kept handing
// back the original OTP-verify token, every subsequent request would still
// authorize against the stale pre-registration role until that token
// naturally expired. This bit the driver app's new-driver signup flow
// specifically: the OTP-verify step always creates new users as
// role:'customer' by default, and this endpoint is what promotes them to
// 'driver' - without a fresh token, every /driver/* call after signup
// would 403 even though the database was already correct.
exports.register = catchAsync(async (req, res) => {
  const { userId, name, email, role } = req.body;
  const user = await User.findByIdAndUpdate(
    userId,
    { name, email, role: role || 'customer' },
    { new: true }
  );
  if (!user) throw new AppError('User not found', 404);

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);

  return success(res, { user, accessToken, refreshToken }, 'Profile updated');
});

// POST /api/v1/auth/login (email/password - used by Admin/Enterprise)
exports.login = catchAsync(async (req, res) => {
  const bcrypt = require('bcryptjs');
  const { email, password } = req.body;
  const user = await User.findOne({ email }).select('+passwordHash');
  if (!user || !user.passwordHash) throw new AppError('Invalid credentials', 401);

  const match = await bcrypt.compare(password, user.passwordHash);
  if (!match) throw new AppError('Invalid credentials', 401);

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  return success(res, { user, accessToken, refreshToken }, 'Login successful');
});

// GET /api/v1/auth/profile
exports.getProfile = catchAsync(async (req, res) => {
  const user = await User.findById(req.user.id);
  return success(res, { user });
});

// PUT /api/v1/auth/profile
exports.updateProfile = catchAsync(async (req, res) => {
  const user = await User.findByIdAndUpdate(req.user.id, req.body, { new: true });
  return success(res, { user }, 'Profile updated');
});

// POST /api/v1/auth/refresh-token
exports.refreshToken = catchAsync(async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) throw new AppError('Refresh token required', 400);

  const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
  const user = await User.findById(decoded.id);
  if (!user) throw new AppError('User not found', 404);

  const accessToken = signAccessToken(user);
  return success(res, { accessToken }, 'Token refreshed');
});

// POST /api/v1/auth/logout
exports.logout = catchAsync(async (req, res) => {
  // Stateless JWT: client discards tokens. If using a refresh-token blacklist/store, invalidate it here.
  return success(res, null, 'Logged out');
});

// POST /api/v1/auth/fcm-token  { token } - registers this device's push
// notification token against the logged-in user. Called by both mobile
// apps on login and whenever Firebase issues a fresh token.
exports.registerFcmToken = catchAsync(async (req, res) => {
  const { token } = req.body;
  if (!token) throw new AppError('token is required', 400);

  await User.findByIdAndUpdate(req.user.id, { fcmToken: token });
  return success(res, null, 'Push token registered');
});
