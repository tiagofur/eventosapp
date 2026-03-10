# Guía de Instalación y Desarrollo

Sigue estos pasos para configurar el entorno de desarrollo local.

## Prerrequisitos

- **Node.js** (v20+)
- **Go** (1.25+)
- **PostgreSQL** (15+) — vía Docker o instancia local
- **Docker** y **Docker Compose** (recomendado para la base de datos)

## 1. Base de Datos (Docker)

```bash
# Desde la raíz del proyecto
docker compose up db -d

# Verificar que PostgreSQL está corriendo
docker compose ps
```

> **⚠️ IMPORTANTE:** No modificar `docker-compose.yml` de forma que rompa el deployment de producción. Para desarrollo local, solo levantar el servicio `db`.

## 2. Backend (Go)

1. Navega a `backend/`.
2. Copia `.env.example` a `.env` y configura las variables:
   - `DATABASE_URL`: URL de conexión a Postgres (ej: `postgres://postgres:postgres@localhost:5432/solennix?sslmode=disable`)
   - `JWT_SECRET`: Clave aleatoria de min 32 caracteres (`openssl rand -hex 32`)
   - `PORT`: Puerto del servidor (por defecto 8080)
   - `CORS_ALLOWED_ORIGINS`: `http://localhost:5173` (el puerto de Vite)
   - `FRONTEND_URL`: `http://localhost:5173`
   - `RESEND_API_KEY`: API key de Resend para emails (opcional en dev)
   - `RESEND_FROM_EMAIL`: Email del remitente
3. Ejecuta el servidor:
   ```bash
   go run cmd/server/main.go
   ```
4. Verificar: `curl http://localhost:8080/health` → `{"status":"ok"}`

> Las migraciones se ejecutan automáticamente al iniciar el servidor.

## 3. Frontend Web (React)

1. Navega a `web/`.
2. Instala dependencias:
   ```bash
   npm install
   ```
3. Configura el entorno en `.env`:
   - `VITE_API_URL`: `http://localhost:8080/api`
4. Inicia el servidor de desarrollo:
   ```bash
   npm run dev
   ```
5. Abre `http://localhost:5173` en el navegador.

## 4. App Mobile (React Native / Expo)

1. Navega a `mobile/`.
2. Instala dependencias:
   ```bash
   npm install
   ```
3. Configura `.env`:
   - `EXPO_PUBLIC_API_URL`: `http://192.168.x.x:8080/api` (usa tu IP local, no `localhost`)
4. Inicia Expo:
   ```bash
   npx expo start
   ```
5. Escanea el QR con la app **Expo Go** (Android) o **cámara** (iOS).

> En desarrollo mobile, usa la IP local de tu máquina en lugar de `localhost` porque el emulador/dispositivo no resuelve `localhost` al host.

## Workflow de Desarrollo

- **Backend:** Las migraciones se ejecutan automáticamente al iniciar en `main.go`.
- **Frontend Web:** HMR (Hot Module Replacement) para cambios instantáneos.
- **Estilos:** Tailwind CSS 4 se procesa en tiempo real.
- **Mobile:** Expo Fast Refresh para iteración rápida.
- **Auth:** El backend envía httpOnly cookies (web) y acepta `Authorization: Bearer` headers (mobile).
