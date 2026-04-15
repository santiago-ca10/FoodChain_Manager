# Backend - FoodChain Manager

API REST para la gestión de la cadena de suministro de productos lácteos.

## Descripción 

Este backend permite gestionar los actores (terceros), productos y transacciones dentro de la cadena de suministro, utilizando una arquitectura modular basada en:

Node.js + Express
Sequelize (ORM)
PostgreSQL

## 🏗️ Estructura

```
src/
├── app.js                 # Punto de entrada principal
├── config/
│   └── db.js              # Configuración de Sequelize
├── models/
│   └── Tercero.js         # Modelo de terceros
├── controllers/
│   └── terceroController.js  # Lógica de negocio
├── routes/
│   └── terceroRoutes.js   # Endpoints de terceros
└── middleware/            # Validaciones y seguridad (pendiente)
```

## 📦 Módulo implementado
👤 Terceros

Primer módulo funcional del sistema.

Permite gestionar entidades como:

Proveedores
Clientes
Distribuidores

Endpoints base:

```
/api/terceros
```

⚠️ Documentación detallada de endpoints pendiente (Swagger próximamente)

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

## 📌 Estado actual

✅ Conexión a base de datos
✅ Estructura base del proyecto
✅ Módulo de terceros (modelo, controlador y rutas)

## 📚 Próximos pasos

- [ ] CRUD completo de terceros
- [ ] Manejo de errores centralizado
- [ ] Autenticación (JWT)
- [ ] Implementar rutas y controladores
- [ ] Agregar validaciones y middleware
- [ ] Tests unitarios
- [ ] Documentación de endpoints con Swagger/OpenAPI
