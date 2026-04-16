const express = require('express');
const sequelize = require('./config/db');

// --- Importación de Modelos ---
// Importarlos aquí asegura que Sequelize los conozca antes de sincronizar
const Tercero = require('./models/Tercero');
const Producto = require('./models/Producto'); 
const Movimiento = require('./models/Movimiento');

// --- Importación de Rutas ---
const terceroRoutes = require('./routes/terceroRoutes');
const productoRoutes = require('./routes/productoRoutes');
const movimientoRoutes = require('./routes/movimientoRoutes');

const app = express();

// Middleware para entender JSON
app.use(express.json());

// --- Definición de Rutas API ---
app.use('/api/terceros', terceroRoutes);
app.use('/api/productos', productoRoutes);
app.use('/api/movimientos', movimientoRoutes); 

// --- Conexión y Sincronización ---
async function startDatabase() {
  try {
    await sequelize.authenticate();
    console.log('✅ ¡Conectado a PostgreSQL!');
    
    // alter: true actualiza las tablas si agregas campos nuevos sin borrar los datos
    await sequelize.sync({ alter: true }); 
    console.log('✅ Tablas sincronizadas y relaciones creadas');
  } catch (error) {
    console.error('❌ Error conectando a la DB:', error);
  }
}

startDatabase();

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});

