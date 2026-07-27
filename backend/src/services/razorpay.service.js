const Razorpay = require('razorpay');
const crypto = require('crypto');

let client = null;

function getClient() {
  if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
    throw new Error('Razorpay is not configured - set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in backend/.env');
  }
  if (!client) {
    client = new Razorpay({ key_id: process.env.RAZORPAY_KEY_ID, key_secret: process.env.RAZORPAY_KEY_SECRET });
  }
  return client;
}

// amountPaise: integer, smallest currency unit (paise for INR)
exports.createRazorpayOrder = async ({ amountPaise, receipt, notes }) => {
  return getClient().orders.create({ amount: amountPaise, currency: 'INR', receipt, notes });
};

// Client-callback verification: HMAC-SHA256 of "orderId|paymentId" using the
// key secret, per Razorpay's Standard Checkout signature scheme.
exports.verifySignature = ({ orderId, paymentId, signature }) => {
  const expected = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(`${orderId}|${paymentId}`)
    .digest('hex');
  return expected === signature;
};

// Webhook verification: HMAC-SHA256 of the raw request body using the
// separate webhook secret (configured in the Razorpay dashboard, not the
// same as the API key secret).
exports.verifyWebhookSignature = (rawBody, signature) => {
  if (!process.env.RAZORPAY_WEBHOOK_SECRET || !signature) return false;
  const expected = crypto
    .createHmac('sha256', process.env.RAZORPAY_WEBHOOK_SECRET)
    .update(rawBody)
    .digest('hex');
  return expected === signature;
};

exports.refundPayment = async (razorpayPaymentId, amountPaise) => {
  return getClient().payments.refund(razorpayPaymentId, amountPaise ? { amount: amountPaise } : {});
};
