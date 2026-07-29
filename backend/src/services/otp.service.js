// Abstracts OTP generation/verification behind the SMS provider (MSG91/Twilio).
// For production, store OTP hashes in Redis with a short TTL instead of in-memory.
const axios = require('axios');
const otpStore = new Map(); // phone -> { otp, expiresAt }

const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

// Sends via whichever provider is configured (SMS_PROVIDER env var) -
// returns true/false for whether a real SMS actually went out, purely for
// logging; sendOtp() below always succeeds either way; a failed real send
// still falls through to the dev console log so testing isn't blocked by
// a provider hiccup.
async function sendRealSms(phone, otp) {
  const provider = process.env.SMS_PROVIDER;

  if (provider === 'msg91' && process.env.MSG91_AUTH_KEY) {
    try {
      // MSG91's OTP endpoint accepts our own pre-generated code via the
      // `otp` param, so it just delivers it - no change needed to our
      // verifyOtp() below, which still checks the same in-memory value.
      await axios.get('https://control.msg91.com/api/v5/otp', {
        params: {
          otp,
          mobile: `91${phone}`,
          authkey: process.env.MSG91_AUTH_KEY,
          template_id: process.env.MSG91_TEMPLATE_ID,
        },
      });
      return true;
    } catch (err) {
      console.error('[otp.service] MSG91 send failed:', err.response?.data || err.message);
      return false;
    }
  }

  if (provider === 'twilio' && process.env.TWILIO_ACCOUNT_SID) {
    try {
      await axios.post(
        `https://api.twilio.com/2010-04-01/Accounts/${process.env.TWILIO_ACCOUNT_SID}/Messages.json`,
        new URLSearchParams({
          To: `+91${phone}`,
          From: process.env.TWILIO_FROM_NUMBER,
          Body: `Your Raah Mitr verification code is ${otp}`,
        }),
        { auth: { username: process.env.TWILIO_ACCOUNT_SID, password: process.env.TWILIO_AUTH_TOKEN } }
      );
      return true;
    } catch (err) {
      console.error('[otp.service] Twilio send failed:', err.response?.data || err.message);
      return false;
    }
  }

  return false; // no provider configured
}

exports.sendOtp = async (phone) => {
  const otp = generateOtp();
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 min validity
  otpStore.set(phone, { otp, expiresAt });

  const sentForReal = await sendRealSms(phone, otp);

  // Always log in dev, and as a fallback in production if the real send
  // failed - otherwise a provider outage would silently lock everyone out
  // with no way to see what the code even was.
  if (!sentForReal && process.env.NODE_ENV !== 'production') {
    console.log(`[DEV OTP] ${phone} -> ${otp}`);
  } else if (!sentForReal) {
    console.error(`[otp.service] No SMS provider configured/working - OTP for ${phone} was not delivered.`);
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
