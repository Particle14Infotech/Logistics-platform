const router = require('express').Router();

router.use('/auth', require('./auth.routes'));
router.use('/booking', require('./booking.routes'));
router.use('/driver', require('./driver.routes'));
router.use('/payment', require('./payment.routes'));
router.use('/enterprise', require('./enterprise.routes'));
router.use('/fleet', require('./fleet.routes'));
router.use('/places', require('./places.routes'));
router.use('/bid', require('./bid.routes'));
router.use('/admin', require('./admin.routes'));

module.exports = router;
