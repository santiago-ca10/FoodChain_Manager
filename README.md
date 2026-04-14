# FoodChain Manager

Sistema de gestión de inventarios, compras y ventas para el sector lácteo y de alimentos, con foco en operación offline y consistencia de datos.

## ✅ Descripción

FoodChain Manager es una aplicación diseñada para facilitar la gestión de la cadena de suministro de productos lácteos. Su arquitectura desacoplada permite mantener el backend independiente del cliente móvil y escalar con facilidad.

## 📦 Qué incluye

- API REST en Node.js y Express
- Base de datos PostgreSQL para el backend
- Soporte planificado para SQLite en la app móvil
- ORM Sequelize para modelos y migraciones
- Estructura modular de carpetas para mantenimiento fácil

## 🧱 Estructura del proyecto

```text
backend/         # Lógica de servidor y API
  ├── src/
  │   ├── config/      # Conexión a DB y variables de entorno
  │   ├── controllers/ # Lógica de negocio
  │   ├── middleware/  # Validación y seguridad
  │   ├── models/      # Modelos Sequelize
  │   ├── routes/      # Definición de endpoints
  │   └── app.js       # Punto de entrada
mobile/          # Código fuente de la aplicación móvil (Flutter)
```

## ⚙️ Requisitos

- **Node.js** 18+ 
- **PostgreSQL** 14+ (o Docker Desktop con PostgreSQL)
- **Git** para el control de versiones
- Variables de entorno configuradas en `.env`

## 🚀 Instalación rápida

### 1️⃣ Clona el repositorio:

```bash
git clone <url-del-repositorio>
cd FoodChain\ Manager
```

### 2️⃣ Opción A: Con PostgreSQL local

```bash
cd backend
npm install
cp .env.example .env        # Copia el template
# Edita .env con tus credenciales de PostgreSQL
node src/app.js             # Inicia el servidor
```

### 2️⃣ Opción B: Con Docker (más fácil)

```bash
# En la raíz del proyecto
docker-compose up -d        # Inicia PostgreSQL en contenedor
cd backend
npm install
node src/app.js
```

## 📋 Variables de entorno

Crea un archivo `.env` en `backend/` basado en `.env.example`:

```env
PORT=3000
DB_NAME=foodchain_db
DB_USER=admin_foodchain
DB_PASS=tu_contraseña_segura_aqui
DB_HOST=localhost           # o 'postgres' si usas Docker
DB_PORT=5432
NODE_ENV=development
```

## 📌 Notas de seguridad

- ✅ El archivo `.env` está en `.gitignore` → No se sube a GitHub
- ✅ Usa `.env.example` como template para otros desarrolladores
- ⚠️ Cambia la contraseña por defecto (`queseriaXD`) en producción
- ⚠️ Si `.env` se subió antes, limpia el historio con:

```bash
git rm --cached backend/.env
git commit -m "Remove .env from tracking"
```

## 🐳 Comandos útiles con Docker

```bash
docker-compose up -d        # Inicia servicios en background
docker-compose logs -f      # Ver logs en tiempo real
docker-compose down         # Detiene servicios
docker-compose restart      # Reinicia
```

## 📖 Documentación específica

- [Backend README](./backend/README.md) - Estructura, endpoints y desarrollo
- [Variables de entorno](./backend/.env.example) - Todas las variables necesarias

## 📈 Roadmap

- [x] Estructura de carpetas y arquitectura inicial
- [x] Configuración de conexión a base de datos
- [ ] Definición de modelos de datos (Terceros, Productos, Transacciones)
- [ ] Desarrollo de lógica de borrador de semana
- [ ] Implementación de sincronización offline-first

## 📚 Próximos pasos

- Desarrollar la app móvil en Flutter
- Añadir autenticación y roles de usuario
- Crear documentación de endpoints para el API
