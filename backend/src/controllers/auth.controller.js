const jwt = require('jsonwebtoken');
const User = require('../models/user.model');
const { success, AppError, catchAsync } = require('../utils/apiResponse');
const { admin, ensureInitialized } = require('../config/firebaseAdmin');
const { signAccessToken, signRefreshToken } = require('../utils/jwt');
const emailOtpService = require('../services/emailOtp.service');
const portalLoginOtpService = require('../services/portalLoginOtp.service');

// Both send-email-otp and verify-email-otp run before the app has any JWT
// session (mid-registration/verification, only a Firebase session exists
// yet) - authenticated via the Firebase ID token itself, sent as this
// custom header rather than Authorization so it can never collide with
// protect()'s own Bearer-JWT handling on routes that do use it.
async function requireFirebaseToken(req) {
  const idToken = req.headers['x-firebase-token'];
  if (!idToken) throw new AppError('X-Firebase-Token header is required', 401);
  if (!ensureInitialized()) throw new AppError('Firebase is not configured', 500);

  try {
    return await admin.auth().verifyIdToken(idToken);
  } catch (err) {
    throw new AppError('Invalid or expired Firebase token', 401);
  }
}

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
  // Admin portal's phone-OTP login (email/password there still goes through
  // the separate bcrypt exports.login below, unchanged) - see
  // AdminLoginPage.jsx.
  admin: ['admin'],
};

// customer/driver phone or email sign-in auto-creates an account on first
// use - that's the point, frictionless self-signup. admin/enterprise are
// privileged roles that must never come into existence this way: an admin
// account only ever gets created by another admin (or seeded directly),
// and enterprise has its own dedicated signup form that also creates the
// Enterprise company record alongside the User (POST /enterprise/firebase-signup) -
// auto-creating a bare User here for either would either grant admin
// access to anyone who can prove a phone number, or leave an enterprise
// account permanently missing its company profile.
const NO_AUTO_CREATE_CONTEXTS = new Set(['enterprise', 'admin']);

// POST /api/v1/auth/firebase-session  { idToken, appContext, role? }
// Exchanges a verified Firebase ID token for this app's own JWT session, so
// downstream routes/middleware never need to know Firebase exists. Mirrors
// verifyOtp's shape/response - Firebase is the credential+verification
// authority, this backend still owns the session.
//
// Handles two independent Firebase sign-in methods through the same
// endpoint: email/password (decoded.email + email_verified) and phone/SMS
// (decoded.phone_number, set by Firebase itself once the SMS code is
// confirmed client-side - there's no separate "email_verified"-equivalent
// flag to check, the token wouldn't exist yet without it). Whichever one
// signed the token in, the match/create logic below just swaps which field
// it keys off - everything else (role gating, blocked check, JWT issuance)
// is identical either way.
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

  const isPhoneAuth = !!decoded.phone_number;
  if (!isPhoneAuth && !decoded.email_verified) throw new AppError('Email not verified', 403);

  const matchQuery = isPhoneAuth ? { phone: decoded.phone_number } : { email: decoded.email };

  const rejectWrongApp = (existingRole) => {
    throw new AppError(
      `This ${isPhoneAuth ? 'phone number' : 'email'} is registered as a${existingRole === 'admin' ? 'n' : ''} ${existingRole.replace('_', ' ')} account - please use the correct app or portal to sign in.`,
      403
    );
  };

  let user = await User.findOne({ firebaseUid: decoded.uid });
  let isNewUser = false;

  if (user && !allowedRoles.includes(user.role)) rejectWrongApp(user.role);

  if (!user) {
    user = await User.findOne(matchQuery);
    if (user) {
      if (!allowedRoles.includes(user.role)) rejectWrongApp(user.role);
      user.firebaseUid = decoded.uid;
      user.isVerified = true;
      await user.save();
    }
  }

  if (user?.isBlocked) throw new AppError('This account has been blocked. Contact support.', 403);

  if (!user) {
    if (NO_AUTO_CREATE_CONTEXTS.has(appContext)) {
      if (appContext === 'enterprise' && !isPhoneAuth) {
        throw new AppError('No account found with this email - use Sign Up to create a new enterprise account.', 404);
      }
      // Phone sign-in (either context) or an admin email with no match -
      // there's no self-service signup to point at, since neither role can
      // be created this way at all. Existing account just hasn't linked
      // this phone number yet.
      throw new AppError(
        `No ${appContext} account is linked to this ${isPhoneAuth ? 'phone number' : 'email'} - log in with your password first, then add ${isPhoneAuth ? 'this phone number' : 'it'} in your profile.`,
        404
      );
    }

    const newRole = role && allowedRoles.includes(role) ? role : allowedRoles[0];
    user = await User.create({
      ...matchQuery,
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

// Which roles each portal is allowed to sign in as via passwordless email
// OTP - same role split as APP_ALLOWED_ROLES' admin/enterprise entries,
// kept separate since this path has nothing to do with Firebase (no
// idToken, no email_verified check - the code itself is the proof).
const PORTAL_OTP_ALLOWED_ROLES = {
  admin: ['admin'],
  enterprise: ['enterprise_admin', 'enterprise_user'],
};

// POST /api/v1/auth/portal/request-otp  { email, appContext }
// Passwordless login for Admin/Enterprise, alongside (not replacing)
// existing password login - a code emailed straight from this backend via
// SendGrid, no Firebase involved for this particular path.
exports.requestPortalOtp = catchAsync(async (req, res) => {
  const { email, appContext } = req.body;
  const allowedRoles = PORTAL_OTP_ALLOWED_ROLES[appContext];
  if (!allowedRoles) throw new AppError('appContext must be "admin" or "enterprise"', 400);
  if (!email) throw new AppError('email is required', 400);

  const user = await User.findOne({ email: email.trim().toLowerCase(), role: { $in: allowedRoles } });
  // Identical response whether or not an account exists - this is a login
  // bypass with no password check, so letting the response confirm/deny an
  // email's existence would make the whole portal user base enumerable.
  // The send itself is silently skipped on no match/blocked.
  if (user && !user.isBlocked) {
    await portalLoginOtpService.sendLoginOtp(user.email);
  }
  return success(res, null, 'If that email has an account, a code has been sent.');
});

// POST /api/v1/auth/portal/verify-otp  { email, code, appContext }
exports.verifyPortalOtp = catchAsync(async (req, res) => {
  const { email, code, appContext } = req.body;
  const allowedRoles = PORTAL_OTP_ALLOWED_ROLES[appContext];
  if (!allowedRoles) throw new AppError('appContext must be "admin" or "enterprise"', 400);
  if (!email || !code) throw new AppError('email and code are required', 400);

  const result = portalLoginOtpService.verifyLoginOtp(email.trim().toLowerCase(), code.trim());
  if (result === 'expired') throw new AppError('That code expired - request a new one.', 400);
  if (result === 'too-many-attempts') throw new AppError('Too many incorrect attempts - request a new code.', 429);
  if (result !== 'ok') throw new AppError('Incorrect code.', 400);

  // The code could only have been sent to a real, unblocked, correctly-
  // roled account (see requestPortalOtp) - re-checking here just guards
  // against the account being blocked/deleted in the few minutes between
  // the two calls, not a normal path.
  const user = await User.findOne({ email: email.trim().toLowerCase(), role: { $in: allowedRoles } });
  if (!user) throw new AppError('Incorrect code.', 400);
  if (user.isBlocked) throw new AppError('This account has been blocked. Contact support.', 403);

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  return success(res, { user, accessToken, refreshToken }, 'Signed in');
});

// POST /api/v1/auth/send-email-otp - alternative to Firebase's own "click
// the link we emailed you" verification (EmailAuthScreen offers both, the
// user's choice). Header: X-Firebase-Token.
exports.sendEmailVerificationOtp = catchAsync(async (req, res) => {
  const decoded = await requireFirebaseToken(req);
  await emailOtpService.sendOtp(decoded.uid, decoded.email);
  return success(res, null, 'Verification code sent');
});

// POST /api/v1/auth/verify-email-otp  { otp }  Header: X-Firebase-Token
// On a correct code, marks the Firebase user's email verified server-side
// via the Admin SDK - the same flag Firebase itself would set after the
// user clicks the emailed link, so everything downstream (syncFirebaseSession
// re-fetching a fresh ID token) behaves identically either way.
exports.verifyEmailOtp = catchAsync(async (req, res) => {
  const decoded = await requireFirebaseToken(req);
  const { otp } = req.body;
  if (!otp) throw new AppError('otp is required', 400);

  const valid = emailOtpService.verifyOtp(decoded.uid, otp);
  if (!valid) throw new AppError('Invalid or expired code', 400);

  await admin.auth().updateUser(decoded.uid, { emailVerified: true });
  return success(res, null, 'Email verified');
});

// POST /api/v1/auth/login (email/password - used by Admin/Enterprise)
exports.login = catchAsync(async (req, res) => {
  const bcrypt = require('bcryptjs');
  const { email, password } = req.body;
  const user = await User.findOne({ email }).select('+passwordHash');
  if (!user || !user.passwordHash) throw new AppError('Invalid credentials', 401);

  const match = await bcrypt.compare(password, user.passwordHash);
  if (!match) throw new AppError('Invalid credentials', 401);
  if (user.isBlocked) throw new AppError('This account has been blocked. Contact support.', 403);

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
  // This is the check that actually matters for isBlocked - access tokens
  // are short-lived, so a blocked user's existing token expiring and then
  // hitting this wall on refresh is what ends their session in practice.
  if (user.isBlocked) throw new AppError('This account has been blocked. Contact support.', 403);

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
