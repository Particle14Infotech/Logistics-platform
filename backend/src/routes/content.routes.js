const router = require('express').Router();
const ctrl = require('../controllers/content.controller');

router.get('/faqs', ctrl.listFaqs);
router.get('/banners', ctrl.listBanners);

module.exports = router;
