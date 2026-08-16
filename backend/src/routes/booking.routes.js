const router = require('express').Router();
const ctrl = require('../controllers/booking.controller');
const { protect } = require('../middlewares/auth.middleware');

router.get('/vehicle-categories', protect, ctrl.vehicleCategories);
router.post('/estimate', protect, ctrl.estimate);
router.post('/create', protect, ctrl.create);
router.get('/:id', protect, ctrl.getById);
router.post('/:id/review', protect, ctrl.submitReview);
router.post('/:id/dispute', protect, ctrl.raiseDispute);
router.get('/user/:userId', protect, ctrl.listByUser);
router.put('/:id/cancel', protect, ctrl.cancel);
router.get('/:id/track', protect, ctrl.track);
router.get('/:id/invoice', protect, ctrl.downloadInvoicePdf);
router.put('/:id/waybill-details', protect, ctrl.updateWaybillDetails);
router.get('/:id/messages', protect, ctrl.listMessages);

module.exports = router;
