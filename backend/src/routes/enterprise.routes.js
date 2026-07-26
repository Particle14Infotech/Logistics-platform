const router = require('express').Router();
const ctrl = require('../controllers/enterprise.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

const enterpriseRoles = authorize('enterprise_admin', 'enterprise_user');
const adminOnly = authorize('enterprise_admin');

router.post('/create', protect, ctrl.createAccount);
router.get('/dashboard', protect, enterpriseRoles, ctrl.dashboard);

router.get('/orders', protect, enterpriseRoles, ctrl.listOrders);
router.post('/bulk-booking', protect, enterpriseRoles, ctrl.bulkBooking);

router.get('/users', protect, enterpriseRoles, ctrl.listUsers);
router.post('/users/invite', protect, adminOnly, ctrl.inviteUser);

router.get('/invoices', protect, enterpriseRoles, ctrl.listInvoices);
router.get('/invoices/:id/pdf', protect, enterpriseRoles, ctrl.downloadInvoicePdf);

router.get('/contract-pricing', protect, enterpriseRoles, ctrl.getContractPricing);
router.put('/contract-pricing', protect, adminOnly, ctrl.updateContractPricing);

router.get('/api-key', protect, adminOnly, ctrl.getApiKey);
router.post('/api-key/regenerate', protect, adminOnly, ctrl.regenerateApiKey);

module.exports = router;
