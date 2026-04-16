const express = require('express');
const router = express.Router();
const movimientoController = require('../controllers/movimientoController');

router.get('/', movimientoController.obtenerHistorial);
router.post('/', movimientoController.registrarMovimiento);

module.exports = router;