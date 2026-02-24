# Guía de Despliegue en VPS (Plesk)

Esta guía detalla cómo desplegar **EventosApp** en un VPS utilizando Docker y la integración de Docker en Plesk.

## 1. Preparación de Variables de Entorno

No utilizaremos archivos `.env` en el servidor por seguridad. En su lugar, configuraremos las variables directamente en la interfaz de Plesk para el contenedor de **Backend**.

### Variables Críticas (Backend)

- `DATABASE_URL`: `postgres://user:password@db:5432/eventosapp`
- `JWT_SECRET`: Una cadena aleatoria larga.
- `STRIPE_SECRET_KEY`: Tu clave secreta definitiva (`sk_live_...`).
- `STRIPE_WEBHOOK_SECRET`: El secreto del webhook de Stripe (lo obtienes al configurar el endpoint en Stripe).
- `STRIPE_PRO_PRICE_ID`: El ID del precio definitivo en Stripe.
- `CORS_ALLOWED_ORIGINS`: La URL de tu aplicación (ej: `https://app.tu-dominio.com`).

## 2. Configuración en Plesk con Docker

1. **Subir el código**: Sube todo el repositorio a tu VPS (vía Git o FTP).
2. **Extensión Docker**: Asegúrate de tener activa la extensión "Docker" en Plesk.
3. **Docker Compose**:
   - Plesk permite ejecutar Docker Compose. Sube el archivo `docker-compose.yml` que se encuentra en la raíz.
   - Ejecuta `docker-compose up -d --build` desde la terminal del VPS o mediante la interfaz si tu versión de Plesk lo soporta.

## 3. Configuración del Frontend (Build Time)

Debido a que React es una SPA, la URL del backend se inyecta en el momento de la "compilación" del contenedor.

- En el `docker-compose.yml`, localiza la sección `frontend -> build -> args`.
- Cambia `VITE_API_URL` por la URL real de tu API (ej: `https://api.tu-dominio.com/api`).

## 4. Reverse Proxy y SSL (Plesk)

Una vez que los contenedores estén corriendo:

1. Crea dos dominios/subdominios en Plesk:
   - `app.tu-dominio.com` (Para el Frontend)
   - `api.tu-dominio.com` (Para el Backend)
2. Activa **Let's Encrypt** (SSL) para ambos.
3. Configura el **Proxy Inverso** en cada dominio:
   - Para el **Frontend**: Apunta al puerto `80` del contenedor `eventosapp-frontend`.
   - Para el **Backend**: Apunta al puerto `8080` del contenedor `eventosapp-backend`.

## 5. Stripe Live (Definitivo)

1. Ve a tu panel de Stripe y desactiva el "Test Mode".
2. Obtén las claves de producción.
3. Configura el Webhook en Stripe apuntando a `https://api.tu-dominio.com/api/webhooks/stripe`.
4. Copia el `Signing Secret` del webhook y ponlo en la variable `STRIPE_WEBHOOK_SECRET` en Plesk.

---

> [!IMPORTANT]
> Recuerda que cualquier cambio en las variables de entorno dentro de Plesk requiere reiniciar el contenedor correspondiente para que surtan efecto.
