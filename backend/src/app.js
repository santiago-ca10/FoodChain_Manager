const express = require('express');
const cors = require('cors');
const sequelize = require('./config/db');

// --- Importación de Modelos ---
// Importarlos aquí asegura que Sequelize los conozca antes de sincronizar
const Tercero = require('./models/Tercero');
const Producto = require('./models/Producto'); 
const Movimiento = require('./models/Movimiento');

// --- Importación de Middleware ---
const verificarToken = require('./middleware/authMiddleware');

// --- Importación de Rutas ---
const authRoutes = require('./routes/authRoutes');
const terceroRoutes = require('./routes/terceroRoutes');
const productoRoutes = require('./routes/productoRoutes');
const movimientoRoutes = require('./routes/movimientoRoutes');

const app = express();

// Middleware generales
app.use(cors());
app.use(express.json());

// ===============================
// RUTAS DE LA API
// ===============================

// Login y registro (públicas)
app.use('/api/auth', authRoutes);

// Rutas protegidas con JWT
app.use('/api/terceros', verificarToken, terceroRoutes);
app.use('/api/productos', verificarToken, productoRoutes);
app.use('/api/movimientos', verificarToken, movimientoRoutes);


// ===============================
// CONEXIÓN Y SINCRONIZACIÓN DB
// ===============================

async function startDatabase() {
  try {
    await sequelize.authenticate();
    console.log('✅ ¡Conectado a PostgreSQL!');

    // Actualiza tablas sin borrar datos
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
