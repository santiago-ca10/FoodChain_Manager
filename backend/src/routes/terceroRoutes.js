const express = require('express');
const router = express.Router();
const terceroController = require('../controllers/terceroController');

router.post('/',         terceroController.crearTercero);
router.get('/',          terceroController.obtenerTerceros);
router.put('/:id',       terceroController.actualizarTercero);  
router.delete('/:id',    terceroController.eliminarTercero);    

module.exports = router;
