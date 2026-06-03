const Movimiento = require('../models/Movimiento');
const Producto = require('../models/Producto');
const Tercero = require('../models/Tercero');
const sequelize = require('../config/db'); 

exports.registrarMovimiento = async (req, res) => {
  const { tipo, cantidad, productoId, terceroId, precio_unitario } = req.body;

  
  const t = await sequelize.transaction();

  try {
    const producto = await Producto.findByPk(productoId, { transaction: t });
    if (!producto) {
      await t.rollback(); 
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    let nuevoStock = parseFloat(producto.stock_actual);
    const cant = parseFloat(cantidad);

    if (tipo === 'compra') {
      nuevoStock += cant;
    } else if (tipo === 'venta') {
      if (nuevoStock < cant) {
        await t.rollback();
        return res.status(400).json({ error: 'Stock insuficiente para la venta' });
      }
      nuevoStock -= cant;
    }

    const total = cant * parseFloat(precio_unitario);

    
    const movimiento = await Movimiento.create(
      { ...req.body, total },
      { transaction: t }
    );

    await producto.update(
      { stock_actual: nuevoStock },
      { transaction: t }
    );

    
    await t.commit();

    res.status(201).json({
      mensaje: 'Movimiento registrado con éxito',
      movimiento,
      stock_actualizado: nuevoStock,
    });
  } catch (error) {
    
    await t.rollback();
    res.status(500).json({
      error: 'Error en la transacción',
      detalle: error.message,
    });
  }
};

exports.obtenerHistorial = async (req, res) => {
  try {
    const historial = await Movimiento.findAll({
      include: [
        { model: Producto, attributes: ['nombre', 'unidad_medida', 'categoria'] },
        { model: Tercero, attributes: ['nombre', 'tipo'] },
      ],
      order: [['createdAt', 'DESC']],
    });
    res.json(historial);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener el historial', detalle: error.message });
  }
};


exports.eliminarMovimiento = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const movimiento = await Movimiento.findByPk(req.params.id, { transaction: t });
    if (!movimiento) {
      await t.rollback();
      return res.status(404).json({ error: 'Movimiento no encontrado' });
    }

    const producto = await Producto.findByPk(movimiento.productoId, { transaction: t });
    if (producto) {
      // Revertimos el efecto que tuvo este movimiento en el stock
      let stockRevertido = parseFloat(producto.stock_actual);
      if (movimiento.tipo === 'compra') {
        stockRevertido -= parseFloat(movimiento.cantidad);
      } else if (movimiento.tipo === 'venta') {
        stockRevertido += parseFloat(movimiento.cantidad);
      }
      await producto.update({ stock_actual: stockRevertido }, { transaction: t });
    }

    await movimiento.destroy({ transaction: t });
    await t.commit();

    res.json({ mensaje: 'Movimiento eliminado y stock revertido correctamente' });
  } catch (error) {
    await t.rollback();
    res.status(500).json({ error: 'Error al eliminar movimiento', detalle: error.message });
  }
};
