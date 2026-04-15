const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Producto = sequelize.define('Producto', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  nombre: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  categoria: {
    type: DataTypes.STRING, // Ejemplo: 'Lácteo', 'Insumo', 'Herramienta'
  },
  unidad_medida: {
    type: DataTypes.STRING, // Ejemplo: 'Litros', 'Kilos', 'Unidades'
    allowNull: false,
  },
  precio_sugerido: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0.0,
  },
  stock_actual: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0.0,
  }
}, {
  timestamps: true,
});

module.exports = Producto;