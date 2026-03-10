# Arquitectura del Sistema

Solennix es una plataforma SaaS diseñada para organizadores de eventos. El sistema sigue una arquitectura de tres capas: Frontend desacoplado, Backend monolítico y Base de Datos Relacional.

## Componentes

### 1. Frontend (Web)

- **Framework:** React 19 con TypeScript ~5.9 y Vite 7.
- **Estilos:** Tailwind CSS 4 con design system premium (tokens semánticos, dark mode OLED).
- **Gestión de Estado:** Contextos de React para Auth y hooks personalizados para lógica de UI.
- **Formularios:** React Hook Form + Zod para validaciones estrictas.
- **Comunicación:** Fetch API con httpOnly cookies hacia el API de Go.
- **Iconos:** Lucide React.
- **PDFs:** jsPDF + jspdf-autotable para generación de documentos.

### 2. Frontend (Mobile)

- **Framework:** React Native 0.83 con Expo SDK 55 (managed workflow).
- **Navegación:** React Navigation 7 (5 bottom tabs + stacks).
- **Estado:** Zustand + React Hook Form + Zod.
- **Almacenamiento seguro:** `expo-secure-store` (Keychain en iOS, EncryptedSharedPreferences en Android).
- **Suscripciones:** RevenueCat (`react-native-purchases`) para In-App Purchases.
- **PDFs:** `expo-print` + `expo-sharing` (HTML → PDF → Share Sheet nativo).
- **Iconos:** `lucide-react-native`.

### 3. Backend (API)

- **Lenguaje:** Go 1.25.
- **Framework:** Chi Router v5 para gestión de rutas ligera.
- **Middleware:** Auth (JWT + httpOnly cookies), Rate Limiting, Security Headers, Logging, CORS.
- **Servicios:** Lógica de negocio encapsulada por entidad (Eventos, Clientes, etc.).
- **Repositorio:** Patrón Repository para abstracción de base de datos.
- **Email:** Resend API para password reset.
- **Pagos:** Stripe (web) + RevenueCat webhooks (mobile).

### 4. Base de Datos

- **Motor:** PostgreSQL 15+.
- **Aislamiento:** Multitenancy lógico basado en `user_id` en todas las tablas principales.
- **Migraciones:** Manejadas por el backend en Go (embebidas con `go:embed`).

## Flujo de Datos

1. El usuario se autentica y recibe un JWT almacenado en httpOnly cookie (web) o SecureStore (mobile).
2. El Frontend envía el JWT automáticamente: vía cookie (web) o header `Authorization: Bearer` (mobile).
3. El Backend valida el JWT y extrae el `userID`.
4. Todas las consultas a la DB se filtran automáticamente por `userID` para asegurar aislamiento.
5. El Frontend renderiza los datos y gestiona los estados de carga/error centralizadamente.

## Herramientas de Desarrollo

- **Testing Web:** Vitest + React Testing Library (783 tests), Playwright (E2E).
- **Testing Mobile:** Jest + React Native Testing Library, Maestro (E2E).
- **Testing Backend:** Go test con testify.
- **Deployment:** Docker Compose + VPS con Plesk/Nginx para reverse proxy y SSL.
