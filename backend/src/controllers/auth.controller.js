const jwt = require('jsonwebtoken');
const User = require('../models/user.model');
const { success, AppError, catchAsync } = require('../utils/apiResponse');
const { admin, ensureInitialized } = require('../config/firebaseAdmin');
const { signAccessToken, signRefreshToken } = require('../utils/jwt');

// Which roles each mobile app is allowed to authenticate/create through
// firebase-session below. Reserved roles (admin, enterprise_admin,
// enterprise_user) are deliberately absent from both lists - they can
// never be created here, and an existing account with one of those roles
// gets rejected rather than silently logged in, regardless of which app
// (customer or driver) it's coming through. Without this, the same shared
// endpoint would find an existing user by email/firebaseUid and hand back
// a valid session no matter which app asked - e.g. an enterprise admin's
// email signing into the customer app "worked" (Firebase itself has no
// concept of which of our apps is calling), even though nothing downstream
// intended that account to be usable there.
const APP_ALLOWED_ROLES = {
  customer: ['customer'],
  driver: ['driver', 'fleet_owner'],
  // The enterprise portal's login page (returning users, not signup) also
  // exchanges its Firebase session through this same shared endpoint - see
  // EnterpriseLoginPage.jsx.
  enterprise: ['enterprise_admin', 'enterprise_user'],
};

// POST /api/v1/auth/firebase-session  { idToken, appContext, role? }
// Exchanges a verified Firebase ID token (email/password auth, handled
// entirely client-side by the Firebase SDK) for this app's own JWT session,
// so downstream routes/middleware never need to know Firebase exists. Mirrors
// verifyOtp's shape/response - Firebase is the credential+verification
// authority, this backend still owns the session.
exports.firebaseSession = catchAsync(async (req, res) => {
  const { idToken, role, appContext } = req.body;
  if (!idToken) throw new AppError('idToken is required', 400);
  const allowedRoles = APP_ALLOWED_ROLES[appContext];
  if (!allowedRoles) throw new AppError('appContext must be "customer" or "driver"', 400);
  if (!ensureInitialized()) throw new AppError('Firebase is not configured', 500);

  let decoded;
  try {
    decoded = await admin.auth().verifyIdToken(idToken);
  } catch (err) {
    throw new AppError('Invalid or expired Firebase token', 401);
  }

  if (!decoded.email_verified) throw new AppError('Email not verified', 403);

  const rejectWrongApp = (existingRole) => {
    throw new AppError(
      `This email is registered as a${existingRole === 'admin' ? 'n' : ''} ${existingRole.replace('_', ' ')} account - please use the correct app or portal to sign in.`,
      403
    );
  };

  let user = await User.findOne({ firebaseUid: decoded.uid });
  let isNewUser = false;

  if (user && !allowedRoles.includes(user.role)) rejectWrongApp(user.role);

  if (!user) {
    user = await User.findOne({ email: decoded.email });
    if (user) {
      if (!allowedRoles.includes(user.role)) rejectWrongApp(user.role);
      user.firebaseUid = decoded.uid;
      user.isVerified = true;
      await user.save();
    }
  }

  if (!user) {
    // Enterprise has a dedicated signup form (POST /enterprise/firebase-signup)
    // that collects company details and creates the Enterprise doc alongside
    // the User - auto-creating a bare User here for a brand-new email would
    // leave it with no Enterprise record and no way to ever get one, since
    // firebase-session would just find that same bare User on every later
    // attempt instead of retrying signup.
    if (appContext === 'enterprise') {
      throw new AppError('No account found with this email - use Sign Up to create a new enterprise account.', 404);
    }

    const newRole = role && allowedRoles.includes(role) ? role : allowedRoles[0];
    user = await User.create({
      email: decoded.email,
      firebaseUid: decoded.uid,
      isVerified: true,
      role: newRole,
    });
    isNewUser = true;
  }

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);

  return success(res, { user, accessToken, refreshToken, isNewUser }, 'Firebase session established');
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
  // passwordHash was explicitly re-selected above for bcrypt.compare - strip
  // it before the document goes into the response, or the hash leaks to
  // the client on every successful login.
  user.passwordHash = undefined;
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
  const { name, email, phone, dob, notificationsEnabled, gstin } = req.body;
  const user = await User.findByIdAndUpdate(
    req.user.id,
    { name, email, phone, dob, notificationsEnabled, gstin },
    { new: true }
  );
  return success(res, { user }, 'Profile updated');
});

// PUT /api/v1/auth/change-password  { currentPassword, newPassword }
// Bcrypt-password accounts only (admin portal - Firebase-based accounts
// change their password client-side via Firebase's own reauthenticate +
// updatePassword, which never touches this backend at all).
exports.changePassword = catchAsync(async (req, res) => {
  const bcrypt = require('bcryptjs');
  const { currentPassword, newPassword } = req.body;
  if (!currentPassword || !newPassword) throw new AppError('currentPassword and newPassword are required', 400);
  if (newPassword.length < 8) throw new AppError('New password must be at least 8 characters', 400);

  const user = await User.findById(req.user.id).select('+passwordHash');
  if (!user || !user.passwordHash) {
    throw new AppError('This account does not use a password login', 400);
  }

  const match = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!match) throw new AppError('Current password is incorrect', 401);

  user.passwordHash = await bcrypt.hash(newPassword, 10);
  await user.save();
  return success(res, {}, 'Password changed');
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
