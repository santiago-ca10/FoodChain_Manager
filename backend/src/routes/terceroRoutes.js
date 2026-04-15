const express = require('express');
const router = express.Router();
const terceroController = require('../controllers/terceroController');

// Definimos los endpoints
router.post('/', terceroController.crearTercero);
router.get('/', terceroController.obtenerTerceros);

module.exports = router;