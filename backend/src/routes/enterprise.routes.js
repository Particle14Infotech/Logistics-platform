const router = require('express').Router();
const ctrl = require('../controllers/enterprise.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

const enterpriseRoles = authorize('enterprise_admin', 'enterprise_user');
const adminOnly = authorize('enterprise_admin');

router.post('/signup', ctrl.signup);
router.post('/firebase-signup', ctrl.firebaseSignup);
router.get('/status', protect, ctrl.status);

router.post('/create', protect, ctrl.createAccount);
router.get('/dashboard', protect, enterpriseRoles, ctrl.dashboard);

router.get('/orders', protect, enterpriseRoles, ctrl.listOrders);
router.get('/orders/:id', protect, enterpriseRoles, ctrl.getOrderById);
router.post('/bulk-booking', protect, enterpriseRoles, ctrl.bulkBooking);

router.get('/users', protect, enterpriseRoles, ctrl.listUsers);
router.post('/users/invite', protect, adminOnly, ctrl.inviteUser);
router.put('/users/:id/role', protect, adminOnly, ctrl.updateUserRole);
router.delete('/users/:id', protect, adminOnly, ctrl.removeUser);

router.get('/invoices', protect, enterpriseRoles, ctrl.listInvoices);
router.get('/invoices/:id/pdf', protect, enterpriseRoles, ctrl.downloadInvoicePdf);

router.get('/contract-pricing', protect, enterpriseRoles, ctrl.getContractPricing);
router.put('/contract-pricing', protect, adminOnly, ctrl.updateContractPricing);

router.get('/api-key', protect, adminOnly, ctrl.getApiKey);
router.post('/api-key/regenerate', protect, adminOnly, ctrl.regenerateApiKey);

router.get('/driver-invite-code', protect, adminOnly, ctrl.getDriverInviteCode);
router.post('/driver-invite-code/regenerate', protect, adminOnly, ctrl.regenerateDriverInviteCode);
router.get('/drivers', protect, enterpriseRoles, ctrl.listDrivers);

module.exports = router;
