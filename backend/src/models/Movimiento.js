const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const Tercero = require('./Tercero');
const Producto = require('./Producto');

const Movimiento = sequelize.define('Movimiento', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  tipo: {
    type: DataTypes.ENUM('compra', 'venta'),
    allowNull: false,
  },
  cantidad: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  precio_unitario: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  total: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  fecha: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  }
}, {
  timestamps: true,
});

// Un movimiento pertenece a un Tercero (cliente/proveedor)
Movimiento.belongsTo(Tercero, { foreignKey: 'terceroId' });
// Un movimiento involucra a un Producto
Movimiento.belongsTo(Producto, { foreignKey: 'productoId' });

module.exports = Movimiento;