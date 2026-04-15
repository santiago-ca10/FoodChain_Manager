# Backend - FoodChain Manager

API REST para la gestión de la cadena de suministro de productos lácteos.

## Descripción 

Este backend permite gestionar los actores (terceros), productos y transacciones dentro de la cadena de suministro, utilizando una arquitectura modular basada en:

Node.js + Express
Sequelize (ORM)
PostgreSQL

## 🏗️ Estructura

src/
├── app.js                 # Punto de entrada principal
├── config/
│   └── db.js              # Configuración de Sequelize (PostgreSQL)
├── models/
│   ├── Tercero.js         # Clientes y Proveedores (UUID)
│   └── Producto.js        # Catálogo de productos e insumos
├── controllers/
│   ├── terceroController.js
│   └── productoController.js
├── routes/
│   ├── terceroRoutes.js
│   └── productoRoutes.js
└── middleware/            # Próximamente: Seguridad y Validaciones


## 📦 Módulo implementado
#### 👤 1. Terceros

Gestión de actores comerciales (Proveedores, Clientes, Distribuidores).

Endpoint: `/api/terceros`

Identificador: UUID (Optimizado para sincronización offline).

#### 🧀 2. Productos

Catálogo maestro de productos lácteos, insumos y herramientas.

Endpoint: `/api/productos`

Atributos: Stock actual, unidad de medida, precio sugerido.

⚠️ Documentación detallada de endpoints pendiente (Swagger próximamente)


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

✅ Conexión a base de datos PostgreSQL vía Docker
✅ Estructura base del proyecto
✅ Módulo de terceros (CRUD inicial)
✅ Módulo de Productos (CRUD inicial).
✅ Arquitectura base (MVC)


### 📚 Próximos pasos

- [ ] Transacciones (Compras y Ventas)
- [ ] Lógica del inventario Automatico
- [ ] Manejo de errores centralizado
- [ ] Autenticación (JWT)
- [ ] Implementar rutas y controladores
- [ ] Agregar validaciones y middleware
- [ ] Tests unitarios
- [ ] Documentación de endpoints con Swagger/OpenAPI
