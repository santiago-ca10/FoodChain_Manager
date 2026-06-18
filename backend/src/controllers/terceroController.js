const { Tercero } = require('../models');

const getTerceros = async (req, res) => {
  try {
    const terceros = await Tercero.findAll({ order: [['nombre', 'ASC']] });
    res.json(terceros);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getTercero = async (req, res) => {
  try {
    const tercero = await Tercero.findByPk(req.params.id);
    if (!tercero) return res.status(404).json({ error: 'Tercero no encontrado' });
    res.json(tercero);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const createTercero = async (req, res) => {
  try {
    const { nombre, tipo, telefono, email, direccion } = req.body;
    if (!nombre || !tipo) {
      return res.status(400).json({ error: 'nombre y tipo son requeridos' });
    }
    const tercero = await Tercero.create({ nombre, tipo, telefono, email, direccion });
    res.status(201).json(tercero);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const updateTercero = async (req, res) => {
  try {
    const tercero = await Tercero.findByPk(req.params.id);
    if (!tercero) return res.status(404).json({ error: 'Tercero no encontrado' });

    const { nombre, tipo, telefono, email, direccion } = req.body;
    if (!nombre || !tipo) {
      return res.status(400).json({ error: 'nombre y tipo son requeridos' });
    }

    await tercero.update({ nombre, tipo, telefono, email, direccion });
    res.json(tercero);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const deleteTercero = async (req, res) => {
  try {
    const tercero = await Tercero.findByPk(req.params.id);
    if (!tercero) return res.status(404).json({ error: 'Tercero no encontrado' });
    await tercero.destroy();
    res.json({ message: 'Tercero eliminado' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { getTerceros, getTercero, createTercero, updateTercero, deleteTercero };
