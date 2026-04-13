const express = require('express');
const sequelize = require('./config/db');

const app = express();
app.use(express.json());

// Probar conexión a la base de datos
async function testDB() {
  try {
    await sequelize.authenticate();
    console.log('✅ ¡Conectado a PostgreSQL con éxito!');
  } catch (error) {
    console.error('❌ Error conectando a la DB:', error);
  }
}

testDB();

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});