🥛 FoodChain Manager 

Sistema robusto de gestión de inventarios, compras y ventas diseñado para el sector lácteo y escalable a la industria de alimentos en general. Enfoque principal en operación offline para zonas rurales y consistencia de datos.

🏗️ Arquitectura del Proyecto

El proyecto sigue una arquitectura desacoplada para garantizar escalabilidad y mantenimiento:

Backend: API REST construida con Node.js y Express.

Base de Datos: PostgreSQL (Servidor) y SQLite (Móvil).

Móvil: Aplicación híbrida con Flutter (próximamente).

ORM: Sequelize para la gestión de modelos y migraciones.

📂 Estructura de Carpetas

├── 📁 backend         # Lógica de servidor y API
│   ├── 📁 src
│   │   ├── 📁 config      # Conexión a DB y variables de entorno
│   │   ├── 📁 controllers # Lógica de negocio
│   │   ├── 📁 middleware  # Validaciones y seguridad
│   │   ├── 📁 models      # Modelos de datos (Sequelize)
│   │   ├── 📁 routes      # Definición de Endpoints
│   │   └── 📄 app.js      # Punto de entrada
│   └── ...
├── 📁 mobile          # Código fuente de la App móvil (Flutter)
└── 📝 README.md


🚀 Requisitos Técnicos Actuales

Node.js (v18+)

PostgreSQL (v14+) o Docker Desktop

Variables de entorno configuradas en un archivo .env dentro de /backend.

🛠️ Instalación y Configuración

Clonar el repositorio.

Entrar a la carpeta backend: cd backend.

Instalar dependencias: npm install.

Configurar el archivo .env con las credenciales de la base de datos local.

Ejecutar en modo desarrollo: node src/app.js.

📈 Roadmap de Desarrollo

[x] Estructura de carpetas y arquitectura inicial.

[x] Configuración del "Puente" de conexión a Base de Datos.

[ ] Definición de modelos de datos (Terceros, Productos, Transacciones).

[ ] Desarrollo de lógica de "Borrador de Semana".

[ ] Implementación de sincronización Offline-First.