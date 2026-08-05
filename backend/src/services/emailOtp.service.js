const { sendEmail } = require('./email.service');

// In-memory store, keyed by Firebase UID (not raw email) - ties a code to
// an already-authenticated Firebase session rather than a bare string
// anyone could guess/spam. Fine for a single backend instance; would need
// Redis if this ever runs as more than one replica (same caveat the old
// phone-OTP service had).
const OTP_TTL_MS = 10 * 60 * 1000; // 10 minutes
const store = new Map(); // uid -> { code, expiresAt }

const generateCode = () => Math.floor(100000 + Math.random() * 900000).toString();

async function sendOtp(uid, email) {
  const code = generateCode();
  store.set(uid, { code, expiresAt: Date.now() + OTP_TTL_MS });

  // Always logged, not just when SendGrid is unconfigured - lets this be
  // tested locally without a real SendGrid key, same dev-fallback spirit
  // the old phone-OTP service used for SMS.
  console.log(`[emailOtp.service] OTP for ${email} (uid ${uid}): ${code}`);

  await sendEmail({
    to: email,
    subject: 'Verify your email',
    text: `Your verification code is ${code}. It expires in 10 minutes.`,
    html: `<p>Your verification code is <strong>${code}</strong>. It expires in 10 minutes.</p>`,
  });
}

function verifyOtp(uid, code) {
  const entry = store.get(uid);
  if (!entry) return false;
  if (Date.now() > entry.expiresAt) {
    store.delete(uid);
    return false;
  }
  if (entry.code !== code) return false;

  store.delete(uid);
  return true;
}

module.exports = { sendOtp, verifyOtp };
