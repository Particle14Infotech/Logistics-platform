const router = require('express').Router();
const ctrl = require('../controllers/savedAddress.controller');
const { protect } = require('../middlewares/auth.middleware');

router.get('/', protect, ctrl.list);
router.post('/', protect, ctrl.create);
router.put('/:id', protect, ctrl.update);
router.delete('/:id', protect, ctrl.remove);

module.exports = router;
