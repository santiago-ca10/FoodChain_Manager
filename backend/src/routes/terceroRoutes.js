const express = require('express');
const router = express.Router();
const { getTerceros, getTercero, createTercero, updateTercero, deleteTercero } = require('../controllers/terceroController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', getTerceros);
router.get('/:id', getTercero);
router.post('/', createTercero);
router.put('/:id', updateTercero);
router.delete('/:id', deleteTercero);

module.exports = router;
