const jwt = require('jsonwebtoken');
const User = require('../models/user.model');
const { success, AppError, catchAsync } = require('../utils/apiResponse');
const otpService = require('../services/otp.service');
const { admin, ensureInitialized } = require('../config/firebaseAdmin');
const { signAccessToken, signRefreshToken } = require('../utils/jwt');

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

// POST /api/v1/auth/firebase-session  { idToken, role? }
// Exchanges a verified Firebase ID token (email/password auth, handled
// entirely client-side by the Firebase SDK) for this app's own JWT session,
// so downstream routes/middleware never need to know Firebase exists. Mirrors
// verifyOtp's shape/response - Firebase is the credential+verification
// authority, this backend still owns the session.
exports.firebaseSession = catchAsync(async (req, res) => {
  const { idToken, role } = req.body;
  if (!idToken) throw new AppError('idToken is required', 400);
  if (!ensureInitialized()) throw new AppError('Firebase is not configured', 500);

  let decoded;
  try {
    decoded = await admin.auth().verifyIdToken(idToken);
  } catch (err) {
    throw new AppError('Invalid or expired Firebase token', 401);
  }

  if (!decoded.email_verified) throw new AppError('Email not verified', 403);

  let user = await User.findOne({ firebaseUid: decoded.uid });
  let isNewUser = false;

  if (!user) {
    user = await User.findOne({ email: decoded.email });
    if (user) {
      user.firebaseUid = decoded.uid;
      user.isVerified = true;
      await user.save();
    }
  }

  if (!user) {
    user = await User.create({
      email: decoded.email,
      firebaseUid: decoded.uid,
      isVerified: true,
      role: role || 'customer',
    });
    isNewUser = true;
  }

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);

  return success(res, { user, accessToken, refreshToken, isNewUser }, 'Firebase session established');
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
// Self-service roles only - this endpoint must never be able to grant
// admin/enterprise_admin/enterprise_user, since it's reachable by any
// authenticated user completing their own profile right after OTP/Firebase
// verification (see otp_login_screen.dart / email_auth_screen.dart in both
// mobile apps).
const SELF_SERVICE_ROLES = ['customer', 'driver', 'fleet_owner'];

exports.register = catchAsync(async (req, res) => {
  const { name, email, role } = req.body;
  if (role && !SELF_SERVICE_ROLES.includes(role)) {
    throw new AppError(`role must be one of: ${SELF_SERVICE_ROLES.join(', ')}`, 400);
  }

  // req.user.id (from the caller's own verified JWT), never a userId taken
  // from the request body - otherwise any caller could update ANY user's
  // name/email/role by guessing/knowing their Mongo _id, not just their own.
  const user = await User.findByIdAndUpdate(
    req.user.id,
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
// Explicit field whitelist - req.body must never be spread directly into
// findByIdAndUpdate, or any authenticated caller could set their own role/
// isVerified/isBlocked/enterpriseId (same class of bug already fixed on
// /auth/register above).
exports.updateProfile = catchAsync(async (req, res) => {
  const { name, email, phone, dob, notificationsEnabled } = req.body;
  const user = await User.findByIdAndUpdate(
    req.user.id,
    { name, email, phone, dob, notificationsEnabled },
    { new: true }
  );
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
