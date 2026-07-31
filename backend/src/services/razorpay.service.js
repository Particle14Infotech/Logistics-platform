const Razorpay = require('razorpay');
const crypto = require('crypto');
const User = require('../models/user.model');

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

// Lazily creates (once) the Razorpay Customer backing this user's saved
// cards - Standard Checkout only offers "save this card" / shows saved
// cards when opened with a customer_id. fail_existing: 0 makes this
// idempotent: if a customer with the same contact/email already exists on
// Razorpay's side, it returns that one instead of erroring.
exports.ensureCustomer = async (user) => {
  if (user.razorpayCustomerId) return user.razorpayCustomerId;

  const customer = await getClient().customers.create({
    name: user.name || 'Customer',
    email: user.email || undefined,
    contact: user.phone || undefined,
    fail_existing: 0,
  });

  user.razorpayCustomerId = customer.id;
  await User.findByIdAndUpdate(user._id, { razorpayCustomerId: customer.id });
  return customer.id;
};

exports.listSavedCards = async (customerId) => {
  const { items } = await getClient().customers.fetchTokens(customerId);
  return items
    .filter((token) => token.method === 'card' && token.card)
    .map((token) => ({
      tokenId: token.id,
      last4: token.card.last4,
      network: token.card.network,
      issuer: token.card.issuer ?? null,
      type: token.card.type ?? null,
    }));
};

exports.deleteSavedCard = async (customerId, tokenId) => {
  return getClient().customers.deleteToken(customerId, tokenId);
};
