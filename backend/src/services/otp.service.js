// Abstracts OTP generation/verification behind the SMS provider (MSG91/Twilio).
// For production, store OTP hashes in Redis with a short TTL instead of in-memory.
const otpStore = new Map(); // phone -> { otp, expiresAt }

const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

exports.sendOtp = async (phone) => {
  const otp = generateOtp();
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 min validity
  otpStore.set(phone, { otp, expiresAt });

  // TODO: integrate MSG91 / Twilio here
  // await smsProvider.send(phone, `Your OTP is ${otp}`);
  if (process.env.NODE_ENV !== 'production') {
    console.log(`[DEV OTP] ${phone} -> ${otp}`);
  }
  return true;
};

exports.verifyOtp = async (phone, otp) => {
  const record = otpStore.get(phone);
  if (!record) return false;
  if (Date.now() > record.expiresAt) {
    otpStore.delete(phone);
    return false;
  }
  const isValid = record.otp === otp;
  if (isValid) otpStore.delete(phone);
  return isValid;
};
