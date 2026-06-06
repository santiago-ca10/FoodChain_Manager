# FoodChain Manager

Sistema de gestión de inventarios, compras y ventas para el sector lácteo y alimentario. Arquitectura desacoplada con API REST en Node.js y aplicación móvil en Flutter.

## Estructura del proyecto

```
FoodChain Manager/
├── backend/          # API REST (Node.js + Express + Sequelize + PostgreSQL)
├── mobile/           # App Flutter (Android, iOS, Web, Windows)
├── docker-compose.yml
├── .env.example
└── .gitignore
```

## Requisitos

- Node.js 18+
- PostgreSQL 14+ (o Docker Desktop)
- Flutter SDK 3.x+
- Git

## Inicio rápido

### 1. Clonar el repositorio

```bash
git clone https://github.com/santiago-ca10/FoodChain_Manager.git
cd FoodChain_Manager
```

### 2. Levantar la base de datos

**Con Docker (recomendado):**
```bash
docker-compose up -d
```

**Con PostgreSQL local:** crear la base de datos manualmente y configurar `.env`.

### 3. Iniciar el backend

```bash
cd backend
npm install
cp .env.example .env   # completar con tus credenciales
node src/app.js
```

El servidor queda corriendo en `http://localhost:3000`.

### 4. Correr la app Flutter

```bash
cd mobile
flutter pub get
flutter run
```

> Editar `mobile/lib/config/app_config.dart` con la IP del servidor antes de correr.

## Variables de entorno

Crear `backend/.env` basado en `.env.example`:

```env
PORT=3000
DB_NAME=foodchain_db
DB_USER=admin_foodchain
DB_PASS=tu_contraseña
DB_HOST=localhost        # usar 'postgres' si corres con Docker
DB_PORT=5432
NODE_ENV=development
```

## Comandos útiles

```bash
# Docker
docker-compose up -d       # iniciar PostgreSQL en background
docker-compose logs -f     # ver logs
docker-compose down        # detener

# Backend
node src/app.js            # iniciar servidor

# Flutter
flutter run                # correr en dispositivo/emulador conectado
flutter run -d chrome      # correr en navegador
flutter run -d windows     # correr en Windows
```

## Arquitectura

```
Flutter App
    │
    │  HTTP (JSON)
    ▼
Express API  ──── Sequelize ORM ──── PostgreSQL
```

- Los IDs son **UUID v4** en todos los modelos, lo que permite generación offline sin colisiones.
- Los movimientos de inventario usan **transacciones atómicas**: el registro del movimiento y la actualización del stock ocurren juntos o ninguno.
- Los movimientos son **inmutables** (no tienen PUT): actúan como historial contable. Para corregir uno se elimina (con reversión automática de stock) y se vuelve a registrar.

## Recursos

- [Backend — endpoints y modelos](./backend/README.md)
- [Mobile — pantallas y patrones](./mobile/README.md)

## Estado del proyecto

- [x] Backend completo: Terceros, Productos, Movimientos (CRUD + transacciones)
- [x] Flutter: navegación, pantallas de lista y formularios para los tres recursos
- [ ] Autenticación y roles de usuario
- [ ] Soporte offline (SQLite + sincronización)
- [ ] Documentación de API (Swagger/Postman)
