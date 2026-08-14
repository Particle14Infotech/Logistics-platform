const router = require('express').Router();
const ctrl = require('../controllers/driver.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.use(protect, authorize('driver'));

router.get('/profile', ctrl.getProfile);
router.post('/profile', ctrl.createProfile);
router.post('/documents/:documentType', ctrl.uploadMiddleware, ctrl.uploadDocument);
router.put('/status', ctrl.updateStatus);
router.put('/location', ctrl.updateLocation);

router.get('/available-orders', ctrl.availableOrders);
router.post('/accept/:bookingId', ctrl.acceptOrder);
router.post('/reject/:bookingId', ctrl.rejectOrder);

router.get('/orders', ctrl.listMyOrders);
router.get('/orders/:id', ctrl.getOrder);
router.put('/orders/:id/status', ctrl.updateOrderStatus);
router.post('/orders/:id/pickup-documents', ctrl.uploadPickupDocumentsMiddleware, ctrl.uploadPickupDocuments);
router.post('/orders/:id/delivery-documents', ctrl.uploadDeliveryDocumentsMiddleware, ctrl.uploadDeliveryDocuments);
router.post('/pod/:bookingId', ctrl.uploadPod);

router.get('/earnings', ctrl.earnings);
router.get('/wallet', ctrl.wallet);
router.put('/bank-details', ctrl.updateBankDetails);
router.put('/vehicle', ctrl.updateVehicle);

module.exports = router;
