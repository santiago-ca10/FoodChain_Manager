const Producto = require('../models/Producto');

exports.crearProducto = async (req, res) => {
  try {
    const nuevoProducto = await Producto.create(req.body);
    res.status(201).json(nuevoProducto);
  } catch (error) {
    res.status(400).json({ error: 'Error al crear producto', detalle: error.message });
  }
};

exports.obtenerProductos = async (req, res) => {
  try {
    const productos = await Producto.findAll();
    res.json(productos);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener productos' });
  }
};


exports.actualizarProducto = async (req, res) => {
  try {
    const producto = await Producto.findByPk(req.params.id);
    if (!producto) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }
    await producto.update(req.body);
    res.json(producto);
  } catch (error) {
    res.status(400).json({ error: 'Error al actualizar producto', detalle: error.message });
  }
};


exports.eliminarProducto = async (req, res) => {
  try {
    const producto = await Producto.findByPk(req.params.id);
    if (!producto) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }
    await producto.destroy();
    res.json({ mensaje: 'Producto eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar producto', detalle: error.message });
  }
};
