const Tercero = require('../models/Tercero');

// Crear un nuevo Tercero (Cliente o Proveedor)
exports.crearTercero = async (req, res) => {
  try {
    const nuevoTercero = await Tercero.create(req.body);
    res.status(201).json(nuevoTercero);
  } catch (error) {
    res.status(400).json({ error: 'No se pudo crear el tercero', detalle: error.message });
  }
};

// Obtener todos los Terceros
exports.obtenerTerceros = async (req, res) => {
  try {
    const terceros = await Tercero.findAll();
    res.json(terceros);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener terceros' });
  }
};

// Actualizar un Tercero existente
exports.actualizarTercero = async (req, res) => {
  try {
    const tercero = await Tercero.findByPk(req.params.id);
    if (!tercero) {
      return res.status(404).json({ error: 'Tercero no encontrado' });
    }
    await tercero.update(req.body);
    res.json(tercero);
  } catch (error) {
    res.status(400).json({ error: 'Error al actualizar tercero', detalle: error.message });
  }
};

// Eliminar un Tercero
exports.eliminarTercero = async (req, res) => {
  try {
    const tercero = await Tercero.findByPk(req.params.id);
    if (!tercero) {
      return res.status(404).json({ error: 'Tercero no encontrado' });
    }
    await tercero.destroy();
    res.json({ mensaje: 'Tercero eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar tercero', detalle: error.message });
  }
};