const router = require('express').Router();
const ctrl = require('../controllers/booking.controller');
const { protect } = require('../middlewares/auth.middleware');

router.post('/estimate', protect, ctrl.estimate);
router.post('/create', protect, ctrl.create);
router.get('/:id', protect, ctrl.getById);
router.get('/user/:userId', protect, ctrl.listByUser);
router.put('/:id/cancel', protect, ctrl.cancel);
router.get('/:id/track', protect, ctrl.track);

module.exports = router;
