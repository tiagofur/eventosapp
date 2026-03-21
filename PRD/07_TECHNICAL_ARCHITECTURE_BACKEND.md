# Arquitectura Técnica — Backend API

**Versión:** 1.0
**Fecha:** 2026-03-20
**Plataforma:** Go REST API + PostgreSQL

---

## 1. Stack Tecnológico

| Componente | Tecnología | Versión | Rol |
|------------|------------|---------|-----|
| **Lenguaje** | Go | 1.24.7 | Rendimiento, concurrencia nativa, binario estático |
| **Router HTTP** | Chi (`go-chi/chi/v5`) | 5.2.5 | Router ligero y compatible con `net/http`, middleware composable |
| **Base de datos** | PostgreSQL | 15 (Alpine) | Base de datos relacional principal, JSONB para datos flexibles |
| **Driver DB** | pgx (`jackc/pgx/v5`) | 5.8.0 | Driver nativo PostgreSQL con connection pooling (`pgxpool`) |
| **Autenticación** | golang-jwt (`golang-jwt/jwt/v5`) | 5.3.1 | Generación y validación de tokens JWT (HS256) |
| **Pagos** | Stripe (`stripe/stripe-go/v81`) | 81.4.0 | Checkout sessions, webhooks, portal de facturación |
| **Email** | Resend (`resend/resend-go/v3`) | 3.1.1 | Emails transaccionales (recuperación de contraseña) |
| **Hashing** | bcrypt (`golang.org/x/crypto`) | 0.48.0 | Hash seguro de contraseñas con cost factor configurable |
| **UUIDs** | google/uuid | 1.6.0 | Identificadores únicos para todas las entidades |
| **Configuración** | godotenv (`joho/godotenv`) | 1.5.1 | Carga de variables de entorno desde archivo `.env` |
| **Imágenes** | golang.org/x/image | 0.36.0 | Redimensionamiento de imágenes para thumbnails |
| **Testing** | testify (`stretchr/testify`) | 1.11.1 | Assertions y mocks para tests unitarios e integración |
| **Contenedor** | Docker (multi-stage) | Alpine | Build y despliegue en contenedor ligero |
| **Logging** | log/slog (stdlib) | — | Logging estructurado nativo de Go |

---

## 2. Arquitectura

### Patrón General

El backend sigue una **arquitectura en capas** inspirada en Clean Architecture, con inyección de dependencias vía constructores y propagación de contexto a través de toda la cadena.

```
┌─────────────────────────────────────────────────────────────────┐
│                        HTTP Request                             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                     Router (Chi)                                │
│  Definición de rutas, agrupación por dominio                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                    Middleware Stack                              │
│  Recovery → CORS → Security Headers → Logger → Auth → RateLimit│
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                      Handlers                                   │
│  Decodificación HTTP, validación, respuesta JSON                │
│  AuthHandler, CRUDHandler, SubscriptionHandler, etc.            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                      Services                                   │
│  Lógica de negocio: AuthService, EmailService                   │
│  JWT, hashing, envío de emails                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                     Repository                                  │
│  Acceso a datos: UserRepo, EventRepo, ClientRepo, etc.          │
│  Queries SQL directas con pgx (sin ORM)                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                    PostgreSQL                                   │
│  pgxpool connection pool (20 max, 2 min)                        │
└─────────────────────────────────────────────────────────────────┘
```

### Principios

- **Sin ORM**: Queries SQL directas con `pgx` para control total y rendimiento
- **Inyección de dependencias**: Todos los componentes reciben dependencias vía constructor (`NewXxxHandler(repo, service)`)
- **Propagación de contexto**: `context.Context` se propaga desde el handler hasta el repositorio para cancelación y timeouts
- **Interfaces para testing**: Los handlers dependen de interfaces (e.g., `FullUserRepository`, `AdminUserRepo`), facilitando mocks en tests
- **Manejo de errores explícito**: Go idiomático — sin excepciones, retorno explícito de `error`
- **Graceful shutdown**: El servidor captura `SIGTERM`/`SIGINT` y drena conexiones activas antes de cerrar

---

## 3. Estructura del Proyecto

```
backend/
├── cmd/
│   └── server/
│       └── main.go                    # Punto de entrada. Configura logging, DB, repos, handlers, router y graceful shutdown
│
├── internal/
│   ├── config/
│   │   ├── config.go                  # Carga de configuración desde variables de entorno (.env)
│   │   └── config_test.go             # Tests de configuración
│   │
│   ├── database/
│   │   ├── database.go                # Conexión a PostgreSQL con pgxpool (pool configurado)
│   │   ├── database_test.go           # Tests de conexión
│   │   ├── migrate.go                 # Sistema de migraciones con go:embed
│   │   ├── migrate_test.go            # Tests de migraciones
│   │   └── migrations/                # Archivos SQL de migración (026 migraciones)
│   │       ├── 001_create_users.up.sql
│   │       ├── 001_create_users.down.sql
│   │       ├── ...
│   │       └── 026_create_device_tokens.up.sql
│   │
│   ├── handlers/
│   │   ├── auth_handler.go            # Registro, login, logout, OAuth, password reset
│   │   ├── crud_handler.go            # CRUD para clients, events, products, inventory, payments
│   │   ├── subscription_handler.go    # Stripe checkout, webhooks, RevenueCat
│   │   ├── search_handler.go          # Búsqueda global multi-entidad
│   │   ├── event_payment_handler.go   # Pagos de eventos vía Stripe
│   │   ├── upload_handler.go          # Subida de imágenes con thumbnails
│   │   ├── admin_handler.go           # Panel de administración (stats, usuarios)
│   │   ├── unavailable_date_handler.go # Gestión de fechas no disponibles
│   │   ├── device_handler.go          # Registro de dispositivos para push notifications
│   │   ├── contract_template.go       # Plantilla de contratos por defecto
│   │   ├── stripe_service.go          # Interfaz del servicio Stripe
│   │   ├── helpers.go                 # Funciones utilitarias (JSON encode/decode, writeError)
│   │   ├── interfaces.go             # Interfaces de repositorios usadas por handlers
│   │   ├── user_repository.go         # Interfaz completa del repositorio de usuario
│   │   ├── validation.go             # Validaciones compartidas
│   │   └── *_test.go                  # Tests unitarios por handler (mocks incluidos)
│   │
│   ├── middleware/
│   │   ├── auth.go                    # Validación JWT (cookie httpOnly + header Authorization)
│   │   ├── admin.go                   # Verificación de rol admin
│   │   ├── cors.go                    # CORS con orígenes configurables
│   │   ├── logging.go                 # Logger de requests (slog estructurado)
│   │   ├── ratelimit.go              # Rate limiting por IP con ventana deslizante
│   │   ├── recovery.go               # Recuperación de panics con stack trace
│   │   ├── security.go               # Headers de seguridad OWASP
│   │   └── *_test.go                  # Tests unitarios por middleware
│   │
│   ├── models/
│   │   └── models.go                  # Todas las estructuras de dominio con JSON tags
│   │
│   ├── repository/
│   │   ├── user_repo.go               # Queries de usuarios
│   │   ├── client_repo.go             # Queries de clientes
│   │   ├── event_repo.go              # Queries de eventos (con joins a client, products, extras)
│   │   ├── product_repo.go            # Queries de productos e ingredientes
│   │   ├── inventory_repo.go          # Queries de inventario
│   │   ├── payment_repo.go            # Queries de pagos
│   │   ├── subscription_repo.go       # Queries de suscripciones
│   │   ├── admin_repo.go              # Queries de administración + expiración de planes gifted
│   │   ├── unavailable_date_repo.go   # Queries de fechas no disponibles
│   │   ├── device_repo.go             # Queries de tokens de dispositivos
│   │   └── *_test.go                  # Tests de integración con DB real
│   │
│   ├── router/
│   │   ├── router.go                  # Definición completa de rutas con Chi
│   │   ├── router_test.go             # Tests de configuración de rutas
│   │   ├── router_api_integration_test.go # Tests de integración API
│   │   └── testdata/                  # Datos de prueba para tests
│   │
│   └── services/
│       ├── auth_service.go            # JWT (generación, validación), bcrypt (hash, verify)
│       ├── auth_service_test.go       # Tests del servicio de auth
│       ├── email_service.go           # Envío de emails con Resend (templates HTML)
│       ├── email_service_test.go      # Tests del servicio de email
│       └── revenuecat_service.go      # Sync Stripe↔RevenueCat (grant/revoke entitlements)
│
├── go.mod                             # Dependencias del módulo Go
├── go.sum                             # Checksums de dependencias
├── Dockerfile                         # Multi-stage build (golang:alpine → alpine)
└── docker-compose.yml                 # PostgreSQL 15 local para desarrollo
```

---

## 4. Modelos de Datos

Todos los modelos se definen en `internal/models/models.go`. Cada struct usa tags `json` para serialización y `json:"-"` para campos sensibles.

### 4.1 Usuarios

#### `User`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `Email` | `string` | `email` | Email del usuario (único) |
| `PasswordHash` | `string` | `-` | Hash bcrypt (nunca se expone en JSON) |
| `Name` | `string` | `name` | Nombre del usuario |
| `BusinessName` | `*string` | `business_name` | Nombre de la empresa (opcional) |
| `LogoURL` | `*string` | `logo_url` | URL del logo (opcional) |
| `BrandColor` | `*string` | `brand_color` | Color de marca personalizado (opcional) |
| `ShowBusinessNameInPdf` | `*bool` | `show_business_name_in_pdf` | Mostrar nombre de empresa en PDFs |
| `DefaultDepositPercent` | `*float64` | `default_deposit_percent` | Porcentaje de anticipo por defecto |
| `DefaultCancellationDays` | `*float64` | `default_cancellation_days` | Días de cancelación por defecto |
| `DefaultRefundPercent` | `*float64` | `default_refund_percent` | Porcentaje de reembolso por defecto |
| `ContractTemplate` | `*string` | `contract_template` | Plantilla HTML de contratos |
| `Plan` | `string` | `plan` | Plan de suscripción (`basic` / `pro`) |
| `Role` | `string` | `role` | Rol del usuario (`user` / `admin`) |
| `StripeCustomerID` | `*string` | `stripe_customer_id` | ID de cliente en Stripe |
| `GoogleUserID` | `*string` | `google_user_id` | ID de usuario Google OAuth |
| `AppleUserID` | `*string` | `apple_user_id` | ID de usuario Apple Sign In |
| `PlanExpiresAt` | `*time.Time` | `plan_expires_at` | Expiración del plan (para planes gifted) |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `UpdatedAt` | `time.Time` | `updated_at` | Fecha de última actualización |

#### Requests de Autenticación (definidas en `auth_handler.go`)
- `registerRequest` — `email`, `password`, `name`
- `loginRequest` — `email`, `password`
- `forgotPasswordRequest` — `email`

### 4.2 Eventos

#### `Event`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `UserID` | `uuid.UUID` | `user_id` | Propietario del evento |
| `ClientID` | `uuid.UUID` | `client_id` | Cliente asociado |
| `EventDate` | `string` | `event_date` | Fecha del evento (`YYYY-MM-DD`) |
| `StartTime` | `*string` | `start_time` | Hora de inicio (opcional) |
| `EndTime` | `*string` | `end_time` | Hora de fin (opcional) |
| `ServiceType` | `string` | `service_type` | Tipo de servicio |
| `NumPeople` | `int` | `num_people` | Número de personas |
| `Status` | `string` | `status` | Estado del evento |
| `Discount` | `float64` | `discount` | Monto/porcentaje de descuento |
| `DiscountType` | `string` | `discount_type` | Tipo: `percent` o `fixed` |
| `RequiresInvoice` | `bool` | `requires_invoice` | Requiere factura |
| `TaxRate` | `float64` | `tax_rate` | Tasa de impuesto |
| `TaxAmount` | `float64` | `tax_amount` | Monto de impuesto |
| `TotalAmount` | `float64` | `total_amount` | Total del evento |
| `Location` | `*string` | `location` | Ubicación (opcional) |
| `City` | `*string` | `city` | Ciudad (opcional) |
| `DepositPercent` | `*float64` | `deposit_percent` | Porcentaje de anticipo |
| `CancellationDays` | `*float64` | `cancellation_days` | Días para cancelación |
| `RefundPercent` | `*float64` | `refund_percent` | Porcentaje de reembolso |
| `Notes` | `*string` | `notes` | Notas (opcional) |
| `Photos` | `*string` | `photos` | URLs de fotos (JSONB como string) |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `UpdatedAt` | `time.Time` | `updated_at` | Fecha de actualización |
| `Client` | `*Client` | `client` | Datos del cliente (joined, opcional) |

#### `EventProduct`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `EventID` | `uuid.UUID` | `event_id` | Evento asociado |
| `ProductID` | `uuid.UUID` | `product_id` | Producto asociado |
| `Quantity` | `float64` | `quantity` | Cantidad |
| `UnitPrice` | `float64` | `unit_price` | Precio unitario |
| `Discount` | `float64` | `discount` | Descuento |
| `TotalPrice` | `float64` | `total_price` | Precio total (columna generada en DB) |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `ProductName` | `*string` | `product_name` | Nombre del producto (joined) |

#### `EventExtra`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `EventID` | `uuid.UUID` | `event_id` | Evento asociado |
| `Description` | `string` | `description` | Descripción del extra |
| `Cost` | `float64` | `cost` | Costo del extra |
| `Price` | `float64` | `price` | Precio al cliente |
| `ExcludeUtility` | `bool` | `exclude_utility` | Excluir del cálculo de utilidad |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |

#### `EventEquipment`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `EventID` | `uuid.UUID` | `event_id` | Evento asociado |
| `InventoryID` | `uuid.UUID` | `inventory_id` | Equipo del inventario |
| `Quantity` | `int` | `quantity` | Cantidad asignada |
| `Notes` | `*string` | `notes` | Notas (opcional) |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `EquipmentName` | `*string` | `equipment_name` | Nombre del equipo (joined) |
| `Unit` | `*string` | `unit` | Unidad de medida (joined) |
| `CurrentStock` | `*float64` | `current_stock` | Stock actual (joined) |

#### `EventSupply`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `EventID` | `uuid.UUID` | `event_id` | Evento asociado |
| `InventoryID` | `uuid.UUID` | `inventory_id` | Insumo del inventario |
| `Quantity` | `float64` | `quantity` | Cantidad |
| `UnitCost` | `float64` | `unit_cost` | Costo unitario |
| `Source` | `string` | `source` | Origen: `stock` o `purchase` |
| `ExcludeCost` | `bool` | `exclude_cost` | Excluir del total del evento |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `SupplyName` | `*string` | `supply_name` | Nombre del insumo (joined) |
| `Unit` | `*string` | `unit` | Unidad (joined) |
| `CurrentStock` | `*float64` | `current_stock` | Stock actual (joined) |

#### `EventPhoto`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `URL` | `string` | `url` | URL de la imagen |
| `ThumbnailURL` | `*string` | `thumbnail_url` | URL del thumbnail (opcional) |
| `Caption` | `*string` | `caption` | Título/descripción (opcional) |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |

#### Modelos auxiliares de eventos
- `EquipmentSuggestion` — Sugerencia automática de equipo con `SuggestedQty` calculado: `ceil(product_qty / capacity)`
- `EquipmentConflict` — Conflicto detectado cuando el mismo equipo está asignado a eventos en la misma fecha
- `SupplySuggestion` — Sugerencia de insumos con cantidad fija por evento (no escalada por cantidad de producto)

### 4.3 Clientes

#### `Client`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `UserID` | `uuid.UUID` | `user_id` | Propietario |
| `Name` | `string` | `name` | Nombre del cliente |
| `Phone` | `string` | `phone` | Teléfono |
| `Email` | `*string` | `email` | Email (opcional) |
| `Address` | `*string` | `address` | Dirección (opcional) |
| `City` | `*string` | `city` | Ciudad (opcional) |
| `Notes` | `*string` | `notes` | Notas (opcional) |
| `PhotoURL` | `*string` | `photo_url` | Foto del cliente (opcional) |
| `TotalEvents` | `int` | `total_events` | Total de eventos (calculado) |
| `TotalSpent` | `float64` | `total_spent` | Total gastado (calculado) |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `UpdatedAt` | `time.Time` | `updated_at` | Fecha de actualización |

### 4.4 Productos

#### `Product`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `UserID` | `uuid.UUID` | `user_id` | Propietario |
| `Name` | `string` | `name` | Nombre del producto |
| `Category` | `string` | `category` | Categoría |
| `BasePrice` | `float64` | `base_price` | Precio base |
| `Recipe` | `*string` | `recipe` | Receta (JSONB como string) |
| `ImageURL` | `*string` | `image_url` | URL de imagen (opcional) |
| `IsActive` | `bool` | `is_active` | Activo/inactivo |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `UpdatedAt` | `time.Time` | `updated_at` | Fecha de actualización |

#### `ProductIngredient`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `ProductID` | `uuid.UUID` | `product_id` | Producto asociado |
| `InventoryID` | `uuid.UUID` | `inventory_id` | Item del inventario |
| `QuantityRequired` | `float64` | `quantity_required` | Cantidad requerida |
| `Capacity` | `*float64` | `capacity` | Capacidad por pieza (solo equipo): `ceil(event_qty / capacity)` |
| `BringToEvent` | `bool` | `bring_to_event` | Transportar al evento |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `IngredientName` | `*string` | `ingredient_name` | Nombre del ingrediente (joined) |
| `Unit` | `*string` | `unit` | Unidad de medida (joined) |
| `UnitCost` | `*float64` | `unit_cost` | Costo unitario (joined) |
| `Type` | `*string` | `type` | Tipo de inventario (joined) |

### 4.5 Inventario

#### `InventoryItem`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `UserID` | `uuid.UUID` | `user_id` | Propietario |
| `IngredientName` | `string` | `ingredient_name` | Nombre del ingrediente/equipo |
| `CurrentStock` | `float64` | `current_stock` | Stock actual |
| `MinimumStock` | `float64` | `minimum_stock` | Stock mínimo (alerta) |
| `Unit` | `string` | `unit` | Unidad de medida |
| `UnitCost` | `*float64` | `unit_cost` | Costo unitario (opcional) |
| `Type` | `string` | `type` | Tipo: `ingredient`, `equipment`, `supply` |
| `LastUpdated` | `time.Time` | `last_updated` | Última actualización |

### 4.6 Pagos

#### `Payment`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `EventID` | `uuid.UUID` | `event_id` | Evento asociado |
| `UserID` | `uuid.UUID` | `user_id` | Propietario |
| `Amount` | `float64` | `amount` | Monto del pago |
| `PaymentDate` | `string` | `payment_date` | Fecha del pago (`YYYY-MM-DD`) |
| `PaymentMethod` | `string` | `payment_method` | Método de pago |
| `Notes` | `*string` | `notes` | Notas (opcional) |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |

### 4.7 Suscripciones

#### `Subscription`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `UserID` | `uuid.UUID` | `user_id` | Usuario suscrito |
| `Provider` | `string` | `provider` | Proveedor: `stripe`, `apple`, `google` |
| `ProviderSubID` | `*string` | `provider_subscription_id` | ID de suscripción del proveedor |
| `RevenueCatAppUserID` | `*string` | `revenuecat_app_user_id` | App User ID de RevenueCat |
| `Plan` | `string` | `plan` | Plan: `basic` o `pro` |
| `Status` | `string` | `status` | Estado: `active`, `past_due`, `canceled`, `trialing` |
| `CurrentPeriodStart` | `*time.Time` | `current_period_start` | Inicio del período actual |
| `CurrentPeriodEnd` | `*time.Time` | `current_period_end` | Fin del período actual |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `UpdatedAt` | `time.Time` | `updated_at` | Fecha de actualización |

### 4.8 Otros

#### `UnavailableDate`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `UserID` | `uuid.UUID` | `user_id` | Propietario |
| `StartDate` | `string` | `start_date` | Fecha de inicio (`YYYY-MM-DD`) |
| `EndDate` | `string` | `end_date` | Fecha de fin (`YYYY-MM-DD`) |
| `Reason` | `*string` | `reason` | Razón (opcional) |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `UpdatedAt` | `time.Time` | `updated_at` | Fecha de actualización |

#### `DeviceToken`
| Campo | Tipo | JSON | Descripción |
|-------|------|------|-------------|
| `ID` | `uuid.UUID` | `id` | Identificador único |
| `UserID` | `uuid.UUID` | `user_id` | Propietario |
| `Token` | `string` | `token` | Token del dispositivo |
| `Platform` | `string` | `platform` | Plataforma: `ios`, `android`, `web` |
| `CreatedAt` | `time.Time` | `created_at` | Fecha de creación |
| `UpdatedAt` | `time.Time` | `updated_at` | Fecha de actualización |

---

## 5. Base de Datos (PostgreSQL)

### 5.1 Conexión

La conexión se establece mediante `pgxpool.Pool` con la siguiente configuración:

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `MaxConns` | 20 | Conexiones máximas en el pool |
| `MinConns` | 2 | Conexiones mínimas mantenidas |
| `MaxConnLifetime` | 30 min | Vida máxima de una conexión |
| `MaxConnIdleTime` | 5 min | Tiempo máximo inactivo antes de cerrar |
| `ConnectTimeout` | 10 seg | Timeout para la conexión inicial |

El pool se inicializa en `database.Connect()` y se verifica con un `Ping()` antes de retornar.

### 5.2 Sistema de Migraciones

El sistema de migraciones es **custom** (sin herramientas externas como `golang-migrate`):

1. **Embedido**: Los archivos SQL se incluyen en el binario usando `go:embed migrations/*.up.sql`
2. **Tabla de control**: `schema_migrations` almacena las versiones aplicadas con timestamp
3. **Ejecución automática**: Se ejecutan al iniciar el servidor (`database.Migrate(pool)`)
4. **Transaccional**: Cada migración se ejecuta en una transacción; si falla, hace rollback
5. **Idempotente**: Solo aplica migraciones que no están en `schema_migrations`
6. **Nomenclatura**: `{NNN}_{descripcion}.up.sql` / `{NNN}_{descripcion}.down.sql`

### 5.3 Migraciones

| # | Archivo | Propósito |
|---|---------|-----------|
| 001 | `create_users` | Tabla principal de usuarios |
| 002 | `create_clients` | Tabla de clientes (`user_id` FK) |
| 003 | `create_events` | Tabla de eventos con todos los campos financieros |
| 004 | `create_products` | Tabla de productos/servicios |
| 005 | `create_inventory` | Tabla de inventario (ingredientes, equipo, insumos) |
| 006 | `create_junction_tables` | Tablas de unión: `event_products`, `event_extras`, `product_ingredients` |
| 007 | `create_payments_subscriptions` | Tablas de pagos y suscripciones |
| 008 | `add_client_logo` | Campo `logo_url` en clientes |
| 009 | `move_logo` | Migración de logo de clients a users |
| 010 | `add_user_brand_color` | Campo `brand_color` en usuarios |
| 011 | `add_show_business_name` | Campo `show_business_name_in_pdf` |
| 012 | `extend_subscriptions` | Campos adicionales de suscripción (provider, RevenueCat) |
| 013 | `fix_plan_constraint` | Corrección de constraint de plan |
| 014 | `add_indexes_and_cascade` | Índices de rendimiento + CASCADE en FKs |
| 015 | `add_image_fields` | Campos de imagen en productos |
| 016 | `create_event_equipment` | Tabla `event_equipment` |
| 017 | `add_contract_template_to_users` | Campo `contract_template` en usuarios |
| 018 | `add_role_to_users` | Campo `role` (user/admin) |
| 019 | `add_plan_expires_at` | Campo `plan_expires_at` para planes gifted |
| 020a | `add_discount_type_to_events` | Campo `discount_type` (percent/fixed) |
| 020b | `add_equipment_capacity` | Campo `capacity` en `product_ingredients` |
| 021 | `add_bring_to_event` | Campo `bring_to_event` en `product_ingredients` |
| 022 | `create_unavailable_dates` | Tabla de fechas no disponibles |
| 023 | `add_supply_type_and_table` | Tipo `supply` en inventario + tabla `event_supplies` |
| 024 | `add_exclude_cost_to_event_supplies` | Campo `exclude_cost` en `event_supplies` |
| 025 | `add_oauth_user_ids` | Campos `google_user_id` y `apple_user_id` |
| 026 | `create_device_tokens` | Tabla de tokens de dispositivo para push |

### 5.4 Relaciones Principales

```
users ──1:N──> clients
users ──1:N──> events
users ──1:N──> products
users ──1:N──> inventory_items
users ──1:N──> payments
users ──1:N──> subscriptions
users ──1:N──> unavailable_dates
users ──1:N──> device_tokens

clients ──1:N──> events

events ──1:N──> event_products ──N:1──> products
events ──1:N──> event_extras
events ──1:N──> event_equipment ──N:1──> inventory_items
events ──1:N──> event_supplies ──N:1──> inventory_items
events ──1:N──> payments

products ──1:N──> product_ingredients ──N:1──> inventory_items
```

Todas las entidades principales se filtran por `user_id` (multi-tenant por usuario). Los CASCADE DELETE se aplican en las tablas de unión para mantener integridad referencial.

---

## 6. API — Rutas Completas

### 6.1 Health Check

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/health` | inline | Retorna `{"status":"ok"}` |

### 6.2 Rutas Públicas — Autenticación

Rate limit: **10 requests/minuto** por IP.

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `POST` | `/api/auth/register` | `AuthHandler.Register` | Registro de nuevo usuario |
| `POST` | `/api/auth/login` | `AuthHandler.Login` | Login con email/password |
| `POST` | `/api/auth/logout` | `AuthHandler.Logout` | Logout (limpia cookie httpOnly) |
| `POST` | `/api/auth/refresh` | `AuthHandler.RefreshToken` | Renovar access token con refresh token |
| `POST` | `/api/auth/forgot-password` | `AuthHandler.ForgotPassword` | Solicitar email de recuperación |
| `POST` | `/api/auth/reset-password` | `AuthHandler.ResetPassword` | Restablecer contraseña con token |
| `POST` | `/api/auth/google` | `AuthHandler.GoogleSignIn` | Login/registro con Google OAuth |
| `POST` | `/api/auth/apple` | `AuthHandler.AppleSignIn` | Login/registro con Apple Sign In |

### 6.3 Rutas Protegidas — Auth (requiere JWT)

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/auth/me` | `AuthHandler.Me` | Obtener perfil del usuario actual |
| `POST` | `/api/auth/change-password` | `AuthHandler.ChangePassword` | Cambiar contraseña |

### 6.4 Rutas Públicas — Webhooks

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `POST` | `/api/subscriptions/webhook/stripe` | `SubscriptionHandler.StripeWebhook` | Webhook de Stripe (verificado por firma) |
| `POST` | `/api/subscriptions/webhook/revenuecat` | `SubscriptionHandler.RevenueCatWebhook` | Webhook de RevenueCat (verificado por header) |

### 6.5 Rutas Públicas — Archivos

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/uploads/*` | `http.FileServer` | Servir archivos subidos (cache 1 año) |

### 6.6 Rutas Protegidas — Usuarios

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `PUT` | `/api/users/me` | `AuthHandler.UpdateProfile` | Actualizar perfil del usuario |

### 6.7 Rutas Protegidas — Clientes

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/clients` | `CRUDHandler.ListClients` | Listar clientes del usuario |
| `POST` | `/api/clients` | `CRUDHandler.CreateClient` | Crear cliente |
| `GET` | `/api/clients/{id}` | `CRUDHandler.GetClient` | Obtener cliente por ID |
| `PUT` | `/api/clients/{id}` | `CRUDHandler.UpdateClient` | Actualizar cliente |
| `DELETE` | `/api/clients/{id}` | `CRUDHandler.DeleteClient` | Eliminar cliente |

### 6.8 Rutas Protegidas — Eventos

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/events` | `CRUDHandler.ListEvents` | Listar eventos del usuario |
| `GET` | `/api/events/upcoming` | `CRUDHandler.GetUpcomingEvents` | Eventos próximos |
| `POST` | `/api/events` | `CRUDHandler.CreateEvent` | Crear evento |
| `GET` | `/api/events/{id}` | `CRUDHandler.GetEvent` | Obtener evento con datos del cliente |
| `PUT` | `/api/events/{id}` | `CRUDHandler.UpdateEvent` | Actualizar evento |
| `DELETE` | `/api/events/{id}` | `CRUDHandler.DeleteEvent` | Eliminar evento |
| `GET` | `/api/events/{id}/products` | `CRUDHandler.GetEventProducts` | Productos del evento |
| `GET` | `/api/events/{id}/extras` | `CRUDHandler.GetEventExtras` | Extras del evento |
| `PUT` | `/api/events/{id}/items` | `CRUDHandler.UpdateEventItems` | Actualizar productos, extras, equipo e insumos del evento |
| `GET` | `/api/events/{id}/equipment` | `CRUDHandler.GetEventEquipment` | Equipo asignado al evento |
| `GET` | `/api/events/{id}/supplies` | `CRUDHandler.GetEventSupplies` | Insumos del evento |
| `GET` | `/api/events/{id}/photos` | `CRUDHandler.GetEventPhotos` | Fotos del evento |
| `POST` | `/api/events/{id}/photos` | `CRUDHandler.AddEventPhoto` | Agregar foto al evento |
| `DELETE` | `/api/events/{id}/photos/{photoId}` | `CRUDHandler.DeleteEventPhoto` | Eliminar foto del evento |
| `GET` | `/api/events/equipment/conflicts` | `CRUDHandler.CheckEquipmentConflictsGET` | Detectar conflictos de equipo (GET para mobile) |
| `POST` | `/api/events/equipment/conflicts` | `CRUDHandler.CheckEquipmentConflicts` | Detectar conflictos de equipo (POST para web) |
| `GET` | `/api/events/equipment/suggestions` | `CRUDHandler.GetEquipmentSuggestionsGET` | Sugerencias de equipo (GET para mobile) |
| `POST` | `/api/events/equipment/suggestions` | `CRUDHandler.GetEquipmentSuggestions` | Sugerencias de equipo (POST para web) |
| `GET` | `/api/events/supplies/suggestions` | `CRUDHandler.GetSupplySuggestionsGET` | Sugerencias de insumos (GET para mobile) |
| `POST` | `/api/events/supplies/suggestions` | `CRUDHandler.GetSupplySuggestions` | Sugerencias de insumos (POST para web) |
| `POST` | `/api/events/{id}/checkout-session` | `EventPaymentHandler.CreateEventCheckoutSession` | Crear sesión de pago Stripe para evento |
| `GET` | `/api/events/{id}/payment-session` | `EventPaymentHandler.HandleEventPaymentSuccess` | Manejar retorno exitoso de pago Stripe |

### 6.9 Rutas Protegidas — Productos

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/products` | `CRUDHandler.ListProducts` | Listar productos |
| `POST` | `/api/products` | `CRUDHandler.CreateProduct` | Crear producto |
| `POST` | `/api/products/ingredients/batch` | `CRUDHandler.GetBatchProductIngredients` | Obtener ingredientes de múltiples productos |
| `GET` | `/api/products/{id}` | `CUDHandler.GetProduct` | Obtener producto |
| `PUT` | `/api/products/{id}` | `CRUDHandler.UpdateProduct` | Actualizar producto |
| `DELETE` | `/api/products/{id}` | `CRUDHandler.DeleteProduct` | Eliminar producto |
| `GET` | `/api/products/{id}/ingredients` | `CRUDHandler.GetProductIngredients` | Ingredientes del producto |
| `PUT` | `/api/products/{id}/ingredients` | `CRUDHandler.UpdateProductIngredients` | Actualizar ingredientes |

### 6.10 Rutas Protegidas — Inventario

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/inventory` | `CRUDHandler.ListInventory` | Listar items del inventario |
| `POST` | `/api/inventory` | `CRUDHandler.CreateInventoryItem` | Crear item de inventario |
| `GET` | `/api/inventory/{id}` | `CRUDHandler.GetInventoryItem` | Obtener item |
| `PUT` | `/api/inventory/{id}` | `CRUDHandler.UpdateInventoryItem` | Actualizar item |
| `DELETE` | `/api/inventory/{id}` | `CRUDHandler.DeleteInventoryItem` | Eliminar item |

### 6.11 Rutas Protegidas — Pagos

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/payments` | `CRUDHandler.ListPayments` | Listar pagos |
| `POST` | `/api/payments` | `CRUDHandler.CreatePayment` | Registrar pago |
| `PUT` | `/api/payments/{id}` | `CRUDHandler.UpdatePayment` | Actualizar pago |
| `DELETE` | `/api/payments/{id}` | `CRUDHandler.DeletePayment` | Eliminar pago |

### 6.12 Rutas Protegidas — Fechas No Disponibles

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/unavailable-dates` | `UnavailableDateHandler.GetUnavailableDates` | Listar fechas bloqueadas |
| `POST` | `/api/unavailable-dates` | `UnavailableDateHandler.CreateUnavailableDate` | Crear fecha no disponible |
| `DELETE` | `/api/unavailable-dates/{id}` | `UnavailableDateHandler.DeleteUnavailableDate` | Eliminar fecha |

### 6.13 Rutas Protegidas — Dispositivos

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `POST` | `/api/devices/register` | `DeviceHandler.RegisterDevice` | Registrar token para push notifications |
| `POST` | `/api/devices/unregister` | `DeviceHandler.UnregisterDevice` | Desregistrar dispositivo |

### 6.14 Rutas Protegidas — Suscripciones

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/subscriptions/status` | `SubscriptionHandler.GetSubscriptionStatus` | Estado de la suscripción |
| `POST` | `/api/subscriptions/checkout-session` | `SubscriptionHandler.CreateCheckoutSession` | Crear sesión de checkout Stripe |
| `POST` | `/api/subscriptions/portal-session` | `SubscriptionHandler.CreatePortalSession` | Crear sesión del portal de facturación |

### 6.15 Rutas Protegidas — Búsqueda

Rate limit: **30 requests/minuto** por IP.

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/search` | `SearchHandler.SearchAll` | Búsqueda global en clientes, productos, inventario y eventos |

### 6.16 Rutas de Uploads

Rate limit: **5 requests/minuto** por IP.

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `POST` | `/api/uploads/image` | `UploadHandler.UploadImage` | Subir imagen (genera thumbnail). Límite por plan: 50 basic / 200 pro |

### 6.17 Rutas Admin

Requieren: JWT + rol `admin`. Rate limit: **30 requests/minuto**.

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `GET` | `/api/admin/stats` | `AdminHandler.GetStats` | Estadísticas globales de la plataforma |
| `GET` | `/api/admin/users` | `AdminHandler.ListUsers` | Listar todos los usuarios |
| `GET` | `/api/admin/users/{id}` | `AdminHandler.GetUser` | Obtener usuario específico |
| `PUT` | `/api/admin/users/{id}/upgrade` | `AdminHandler.UpgradeUser` | Upgrade/downgrade de plan de usuario |
| `GET` | `/api/admin/subscriptions` | `AdminHandler.GetSubscriptions` | Listar todas las suscripciones |

### 6.18 Rutas Debug (Admin Only)

Solo disponibles en entornos de desarrollo. Requieren JWT + rol `admin`.

| Método | Ruta | Handler | Descripción |
|--------|------|---------|-------------|
| `POST` | `/api/subscriptions/debug-upgrade` | `SubscriptionHandler.DebugUpgrade` | Upgrade manual de plan (solo dev) |
| `POST` | `/api/subscriptions/debug-downgrade` | `SubscriptionHandler.DebugDowngrade` | Downgrade manual de plan (solo dev) |

---

## 7. Middleware Stack

El orden de los middleware es intencional — Recovery debe ser el primero para capturar panics en cualquier middleware posterior.

### 7.1 Recovery (Global)

**Archivo:** `middleware/recovery.go`

- Captura panics en cualquier handler o middleware
- Registra el stack trace completo con `debug.Stack()`
- Retorna HTTP 500 con `{"error":"Internal server error"}`
- **Debe ser el primer middleware** en la cadena

### 7.2 CORS (Global)

**Archivo:** `middleware/cors.go`

- Orígenes permitidos configurables vía `CORS_ALLOWED_ORIGINS`
- Verifica el header `Origin` contra un set de orígenes permitidos
- Headers permitidos: `Accept`, `Content-Type`, `Authorization`
- Métodos permitidos: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`, `PATCH`
- Responde preflight (`OPTIONS`) con `204 No Content`
- `Access-Control-Allow-Credentials: true` para cookies httpOnly
- `Access-Control-Max-Age: 3600` (1 hora de cache del preflight)

### 7.3 Security Headers (Global)

**Archivo:** `middleware/security.go`

Implementa headers de seguridad OWASP:

| Header | Valor | Protección |
|--------|-------|------------|
| `X-Content-Type-Options` | `nosniff` | Previene MIME sniffing |
| `X-Frame-Options` | `DENY` | Previene clickjacking |
| `X-XSS-Protection` | `1; mode=block` | XSS en navegadores legacy |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Fuerza HTTPS (solo si TLS/proxy HTTPS) |
| `Content-Security-Policy` | `default-src 'self'; script-src 'self'; ...` | Restringe fuentes de recursos |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Controla info del Referer |
| `Permissions-Policy` | `geolocation=(), microphone=(), camera=(), ...` | Deshabilita APIs del navegador no necesarias |

### 7.4 Logger (Global)

**Archivo:** `middleware/logging.go`

- Registra cada request con `slog.Info`
- Campos: `method`, `path`, `status`, `duration`, `remote`
- Usa un `responseWriter` wrapper para capturar el status code real
- Formato estructurado (key-value pairs)

### 7.5 Auth (Per-Route)

**Archivo:** `middleware/auth.go`

Flujo de validación:
1. Busca token en cookie `auth_token` (prioridad, seguro)
2. Fallback a header `Authorization: Bearer {token}` (para API clients/mobile)
3. Si no hay token: HTTP 401 `"Authentication required"`
4. Valida el JWT con `AuthService.ValidateToken()`
5. Rechaza tokens de tipo `refresh` o `password-reset`
6. Inyecta `UserID` y `UserEmail` en `context.Context`
7. Los handlers acceden con `middleware.GetUserID(ctx)` y `middleware.GetUserEmail(ctx)`

### 7.6 Rate Limiting (Per-Route)

**Archivo:** `middleware/ratelimit.go`

- **Algoritmo**: Ventana fija por IP (fixed window counter)
- **Extracción de IP**: `RemoteAddr` por defecto; `X-Forwarded-For` solo si `TrustProxy = true`
- **Limpieza**: Goroutine de fondo cada 5 minutos elimina entradas expiradas
- **Stop function**: `RateLimitStopFunc` para shutdown limpio

Límites configurados:

| Grupo de rutas | Límite | Ventana |
|----------------|--------|---------|
| Auth (login, register, etc.) | 10 requests | 1 minuto |
| Uploads (subida de imágenes) | 5 requests | 1 minuto |
| Search | 30 requests | 1 minuto |
| Admin | 30 requests | 1 minuto |

Respuesta cuando se excede: HTTP 429 con header `Retry-After`.

### 7.7 Admin Only (Per-Route)

**Archivo:** `middleware/admin.go`

- Requiere que el middleware `Auth` haya corrido antes
- Extrae `UserID` del contexto
- Consulta la base de datos para verificar `user.Role == "admin"`
- HTTP 401 si no hay usuario; HTTP 403 si no es admin

---

## 8. Autenticación y Seguridad

### 8.1 JWT — Generación y Validación

**Archivo:** `services/auth_service.go`

El sistema usa **tres tipos de token**, todos firmados con HS256:

| Tipo | Subject | Duración | Uso |
|------|---------|----------|-----|
| Access Token | `access` | Configurable (default 24h) | Autenticar requests a la API |
| Refresh Token | `refresh` | 7 días | Renovar access tokens sin re-login |
| Reset Token | `password-reset` | 1 hora | Restablecer contraseña |

**Claims del token** (`TokenClaims`):
- `user_id` — UUID del usuario
- `email` — Email del usuario
- `exp` — Expiración
- `iat` — Fecha de emisión
- `iss` — `"solennix-backend"`
- `sub` — Tipo de token

**Validación estricta por tipo**: `ValidateToken()` rechaza tokens refresh y reset. `ValidateRefreshToken()` solo acepta subject `refresh`. `ValidateResetToken()` solo acepta subject `password-reset`.

### 8.2 Password Hashing

- **Algoritmo**: bcrypt con `bcrypt.DefaultCost` (10)
- `HashPassword()` — genera hash al registrar o cambiar contraseña
- `CheckPassword()` — compara contraseña plana con hash almacenado
- El campo `PasswordHash` tiene tag `json:"-"` para nunca exponerse en JSON

### 8.3 Token Refresh

1. El cliente envía su refresh token a `POST /api/auth/refresh`
2. El servidor valida que sea un token tipo `refresh` (no access, no reset)
3. Genera un nuevo `TokenPair` (access + refresh)
4. Retorna ambos tokens al cliente

### 8.4 OAuth — Google y Apple

- `POST /api/auth/google` — Recibe un token de Google, verifica la identidad y crea/actualiza el usuario con `google_user_id`
- `POST /api/auth/apple` — Recibe un token de Apple Sign In, verifica y crea/actualiza con `apple_user_id`
- Ambos flujos generan un `TokenPair` JWT propio del backend

### 8.5 Cookie httpOnly

- El access token se puede almacenar en una cookie `auth_token` con flag `httpOnly`
- El middleware de Auth prioriza la cookie sobre el header `Authorization`
- `POST /api/auth/logout` limpia la cookie

### 8.6 Seguridad General

- Rate limiting en endpoints sensibles (auth, uploads)
- Security headers OWASP en todas las respuestas
- CORS restringido a orígenes específicos
- `TrustProxy` configurable para despliegues detrás de reverse proxy
- Todas las queries usan parámetros (`$1`, `$2`) para prevenir SQL injection
- Multi-tenant: todas las queries filtran por `user_id`

---

## 9. Integraciones Externas

### 9.1 Stripe

**Archivos:** `handlers/subscription_handler.go`, `handlers/event_payment_handler.go`, `handlers/stripe_service.go`

| Funcionalidad | Endpoint | Descripción |
|---------------|----------|-------------|
| Checkout Session (suscripción) | `POST /api/subscriptions/checkout-session` | Crea una sesión de Stripe Checkout para upgrade a plan Pro |
| Checkout Session (evento) | `POST /api/events/{id}/checkout-session` | Crea una sesión de pago para un evento específico |
| Customer Portal | `POST /api/subscriptions/portal-session` | Redirige al portal de facturación de Stripe |
| Webhook | `POST /api/subscriptions/webhook/stripe` | Procesa eventos de Stripe (suscripción creada, cancelada, etc.) |

**Variables de entorno requeridas:**
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_PRO_PRICE_ID`
- `STRIPE_PORTAL_CONFIG_ID` (opcional)

### 9.2 RevenueCat

**Archivos:** `handlers/subscription_handler.go`, `services/revenuecat_service.go`

- `POST /api/subscriptions/webhook/revenuecat` — Procesa webhooks v2 de RevenueCat (verificado por header `REVENUECAT_WEBHOOK_SECRET`)
- `RevenueCatService` — Sync bidireccional Stripe ↔ RevenueCat via REST API v1:
  - `GrantPromotionalEntitlement` — Cuando un usuario compra por Stripe (web), se le otorga el entitlement `pro_access` en RevenueCat para que iOS/Android lo vean
  - `RevokePromotionalEntitlement` — Cuando se cancela/elimina la suscripcion Stripe, se revoca el entitlement en RevenueCat
- **Variables de entorno:** `REVENUECAT_WEBHOOK_SECRET`, `REVENUECAT_API_KEY` (secret key para server-to-server)

### 9.3 Resend

**Archivo:** `services/email_service.go`

- Único uso actual: **email de recuperación de contraseña**
- Template HTML en español con branding de Solennix
- El enlace de reset apunta a `{FRONTEND_URL}/reset-password?token={token}`
- Si `RESEND_API_KEY` no está configurado, el email no se envía (warning en log)

**Variables de entorno:**
- `RESEND_API_KEY`
- `RESEND_FROM_EMAIL` (default: `Solennix <noreply@solennix.com>`)
- `FRONTEND_URL` (default: `http://localhost:5173`)

### 9.4 File Uploads

**Archivo:** `handlers/upload_handler.go`

- Almacenamiento local en disco (`UPLOAD_DIR`, default `./uploads`)
- Archivos organizados por usuario: `{uploadDir}/{userID}/{filename}`
- Genera thumbnails automáticamente al subir imágenes
- Acepta JPEG y PNG
- Servidos estáticamente en `GET /api/uploads/*` con cache de 1 año

**Límites por plan:**

| Plan | Uploads máximos |
|------|----------------|
| Basic | 50 |
| Pro | 200 |

---

## 10. Testing

### 10.1 Estrategia

El proyecto tiene tests en todas las capas:

| Capa | Archivos | Enfoque |
|------|----------|---------|
| Config | `config_test.go` | Variables de entorno, defaults |
| Middleware | `auth_test.go`, `cors_test.go`, `recovery_test.go`, `security_test.go`, `ratelimit_test.go`, `admin_test.go`, `logging_test.go` | Comportamiento de cada middleware |
| Handlers | `auth_handler_test.go`, `crud_handler_test.go`, `crud_handler_success_test.go`, `crud_handler_error_test.go`, `crud_payment_test.go`, `subscription_handler_test.go`, `event_payment_handler_test.go`, `upload_handler_test.go`, `search_handler_test.go`, `helpers_test.go`, `validation_test.go`, `contract_template_test.go` | Mocks de repos, validación de HTTP responses |
| Services | `auth_service_test.go`, `email_service_test.go` | JWT, bcrypt, templates de email |
| Repository | `repository_integration_test.go`, `repository_error_test.go` | Tests de integración con DB real |
| Router | `router_test.go`, `router_api_integration_test.go` | Rutas registradas, integración API |
| Database | `database_test.go`, `migrate_test.go` | Conexión, sistema de migraciones |

### 10.2 Herramientas

- **testify** — Assertions (`assert`, `require`) y mocks (`mock.Mock`)
- **Mocks**: Definidos en `handlers/mocks_test.go` — implementan las interfaces de repositorio
- **httptest**: `httptest.NewRecorder()` para simular HTTP requests sin servidor real

### 10.3 Ejecución

```bash
# Todos los tests
cd backend && go test ./...

# Tests con verbose
go test ./... -v

# Tests de un paquete específico
go test ./internal/handlers/ -v

# Tests de integración (requieren DB)
go test ./internal/repository/ -v
```

---

## 11. Despliegue

### 11.1 Docker

**Dockerfile** (multi-stage build):

1. **Stage builder** (`golang:1.25-alpine`): Descarga dependencias, compila binario estático
2. **Stage final** (`alpine:latest`): Solo el binario + certificados CA

```bash
# Build
docker build -t solennix-backend .

# Run
docker run -p 8080:8080 --env-file .env solennix-backend
```

### 11.2 Docker Compose (Desarrollo Local)

```yaml
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: solennix_user
      POSTGRES_PASSWORD: solennix_password
      POSTGRES_DB: solennix
    ports:
      - "5433:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
```

### 11.3 Variables de Entorno

| Variable | Requerida | Default | Descripción |
|----------|-----------|---------|-------------|
| `DATABASE_URL` | Si | — | URL de conexión PostgreSQL |
| `JWT_SECRET` | Si | — | Secreto para firmar JWTs |
| `PORT` | No | `8080` | Puerto del servidor HTTP |
| `ENVIRONMENT` | No | `development` | Entorno (`development` / `production`) |
| `JWT_EXPIRY_HOURS` | No | `24` | Horas de expiración del access token |
| `CORS_ALLOWED_ORIGINS` | No | `http://localhost:5173` | Orígenes CORS (separados por coma) |
| `RESEND_API_KEY` | No | — | API key de Resend para emails |
| `RESEND_FROM_EMAIL` | No | `Solennix <noreply@solennix.com>` | Dirección de envío de emails |
| `FRONTEND_URL` | No | `http://localhost:5173` | URL del frontend (para links en emails) |
| `STRIPE_SECRET_KEY` | No | — | Secret key de Stripe |
| `STRIPE_WEBHOOK_SECRET` | No | — | Secreto para verificar webhooks de Stripe |
| `STRIPE_PRO_PRICE_ID` | No | — | Price ID del plan Pro en Stripe |
| `STRIPE_PORTAL_CONFIG_ID` | No | — | Config ID del portal de facturación |
| `REVENUECAT_WEBHOOK_SECRET` | No | — | Secreto para webhooks de RevenueCat |
| `REVENUECAT_API_KEY` | No | — | Secret API key de RevenueCat para sync Stripe→RC |
| `UPLOAD_DIR` | No | `./uploads` | Directorio de uploads |
| `BOOTSTRAP_ADMIN_EMAIL` | No | — | Email a promover a admin al iniciar |
| `TRUST_PROXY` | No | `false` | Confiar en `X-Forwarded-For` |

### 11.4 Health Check

```bash
curl http://localhost:8080/health
# {"status":"ok"}
```

### 11.5 Graceful Shutdown

El servidor captura senales `SIGINT` y `SIGTERM`:
1. Deja de aceptar nuevas conexiones
2. Espera hasta 15 segundos para que las conexiones activas terminen
3. Cierra el pool de conexiones a PostgreSQL
4. Sale limpiamente

### 11.6 Background Jobs

| Job | Frecuencia | Descripción |
|-----|------------|-------------|
| Expire Gifted Plans | Cada 1 hora | Revierte planes gifted expirados a `basic` |

---

## 12. Gotchas y Decisiones Técnicas

### 12.1 pgx sobre GORM

**Decision**: Usar `pgx` directamente en lugar de un ORM como GORM.

**Razones:**
- Control total sobre las queries SQL (JOINs complejos, columnas generadas, JSONB)
- Mejor rendimiento al eliminar la capa de abstracción del ORM
- `pgxpool` provee connection pooling nativo eficiente
- El driver nativo de PostgreSQL soporta tipos avanzados (UUID, JSONB, arrays)
- Más idiomático en Go (explícito > implícito)

### 12.2 Chi sobre Gin/Echo

**Decision**: Usar Chi como router HTTP.

**Razones:**
- Totalmente compatible con `net/http` (handlers estándar de Go)
- Middleware composable con la firma estándar `func(http.Handler) http.Handler`
- Sin dependencias externas pesadas
- Enrutamiento basado en radix tree (rendimiento similar a Gin)
- Integración natural con el ecosistema estándar de Go

### 12.3 Migraciones Embebidas

**Decision**: Sistema de migraciones propio con `go:embed` en lugar de herramientas como `golang-migrate` o `goose`.

**Razones:**
- Las migraciones se incluyen en el binario compilado (no hay archivos externos que gestionar)
- Ejecución automática al arrancar el servidor
- Control total sobre el proceso (transacciones por migración, rollback automático)
- Sin dependencias adicionales
- Simple de mantener: solo archivos `.up.sql` y `.down.sql` numerados

### 12.4 slog sobre zerolog/zap

**Decision**: Usar `log/slog` (stdlib) en lugar de librerías de logging de terceros.

**Razones:**
- Incluido en la biblioteca estándar desde Go 1.21
- Logging estructurado nativo (key-value pairs)
- Sin dependencias externas
- Rendimiento suficiente para la carga actual
- API estable garantizada por el equipo de Go

### 12.5 JWT en Cookie httpOnly + Header

**Decision**: Soportar ambos mecanismos de autenticación.

**Razones:**
- Cookie httpOnly es más seguro para la web (no accesible desde JavaScript)
- Header `Authorization: Bearer` es estándar para clientes móviles (iOS/Android)
- La prioridad es cookie > header para máxima seguridad en web

### 12.6 Multi-tenant por user_id

**Decision**: Filtrar todas las queries por `user_id` en lugar de una arquitectura multi-database.

**Razones:**
- Simplicidad de implementación y despliegue
- Una sola base de datos para todos los usuarios
- Cada usuario solo accede a sus propios datos
- Los índices incluyen `user_id` para rendimiento

### 12.7 Almacenamiento Local de Uploads

**Decision**: Almacenar archivos en disco local en lugar de S3/Cloud Storage.

**Razones:**
- Simplicidad para MVP
- Sin costos adicionales de almacenamiento en la nube
- Servidos directamente por el servidor Go con `http.FileServer`
- **Limitación conocida**: No funciona en deploys multi-instancia sin volumen compartido. Migrar a S3/Cloud Storage es un cambio futuro planificado.

### 12.8 Fechas como Strings

**Decision**: Las fechas de eventos, pagos y fechas no disponibles se almacenan como `string` (`YYYY-MM-DD`) en los modelos Go.

**Razones:**
- PostgreSQL almacena como tipo `DATE`
- Evita problemas de timezone al transportar entre servidor y clientes móviles
- Formato consistente y predecible en JSON
- Los clientes (iOS, Android, web) parsean el string directamente
