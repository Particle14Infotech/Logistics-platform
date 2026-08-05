const sgMail = require('@sendgrid/mail');

// Lazy-init, gated on SENDGRID_API_KEY - mirrors the same
// graceful-degradation pattern used by firebaseAdmin.js/notification.service.js
// and maps.service.js: if unconfigured, callers still work, just logging to
// console instead of actually sending, rather than throwing.
let initialized = false;
let initFailed = false;

function ensureInitialized() {
  if (initialized || initFailed) return initialized;

  const { SENDGRID_API_KEY } = process.env;
  if (!SENDGRID_API_KEY) {
    initFailed = true;
    return false;
  }

  sgMail.setApiKey(SENDGRID_API_KEY);
  initialized = true;
  return true;
}

// sendEmail({ to, subject, text, html }) - html optional, falls back to text.
async function sendEmail({ to, subject, text, html }) {
  if (!ensureInitialized()) {
    console.log(`[email.service] SendGrid not configured - would have sent to ${to}: "${subject}"\n${text}`);
    return;
  }

  try {
    await sgMail.send({
      to,
      from: process.env.EMAIL_FROM,
      subject,
      text,
      html: html || text,
    });
  } catch (err) {
    console.error(`[email.service] Failed to send to ${to}:`, err.response?.body || err.message);
  }
}

module.exports = { sendEmail, isConfigured: ensureInitialized };
