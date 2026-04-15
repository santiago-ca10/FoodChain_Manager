const express = require('express');
const sequelize = require('./config/db');
const Tercero = require('./models/Tercero');
const terceroRoutes = require('./routes/terceroRoutes');

const app = express();
app.use(express.json());
app.use('/api/terceros', terceroRoutes);

async function startDatabase() {
  try {
    await sequelize.authenticate();
    console.log('✅ ¡Conectado a PostgreSQL!');
    
    await sequelize.sync({ alter: true }); // Sincroniza modelos con la DB
    console.log('✅ Tablas sincronizadas');
  } catch (error) {
    console.error('❌ Error conectando a la DB:', error);
  }
}

startDatabase();

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});