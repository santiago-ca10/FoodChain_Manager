# FoodChain Manager — Backend

API REST para gestión de inventarios, compras y ventas del sector lácteo y alimentario.

## Stack

- **Runtime:** Node.js 18+
- **Framework:** Express
- **ORM:** Sequelize
- **Base de datos:** PostgreSQL 14+
- **IDs:** UUID v4 (generados por el servidor)

## Estructura

```
backend/
├── src/
│   ├── config/
│   │   └── db.js               # Conexión Sequelize + PostgreSQL
│   ├── controllers/
│   │   ├── terceroController.js
│   │   ├── productoController.js
│   │   └── movimientoController.js
│   ├── models/
│   │   ├── Tercero.js
│   │   ├── Producto.js
│   │   └── Movimiento.js
│   ├── routes/
│   │   ├── terceroRoutes.js
│   │   ├── productoRoutes.js
│   │   └── movimientoRoutes.js
│   └── app.js
├── .env
├── .env.example
└── package.json
```

## Instalación

```bash
cd backend
npm install
cp .env.example .env   # completar credenciales
node src/app.js
```

### Con Docker

```bash
# desde la raíz del proyecto
docker-compose up -d   # levanta PostgreSQL
cd backend
npm install
node src/app.js
```

## Variables de entorno

```env
PORT=3000
DB_NAME=foodchain_db
DB_USER=admin_foodchain
DB_PASS=tu_contraseña
DB_HOST=localhost        # 'postgres' si usas Docker
DB_PORT=5432
NODE_ENV=development
```

## Modelos

### Tercero

| Campo       | Tipo            | Notas                              |
|-------------|-----------------|-------------------------------------|
| `id`        | UUID (PK)       | Generado automáticamente (UUIDV4)  |
| `nombre`    | STRING          | Requerido                          |
| `tipo`      | ENUM            | `'cliente'`, `'proveedor'`, `'ambos'` |
| `telefono`  | STRING          | Opcional                           |
| `direccion` | STRING          | Opcional                           |
| `last_sync` | DATE            | Para soporte offline futuro        |

### Producto

| Campo            | Tipo          | Notas                              |
|------------------|---------------|-------------------------------------|
| `id`             | UUID (PK)     | Generado automáticamente (UUIDV4)  |
| `nombre`         | STRING        | Requerido                          |
| `categoria`      | STRING        | Opcional. Ej: `'Lácteo'`, `'Insumo'` |
| `unidad_medida`  | STRING        | Requerido. Ej: `'Litros'`, `'Kilos'` |
| `precio_sugerido`| DECIMAL(10,2) | Default 0.0                        |
| `stock_actual`   | DECIMAL(10,2) | Actualizado automáticamente        |

### Movimiento

| Campo            | Tipo          | Notas                              |
|------------------|---------------|-------------------------------------|
| `id`             | UUID (PK)     | Generado automáticamente (UUIDV4)  |
| `tipo`           | ENUM          | `'compra'` o `'venta'`             |
| `cantidad`       | DECIMAL(10,2) | Requerido                          |
| `precio_unitario`| DECIMAL(10,2) | Requerido                          |
| `total`          | DECIMAL(10,2) | Calculado: `cantidad × precio_unitario` |
| `fecha`          | DATE          | Default: ahora                     |
| `productoId`     | UUID (FK)     | Referencia a Producto              |
| `terceroId`      | UUID (FK)     | Referencia a Tercero               |

## Endpoints

### Terceros `/api/terceros`

| Método   | Ruta         | Descripción          |
|----------|--------------|----------------------|
| `GET`    | `/`          | Listar todos         |
| `POST`   | `/`          | Crear tercero        |
| `PUT`    | `/:id`       | Actualizar tercero   |
| `DELETE` | `/:id`       | Eliminar tercero     |

**POST/PUT body:**
```json
{
  "nombre": "Santy Lácteos S.A.",
  "tipo": "proveedor",
  "telefono": "3001234567",
  "direccion": "Vereda El Rosal"
}
```

---

### Productos `/api/productos`

| Método   | Ruta         | Descripción          |
|----------|--------------|----------------------|
| `GET`    | `/`          | Listar todos         |
| `POST`   | `/`          | Crear producto       |
| `PUT`    | `/:id`       | Actualizar producto  |
| `DELETE` | `/:id`       | Eliminar producto    |

**POST/PUT body:**
```json
{
  "nombre": "Leche entera",
  "categoria": "Lácteo",
  "unidad_medida": "Litros",
  "precio_sugerido": 2500.00,
  "stock_actual": 100.0
}
```

---

### Movimientos `/api/movimientos`

| Método   | Ruta         | Descripción                              |
|----------|--------------|------------------------------------------|
| `GET`    | `/`          | Historial completo (con Producto y Tercero incluidos) |
| `POST`   | `/`          | Registrar movimiento (actualiza stock atómicamente) |
| `DELETE` | `/:id`       | Eliminar y revertir stock automáticamente |

> ⚠️ No existe `PUT` para movimientos. Son registros de auditoría inmutables; para corregir se elimina y se vuelve a registrar.

**POST body:**
```json
{
  "tipo": "compra",
  "cantidad": 50.0,
  "precio_unitario": 2300.00,
  "productoId": "uuid-del-producto",
  "terceroId": "uuid-del-tercero"
}
```

**POST response 201:**
```json
{
  "mensaje": "Movimiento registrado con éxito",
  "movimiento": { ... },
  "stock_actualizado": 150.0
}
```

**Lógica de stock (transacción atómica):**
- `compra` → `stock_actual += cantidad`
- `venta` → `stock_actual -= cantidad` (falla con 400 si stock insuficiente)
- `DELETE` → revierte el efecto: compra descuenta, venta suma

## Decisiones de diseño

- **UUIDs:** permiten que el cliente móvil genere IDs offline sin colisiones al sincronizar.
- **Transacciones atómicas en movimientos:** la creación del movimiento y la actualización del stock ocurren juntas o ninguna.
- **Movimientos inmutables:** solo se pueden eliminar (con reversión de stock), nunca editar, para mantener integridad del historial contable.