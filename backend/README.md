# Backend - FoodChain Manager

API REST para la gestión de la cadena de suministro de productos lácteos.

## 🏗️ Estructura

```
src/
├── app.js              # Punto de entrada principal
├── config/
│   └── db.js           # Conexión a base de datos (Sequelize)
├── models/             # Modelos de datos (aún por desarrollar)
├── routes/             # Definición de endpoints
├── controllers/        # Lógica de negocio
└── middleware/         # Validaciones y seguridad
```

## ⚙️ Variables de entorno

Crea un archivo `.env` en la raíz del backend con:

```env
PORT=3000
DB_NAME=foodchain_db
DB_USER=admin_foodchain
DB_PASS=tu_contraseña_segura
DB_HOST=localhost
DB_PORT=5432
NODE_ENV=development
```

Ver `.env.example` para más detalles.

## 🚀 Instalación

```bash
npm install
```

## 📝 Comandos

| Comando | Descripción |
|---------|------------|
| `npm start` | Inicia el servidor (si está configurado en `package.json`) |
| `node src/app.js` | Ejecuta el servidor directamente |
| `npm test` | Ejecuta tests (cuando estén disponibles) |

## 🔌 Conexión a la Base de Datos

El backend usa **Sequelize** como ORM y **PostgreSQL** como base de datos.

**Requisitos:**
- PostgreSQL 14+ corriendo en `localhost:5432`
- Base de datos `foodchain_db` creada

**Verificar conexión:**
```bash
node src/app.js
```
Si ves ✅ "¡Conectado a PostgreSQL con éxito!" → está funcionando.

## 🐳 Con Docker (opcional)

Si prefieres PostgreSQL en Docker, usa:

```bash
cd ..
docker-compose up -d
```

Esto inicia PostgreSQL automáticamente con las variables del `.env`.

## 📚 Próximos pasos

- [ ] Crear modelos de datos (Terceros, Productos, Transacciones)
- [ ] Implementar rutas y controladores
- [ ] Agregar validaciones y middleware
- [ ] Tests unitarios
- [ ] Documentación de endpoints con Swagger/OpenAPI
