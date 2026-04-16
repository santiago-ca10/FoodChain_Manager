const Movimiento = require('../models/Movimiento');
const Producto = require('../models/Producto');
const Tercero = require('../models/Tercero');

/**
 * Registra un movimiento de inventario (Compra o Venta).
 * Actualiza automáticamente el stock del producto involucrado.
 */
exports.registrarMovimiento = async (req, res) => {
  const { tipo, cantidad, productoId, terceroId, precio_unitario } = req.body;
  
  try {
    // 1. Validar existencia del producto
    const producto = await Producto.findByPk(productoId);
    if (!producto) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    // 2. Lógica de Stock
    let nuevoStock = parseFloat(producto.stock_actual);
    const cant = parseFloat(cantidad);

    if (tipo === 'compra') {
      nuevoStock += cant;
    } else if (tipo === 'venta') {
      if (nuevoStock < cant) {
        return res.status(400).json({ error: 'Stock insuficiente para la venta' });
      }
      nuevoStock -= cant;
    }

    // 3. Crear movimiento y actualizar producto en la DB
    const total = cant * parseFloat(precio_unitario);
    const movimiento = await Movimiento.create({ 
      ...req.body, 
      total 
    });
    
    await producto.update({ stock_actual: nuevoStock });

    res.status(201).json({ 
      mensaje: 'Movimiento registrado con éxito',
      movimiento, 
      stock_actualizado: nuevoStock 
    });
  } catch (error) {
    res.status(500).json({ 
      error: 'Error en la transacción', 
      detalle: error.message 
    });
  }
};

/**
 * Obtiene el historial completo de movimientos.
 * Incluye información detallada del Producto y el Tercero.
 */
exports.obtenerHistorial = async (req, res) => {
  try {
    const historial = await Movimiento.findAll({
      include: [
        { 
          model: Producto, 
          attributes: ['nombre', 'unidad_medida', 'categoria'] 
        },
        { 
          model: Tercero, 
          attributes: ['nombre', 'tipo'] 
        }
      ],
      order: [['createdAt', 'DESC']] // Los más recientes primero
    });
    res.json(historial);
  } catch (error) {
    res.status(500).json({ 
      error: 'Error al obtener el historial', 
      detalle: error.message 
    });
  }
};