const router = require('express').Router();
const ctrl = require('../controllers/enterprise.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.post('/create', protect, ctrl.createAccount);
router.get('/dashboard', protect, authorize('enterprise_admin', 'enterprise_user'), ctrl.dashboard);
router.post('/bulk-booking', protect, authorize('enterprise_admin', 'enterprise_user'), ctrl.bulkBooking);
router.post('/users/invite', protect, authorize('enterprise_admin'), ctrl.inviteUser);
router.get('/invoices', protect, authorize('enterprise_admin', 'enterprise_user'), ctrl.listInvoices);
router.get('/invoices/:id/pdf', protect, authorize('enterprise_admin', 'enterprise_user'), ctrl.downloadInvoicePdf);

module.exports = router;
