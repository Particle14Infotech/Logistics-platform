const router = require('express').Router();
const ctrl = require('../controllers/admin.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.use(protect, authorize('admin'));

router.get('/orders', ctrl.listOrders);
router.get('/orders/:id', ctrl.getOrderById);
router.put('/orders/:id/assign', ctrl.assignDriver);

router.get('/drivers', ctrl.listDrivers);
router.get('/drivers/:id', ctrl.getDriverById);
router.put('/drivers/:id', ctrl.updateDriverStatus);
router.get('/drivers/:id/wallet', ctrl.getDriverWallet);
router.post('/drivers/:id/payout', ctrl.payoutDriver);
router.get('/drivers/:id/report', ctrl.getDriverReport);
router.get('/drivers/:id/report/pdf', ctrl.getDriverReportPdf);

router.get('/vehicles', ctrl.listVehicles);

router.get('/fleets', ctrl.listFleets);
router.get('/fleets/:id', ctrl.getFleetById);

router.get('/pricing', ctrl.getPricing);
router.put('/pricing', ctrl.updatePricing);

router.get('/payments', ctrl.listPayments);
router.put('/payments/:id/refund', ctrl.refundPayment);
router.put('/invoices/:id/status', ctrl.updateInvoiceStatus);

router.get('/disputes', ctrl.listDisputes);
router.put('/disputes/:id/resolve', ctrl.resolveDispute);

router.get('/enterprises', ctrl.listEnterprises);
router.put('/enterprises/:id/status', ctrl.updateEnterpriseStatus);

router.get('/analytics', ctrl.analytics);
router.get('/fleet-live', ctrl.fleetLive);

router.get('/banners', ctrl.listBanners);
router.post('/banners', ctrl.createBanner);
router.put('/banners/:id', ctrl.updateBanner);
router.delete('/banners/:id', ctrl.deleteBanner);

router.get('/faqs', ctrl.listFaqs);
router.post('/faqs', ctrl.createFaq);
router.put('/faqs/:id', ctrl.updateFaq);
router.delete('/faqs/:id', ctrl.deleteFaq);

router.get('/notifications', ctrl.listNotifications);
router.post('/notifications', ctrl.sendNotification);

module.exports = router;
