# Backend - FoodChain Manager

API REST para la gestión de la cadena de suministro de productos lácteos.

## Descripción 

Este backend permite gestionar los actores (terceros), productos y transacciones dentro de la cadena de suministro, utilizando una arquitectura modular diseñada para soportar sincronización offline.

### Stack Tecnológico:

Node.js + Express: Servidor y ruteo.

Sequelize (ORM): Gestión de modelos y relaciones.

PostgreSQL (Docker): Base de datos relacional robusta.

## 🏗️ Estructura

src/
├── app.js                # Punto de entrada y configuración de Express
├── config/
│   └── db.js             # Conexión a Sequelize con soporte para .env
├── models/
│   ├── Tercero.js        # Clientes y Proveedores
│   ├── Producto.js       # Catálogo e Inventario
│   └── Movimiento.js     # Transacciones (Compras/Ventas)
├── controllers/
│   ├── terceroController.js
│   ├── productoController.js
│   └── movimientoController.js
├── routes/
│   ├── terceroRoutes.js
│   ├── productoRoutes.js
│   └── movimientoRoutes.js
└── middleware/           # (Próximamente: Seguridad)


## 📦 Módulo implementado

#### 👤 1. Terceros

Gestión de actores comerciales (Proveedores, Clientes, Distribuidores).

- Endpoint: `/api/terceros`

- Identificador: UUID (Optimizado para sincronización offline).

#### 🧀 2. Productos

Catálogo maestro de productos lácteos, insumos y herramientas.

Endpoint: `/api/productos`

#### 🔄 3. Movimientos e Inventario

Registro de transacciones que afectan el stock en tiempo real.

- Endpoint: `/api/movimientos`

- Lógica: Al registrar una Compra, el stock del producto sube. Al registrar una Venta, el stock baja (valida existencia mínima).

- Relaciones: Vincula un Producto con un Tercero (Proveedor o Cliente).


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
✅ Arquitectura base (MVC)
✅ Modelo de terceros (UUID)
✅ Lógica de Movimientos e Inventario Automático.
✅ Módulo de Productos y catalogo

### 📚 Próximos pasos

- [ ] Transacciones (Compras y Ventas)
- [ ] Lógica del inventario Automatico
- [ ] Manejo de errores centralizado
- [ ] Autenticación (JWT)
- [ ] Implementar rutas y controladores
- [ ] Agregar validaciones y middleware
- [ ] Tests unitarios
- [ ] Documentación de endpoints con Swagger/OpenAPI
