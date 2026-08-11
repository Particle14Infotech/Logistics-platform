const { sendEmail } = require('./email.service');

// Passwordless email-OTP login for the Admin/Enterprise web portals - a
// second, independent way in alongside the existing password (and, for
// enterprise, Firebase email/password) login, not a replacement. Unlike
// emailOtp.service.js (which just re-verifies an email during signup, keyed
// by an already-authenticated Firebase uid), this code IS the credential -
// whoever enters it gets a real session with no password check at all, so
// it's keyed by email + rate-limited on verify attempts rather than trusting
// a short TTL alone.
const OTP_TTL_MS = 10 * 60 * 1000; // 10 minutes
const MAX_ATTEMPTS = 5;
const store = new Map(); // lowercased email -> { code, expiresAt, attempts }

const generateCode = () => Math.floor(100000 + Math.random() * 900000).toString();

async function sendLoginOtp(email) {
  const key = email.toLowerCase();
  const code = generateCode();
  store.set(key, { code, expiresAt: Date.now() + OTP_TTL_MS, attempts: 0 });

  // Always logged, not just when SendGrid is unconfigured - same
  // dev-fallback spirit as emailOtp.service.js.
  console.log(`[portalLoginOtp.service] Login OTP for ${email}: ${code}`);

  await sendEmail({
    to: email,
    subject: 'Your sign-in code',
    text: `Your sign-in code is ${code}. It expires in 10 minutes. If you didn't request this, you can ignore this email.`,
    html: `<p>Your sign-in code is <strong>${code}</strong>. It expires in 10 minutes.</p><p>If you didn't request this, you can ignore this email.</p>`,
  });
}

// Returns 'ok' | 'invalid' | 'expired' | 'too-many-attempts' - distinct
// outcomes so the endpoint can tell "wrong code, try again" apart from
// "start over", rather than one flat true/false.
function verifyLoginOtp(email, code) {
  const key = email.toLowerCase();
  const entry = store.get(key);
  if (!entry) return 'invalid';

  if (Date.now() > entry.expiresAt) {
    store.delete(key);
    return 'expired';
  }
  if (entry.attempts >= MAX_ATTEMPTS) {
    store.delete(key);
    return 'too-many-attempts';
  }

  if (entry.code !== code) {
    entry.attempts += 1;
    return 'invalid';
  }

  store.delete(key);
  return 'ok';
}

module.exports = { sendLoginOtp, verifyLoginOtp };
