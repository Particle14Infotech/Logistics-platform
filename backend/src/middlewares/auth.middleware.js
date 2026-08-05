const jwt = require('jsonwebtoken');
const Enterprise = require('../models/enterprise.model');

// Verifies Bearer JWT and attaches req.user
const protect = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Not authenticated' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
    req.user = decoded; // { id, role }
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
};

// Restricts route to specific roles, e.g. authorize('admin', 'enterprise_admin')
const authorize = (...roles) => (req, res, next) => {
  if (!req.user || !roles.includes(req.user.role)) {
    return res.status(403).json({ success: false, message: 'Forbidden: insufficient role' });
  }
  next();
};

// Enterprise API-key auth (X-API-Key header) as an alternative to a human
// JWT session, for the two endpoints the key is actually documented for on
// EnterpriseApiKeysPage.jsx: bulk booking and order tracking. Deliberately
// NOT wired into every enterprise route via the shared `protect` - keeping
// it opt-in per-route means a leaked key can only book/read orders, not
// invite users or change contract pricing.
const protectApiKeyOrJwt = async (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (!apiKey) return protect(req, res, next);

  const enterprise = await Enterprise.findOne({ apiKey, isActive: true }).select('adminUserId');
  if (!enterprise) return res.status(401).json({ success: false, message: 'Invalid API key' });

  req.user = { id: enterprise.adminUserId.toString(), role: 'enterprise_admin' };
  next();
};

module.exports = { protect, authorize, protectApiKeyOrJwt };
