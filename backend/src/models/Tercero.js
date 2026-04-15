const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Tercero = sequelize.define('Tercero', {
  // Usamos UUID para que el celular pueda generar el ID sin internet 
  // y no choque con otros al sincronizar.
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  nombre: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  tipo: {
    type: DataTypes.ENUM('cliente', 'proveedor', 'ambos'),
    allowNull: false,
  },
  telefono: {
    type: DataTypes.STRING,
  },
  direccion: {
    type: DataTypes.STRING,
  },
  // Este campo es clave para tu modo Offline
  last_sync: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  }
}, {
  timestamps: true, // Crea createdAt y updatedAt automáticamente
});

module.exports = Tercero;