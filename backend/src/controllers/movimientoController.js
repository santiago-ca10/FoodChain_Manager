const Movimiento = require('../models/Movimiento');
const Producto = require('../models/Producto');

exports.obtenerMovimientos = async (req, res) => {
  try {
    const movimientos = await Movimiento.findAll({
      include: [Producto] // opcional, pero pro 🔥
    });
    res.json(movimientos);
  } catch (error) {
    res.status(500).json({ 
      error: 'Error al obtener movimientos', 
      detalle: error.message 
    });
  }
};

exports.registrarMovimiento = async (req, res) => {
  const { tipo, cantidad, productoId, terceroId, precio_unitario } = req.body;
  
  try {
    // 1. Buscamos el producto para ver su stock
    const producto = await Producto.findByPk(productoId);
    if (!producto) return res.status(404).json({ error: 'Producto no encontrado' });

    // 2. Calculamos el nuevo stock
    let nuevoStock = parseFloat(producto.stock_actual);
    const cant = parseFloat(cantidad);

    if (tipo === 'compra') {
      nuevoStock += cant;
    } else if (tipo === 'venta') {
      if (nuevoStock < cant) return res.status(400).json({ error: 'Stock insuficiente' });
      nuevoStock -= cant;
    }

    // 3. Guardamos el movimiento y actualizamos el producto
    const total = cant * parseFloat(precio_unitario);
    const movimiento = await Movimiento.create({ ...req.body, total });
    
    await producto.update({ stock_actual: nuevoStock });

    res.status(201).json({ movimiento, stock_actualizado: nuevoStock });
  } catch (error) {
    res.status(500).json({ error: 'Error en la transacción', detalle: error.message });
  }
};