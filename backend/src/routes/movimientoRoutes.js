const express = require('express');
const router = express.Router();
const movimientoController = require('../controllers/movimientoController');

router.post('/',      movimientoController.registrarMovimiento);
router.get('/',       movimientoController.obtenerHistorial);
router.delete('/:id', movimientoController.eliminarMovimiento);  

module.exports = router;