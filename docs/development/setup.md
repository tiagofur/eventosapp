# Guía de Instalación y Desarrollo

Sigue estos pasos para configurar el entorno de desarrollo local.

## Prerrequisitos

- **Node.js** (v18+)
- **Go** (1.21+)
- **PostgreSQL** (15+) o una instancia en la nube (ej. Supabase, Neon)

## Configuración del Backend

1. Navega a `backend/`.
2. Copia `.env.example` a `.env` y configura las variables:
   - `DATABASE_URL`: URL de conexión a Postgres.
   - `JWT_SECRET`: Clave aleatoria para firmar tokens.
   - `PORT`: Puerto del servidor (por defecto 8080).
3. Ejecuta el servidor:
   ```bash
   go run cmd/server/main.go
   ```

## Configuración del Frontend (Web)

1. Navega a `web/`.
2. Instala dependencias:
   ```bash
   npm install
   ```
3. Configura el entorno en `.env`:
   - `VITE_API_URL`: URL del backend (ej. `http://localhost:8080/api`).
4. Inicia el servidor de desarrollo:
   ```bash
   npm run dev
   ```

## Workflow de Desarrollo

- **Backend:** Las migraciones se ejecutan automáticamente al iniciar el servidor en `main.go`.
- **Frontend:** Uso de HMR (Hot Module Replacement) para cambios instantáneos.
- **Estilos:** Tailwind CSS se procesa en tiempo real.
