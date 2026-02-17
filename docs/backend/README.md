# Backend — Go API

Guía completa del backend en Go para EventosApp.

## 📋 Resumen

Backend REST API en Go que sirve como capa de servicios para la aplicación web y móvil. Se integra con PostgreSQL como base de datos y maneja autenticación JWT, middleware de seguridad, y lógica de negocio.

### Características Principales

- 🏗️ **Arquitectura**: Chi router + capas separadas (handlers, services, repositories)
- 🔒 **Autenticación**: JWT con refresh tokens
- 🛡️ **Base de datos**: PostgreSQL con pgx driver
- 🔐 **Seguridad**: CORS, rate limiting, sanitización de inputs
- 📊 **Reporting**: Logging estructurado con contexto
- 🔄 **Migraciones**: SQL embebidas con `go:embed`
- 📦 **Docker**: Soporte para despliegue en contenedores

---

## 🚀 Requisitos Previos

- **Go** 1.21+ (instalar desde [golang.org](https://go.dev/dl/))
- **PostgreSQL** 15+
- **Docker** (opcional, para desarrollo fácil)

## 📦 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/tiagofur/eventosapp.git
cd eventosapp/backend
```

### 2. Instalar dependencias

```bash
go mod download
```

### 3. Configurar base de datos

```bash
# Crear base de datos
createdb eventosapp

# Ejecutar migraciones
go run ./cmd/migrate/main.go
```

### 4. Configurar variables de entorno

```bash
# Crear archivo .env
cat > .env << EOF
# Database
DATABASE_URL=postgres://postgres:postgres@localhost:5432/eventosapp?sslmode=disable

# JWT
JWT_SECRET=tu-secret-key-muy-seguro-genera-con-openssl-rand-base64-32
JWT_EXPIRY_HOURS=24

# Server
PORT=8080
ENVIRONMENT=development

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
EOF
```

### 5. Ejecutar en desarrollo

```bash
go run ./cmd/server/main.go
```

El servidor estará disponible en `http://localhost:8080`

---

## 🏗️ Estructura del Proyecto

```
backend/
├── cmd/
│   ├── server/
│   │   └── main.go           # Punto de entrada del servidor
│   └── migrate/
│       └── main.go           # Ejecutor de migraciones
│
├── internal/
│   ├── config/
│   │   ├── config.go        # Configuración (env vars)
│   │   └── database.go      # Conexión a PostgreSQL
│   │
│   ├── handlers/
│   │   ├── auth.go          # Handlers de autenticación
│   │   ├── users.go         # Handlers de usuarios
│   │   ├── clients.go       # Handlers de clientes
│   │   ├── events.go        # Handlers de eventos
│   │   ├── products.go      # Handlers de productos
│   │   ├── inventory.go     # Handlers de inventario
│   │   ├── payments.go      # Handlers de pagos
│   │   ├── search.go        # Handlers de búsqueda
│   │   └── dashboard.go     # Handlers de dashboard
│   │
│   ├── middleware/
│   │   ├── auth.go          # Middleware de autenticación
│   │   ├── cors.go          # Middleware de CORS
│   │   ├── logging.go       # Middleware de logging
│   │   └── ratelimit.go     # Middleware de rate limiting
│   │
│   ├── models/
│   │   ├── user.go          # Modelo de usuario
│   │   ├── client.go        # Modelo de cliente
│   │   ├── event.go         # Modelo de evento
│   │   ├── product.go       # Modelo de producto
│   │   ├── inventory.go     # Modelo de inventario
│   │   └── payment.go       # Modelo de pago
│   │
│   ├── repository/
│   │   ├── user.go          # Repositorio de usuario
│   │   ├── client.go        # Repositorio de cliente
│   │   ├── event.go         # Repositorio de evento
│   │   └── ...
│   │
│   ├── services/
│   │   ├── auth.go          # Servicio de autenticación
│   │   ├── event.go         # Servicio de eventos
│   │   └── ...
│   │
│   └── router/
│       └── router.go        # Configuración de rutas Chi
│
├── migrations/
│   ├── 000001_init_schema.up.sql      # SQL inicial
│   ├── 000001_init_schema.down.sql    # Rollback
│   └── ...
│
├── .env                         # Variables de entorno (no commitear)
├── .env.example                 # Ejemplo de variables
├── go.mod                       # Dependencias Go
├── go.sum                       # Checksums de dependencias
├── Dockerfile                    # Configuración Docker
└── docker-compose.yml              # Orquestación de servicios
```

---

## 🔌 Principios de Arquitectura

### Clean Architecture

```
┌─────────────┐
│   Handlers  │ ← HTTP handlers (Chi router)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Services   │ ← Lógica de negocio
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Repositories  │ ← Acceso a datos (SQL)
└─────────────┘
       │
       ▼
┌─────────────┐
│ PostgreSQL  │
└─────────────┘
```

### Responsabilidades por Capa

| Capa | Responsabilidad |
|-------|---------------|
| **Handlers** | Manejar requests HTTP, validar inputs, llamar services |
| **Services** | Lógica de negocio, coordinar múltiples repositorios |
| **Repositories** | CRUD directo a base de datos |
| **Middleware** | Cross-cutting concerns (auth, CORS, logging) |
| **Models** | Estructuras de datos, validaciones |

---

## 🛠️ Stack Tecnológico

| Tecnología | Versión | Uso |
|-----------|----------|------|
| Go | 1.21+ | Lenguaje principal |
| Chi | Latest | HTTP router |
| pgx | Latest | PostgreSQL driver |
| golang-jwt/jwt | v5 | Generación/validación JWT |
| bcrypt | Latest | Hash de passwords |
| go:embed | Latest | Embeber archivos SQL |
| testify | Latest | Unit testing |
| godotenv | Latest | Variables de entorno |

---

## 🔗 Configuración

### Database Connection

```go
// internal/config/database.go
package config

import (
    "context"
    "fmt"

    "github.com/jackc/pgx/v5/pgxpool"
    _ "github.com/lib/pq" // driver para pgx
)

type DB struct {
    *pgxpool.Pool
}

func Connect(ctx context.Context, connString string) (*DB, error) {
    config, err := pgxpool.ParseConfig(connString)
    if err != nil {
        return nil, fmt.Errorf("unable to parse database config: %w", err)
    }

    pool, err := pgxpool.NewWithConfig(config, connString)
    if err != nil {
        return nil, fmt.Errorf("unable to create connection pool: %w", err)
    }

    return &DB{Pool: pool}, nil
}
```

### Environment Variables

```go
// internal/config/config.go
package config

import (
    "os"

    "github.com/joho/godotenv"
)

type Config struct {
    DatabaseURL string
    JWTSecret   string
    JWTExpiry  int
    Port        string
    Environment string
    CORSOrigins []string
}

func Load() (*Config, error) {
    if err := godotenv.Load(); err != nil {
        return nil, err
    }

    return &Config{
        DatabaseURL: os.Getenv("DATABASE_URL"),
        JWTSecret:  os.Getenv("JWT_SECRET"),
        JWTExpiry:  mustGetInt("JWT_EXPIRY_HOURS", 24),
        Port:        mustGetString("PORT", "8080"),
        Environment:  mustGetString("ENVIRONMENT", "development"),
        CORSOrigins: mustGetStringSlice("CORS_ALLOWED_ORIGINS", "http://localhost:5173"),
    }, nil
}
```

---

## 🔐 Autenticación con JWT

### Generar Tokens

```go
// internal/services/auth.go
package services

import (
    "errors"
    "time"

    "github.com/golang-jwt/jwt/v5"
)

type Claims struct {
    UserID string `json:"user_id"`
    jwt.RegisteredClaims
}

func (s *AuthService) GenerateTokens(userID string) (string, string, error) {
    // Access token (1 hora)
    accessToken, err := s.generateToken(userID, time.Hour*time.Duration(s.config.JWTExpiry))
    if err != nil {
        return "", "", err
    }

    // Refresh token (7 días)
    refreshToken, err := s.generateToken(userID, 24*7*time.Hour)
    if err != nil {
        return "", "", err
    }

    return accessToken, refreshToken, nil
}

func (s *AuthService) generateToken(userID string, expiry time.Duration) (string, error) {
    claims := Claims{
        UserID: userID,
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: time.Now().Add(expiry).Unix(),
        },
    }

    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString([]byte(s.config.JWTSecret))
}
```

### Middleware de Autenticación

```go
// internal/middleware/auth.go
package middleware

import (
    "net/http"

    "github.com/go-chi/chi/v5"
    "github.com/golang-jwt/jwt/v5"
)

func AuthMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Extraer token del header
        tokenString := r.Header.Get("Authorization")
        if tokenString == "" {
            http.Error(w, "Unauthorized", http.StatusUnauthorized)
            return
        }

        // Remover "Bearer " prefix
        tokenString = tokenString[7:]

        // Validar token
        token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
            return []byte(jwtSecret), nil
        })

        if err != nil || !token.Valid {
            http.Error(w, "Invalid token", http.StatusUnauthorized)
            return
        }

        // Agregar userID al contexto
        claims := token.Claims.(*Claims)
        ctx := context.WithValue(r.Context(), "userID", claims.UserID)

        next.ServeHTTP(w, r.WithContext(ctx))
    })
}

// Helper para obtener userID del contexto
func GetUserID(ctx context.Context) (string, bool) {
    userID, ok := ctx.Value("userID").(string)
    return userID, ok
}
```

---

## 📡 Estructura de Handlers

### Handler Base

```go
// internal/handlers/handlers.go
package handlers

import (
    "encoding/json"
    "net/http"

    "github.com/go-chi/chi/v5"
)

type Handler struct {
    db *config.DB
}

func NewHandler(db *config.DB) *Handler {
    return &Handler{db: db}
}

// Response helper
func respondJSON(w http.ResponseWriter, status int, data interface{}) error {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    return json.NewEncoder(w).Encode(data)
}

// Error helper
func respondError(w http.ResponseWriter, status int, message string) error {
    return respondJSON(w, status, map[string]string{"error": message})
}
```

### Handler de Ejemplo: Events

```go
// internal/handlers/events.go
package handlers

import (
    "net/http"

    "github.com/go-chi/chi/v5"
)

type EventRequest struct {
    ClientID      string    `json:"client_id"`
    EventDate     string    `json:"event_date"`
    StartTime     string    `json:"start_time,omitempty"`
    EndTime       string    `json:"end_time,omitempty"`
    ServiceType   string    `json:"service_type"`
    NumPeople     int       `json:"num_people"`
    Status        string    `json:"status"`
    Discount      float64   `json:"discount,omitempty"`
    RequiresInvoice bool      `json:"requires_invoice"`
    TaxRate       float64   `json:"tax_rate,omitempty"`
    Location      string    `json:"location,omitempty"`
    City          string    `json:"city,omitempty"`
    Notes         string    `json:"notes,omitempty"`
}

func (h *Handler) CreateEvent(w http.ResponseWriter, r *http.Request) {
    userID, ok := middleware.GetUserID(r.Context())
    if !ok {
        respondError(w, http.StatusUnauthorized, "Unauthorized")
        return
    }

    var req EventRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        respondError(w, http.StatusBadRequest, "Invalid request body")
        return
    }

    // Crear evento usando service
    event, err := h.eventService.Create(r.Context(), userID, req)
    if err != nil {
        respondError(w, http.StatusInternalServerError, "Failed to create event")
        return
    }

    respondJSON(w, http.StatusCreated, event)
}

func (h *Handler) GetEvents(w http.ResponseWriter, r *http.Request) {
    userID, ok := middleware.GetUserID(r.Context())
    if !ok {
        respondError(w, http.StatusUnauthorized, "Unauthorized")
        return
    }

    // Obtener query params
    status := r.URL.Query().Get("status")
    clientID := r.URL.Query().Get("client_id")

    events, err := h.eventService.GetByUser(r.Context(), userID, status, clientID)
    if err != nil {
        respondError(w, http.StatusInternalServerError, "Failed to get events")
        return
    }

    respondJSON(w, http.StatusOK, events)
}
```

---

## 🗄️ Migraciones

### Embeber SQL con go:embed

```go
// cmd/migrate/main.go
package main

import (
    "embed"
    "fmt"
    "log"

    "github.com/jackc/pgx/v5"
)

//go:embed migrations/*.sql
var migrationsFS embed.FS

func main() {
    // Conectar a DB
    connString := os.Getenv("DATABASE_URL")
    conn, err := pgx.Connect(context.Background(), connString)
    if err != nil {
        log.Fatalf("Failed to connect to database: %v", err)
    }
    defer conn.Close(context.Background())

    // Ejecutar migraciones
    if err := runMigrations(conn); err != nil {
        log.Fatalf("Failed to run migrations: %v", err)
    }

    fmt.Println("Migrations completed successfully!")
}

func runMigrations(conn *pgx.Conn) error {
    // Leer archivos SQL del filesystem embebido
    files, err := migrationsFS.ReadDir("migrations")
    if err != nil {
        return fmt.Errorf("failed to read migrations directory: %w", err)
    }

    // Ejecutar cada migración en orden
    for _, file := range files {
        content, err := migrationsFS.ReadFile("migrations/" + file.Name())
        if err != nil {
            return fmt.Errorf("failed to read migration file %s: %w", file.Name(), err)
        }

        if _, err := conn.Exec(context.Background(), string(content)); err != nil {
            return fmt.Errorf("failed to execute migration %s: %w", file.Name(), err)
        }

        log.Printf("Executed migration: %s", file.Name())
    }

    return nil
}
```

---

## 🛣️ Router con Chi

```go
// internal/router/router.go
package router

import (
    "net/http"

    "github.com/go-chi/chi/v5"
    "github.com/go-chi/chi/v5/middleware"
    "eventosapp/internal/handlers"
    "eventosapp/internal/middleware"
)

func SetupRouter(h *handlers.Handler) *chi.Mux {
    r := chi.NewRouter()

    // Middleware global
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)
    r.Use(middleware.CORS)

    // Rutas públicas (sin auth)
    r.Post("/api/auth/register", h.Register)
    r.Post("/api/auth/login", h.Login)
    r.Post("/api/auth/refresh", h.RefreshToken)

    // Rutas protegidas (requieren auth)
    r.Group(func(r chi.Router) {
        r.Use(middleware.AuthMiddleware)

        r.Get("/api/auth/me", h.GetCurrentUser)
        r.Put("/api/users/me", h.UpdateUser)

        r.Route("/api/clients", func(r chi.Router) {
            r.Get("/", h.GetClients)
            r.Post("/", h.CreateClient)
            r.Get("/{id}", h.GetClient)
            r.Put("/{id}", h.UpdateClient)
            r.Delete("/{id}", h.DeleteClient)
        })

        r.Route("/api/events", func(r chi.Router) {
            r.Get("/", h.GetEvents)
            r.Post("/", h.CreateEvent)
            r.Get("/{id}", h.GetEvent)
            r.Put("/{id}", h.UpdateEvent)
            r.Delete("/{id}", h.DeleteEvent)
            r.Get("/{id}/products", h.GetEventProducts)
            r.Get("/{id}/extras", h.GetEventExtras)
            r.Put("/{id}/items", h.UpdateEventItems)
        })
    })

    // Health check
    r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte(`{"status":"ok"}`))
    })

    return r
}
```

---

## 🧪 Docker

### Dockerfile

```dockerfile
# Dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copiar go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copiar código
COPY . .

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server/main.go

# Runner
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/server .
COPY --from=builder /app/migrations ./migrations

EXPOSE 8080

CMD ["./server"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: eventosapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: postgres://postgres:postgres@db:5432/eventosapp?sslmode=disable
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXPIRY_HOURS: 24
      PORT: 8080
      ENVIRONMENT: production
      CORS_ALLOWED_ORIGINS: https://app.eventosapp.com
    depends_on:
      db:
        condition: service_healthy

volumes:
  postgres_data:
```

### Ejecutar con Docker

```bash
# Build y ejecutar
docker-compose up -d --build

# Ver logs
docker-compose logs -f backend

# Detener
docker-compose down
```

---

## 🧪 Testing

### Unit Tests

```go
// internal/handlers/events_test.go
package handlers_test

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"

    "github.com/stretchr/testify/assert"
)

func TestCreateEvent(t *testing.T) {
    db := setupTestDB(t)
    defer db.Close()
    h := NewHandler(db)

    reqBody := map[string]interface{}{
        "client_id":   "client-123",
        "event_date":  "2024-06-15",
        "service_type": "Boda",
        "num_people":  150,
        "status":       "quoted",
    }

    body, _ := json.Marshal(reqBody)
    req := httptest.NewRequest("POST", "/api/events", bytes.NewBuffer(body))
    req.Header.Set("Content-Type", "application/json")

    // Mock auth middleware
    req = req.WithContext(context.WithValue(req.Context(), "userID", "user-123"))

    w := httptest.NewRecorder()
    h.CreateEvent(w, req)

    assert.Equal(t, http.StatusCreated, w.Code)

    var response map[string]interface{}
    json.Unmarshal(w.Body.Bytes(), &response)
    assert.Equal(t, "Boda", response["service_type"])
}
```

### Ejecutar Tests

```bash
# Ejecutar todos los tests
go test ./...

# Ejecutar con cobertura
go test -cover ./...

# Ejecutar con verbose
go test -v ./...
```

---

## 🔍 Endpoints API

### Auth Endpoints

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|-------|
| POST | `/api/auth/register` | Registrar usuario | ❌ |
| POST | `/api/auth/login` | Iniciar sesión | ❌ |
| POST | `/api/auth/refresh` | Renovar token | ❌ |
| GET | `/api/auth/me` | Obtener usuario actual | ✅ |
| PUT | `/api/users/me` | Actualizar usuario | ✅ |

### Clientes Endpoints

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|-------|
| GET | `/api/clients` | Listar clientes | ✅ |
| POST | `/api/clients` | Crear cliente | ✅ |
| GET | `/api/clients/{id}` | Obtener cliente | ✅ |
| PUT | `/api/clients/{id}` | Actualizar cliente | ✅ |
| DELETE | `/api/clients/{id}` | Eliminar cliente | ✅ |

### Eventos Endpoints

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|-------|
| GET | `/api/events` | Listar eventos | ✅ |
| POST | `/api/events` | Crear evento | ✅ |
| GET | `/api/events/{id}` | Obtener evento | ✅ |
| PUT | `/api/events/{id}` | Actualizar evento | ✅ |
| DELETE | `/api/events/{id}` | Eliminar evento | ✅ |
| GET | `/api/events/{id}/products` | Obtener productos del evento | ✅ |
| GET | `/api/events/{id}/extras` | Obtener extras del evento | ✅ |
| PUT | `/api/events/{id}/items` | Actualizar productos y extras | ✅ |

### Productos Endpoints

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|-------|
| GET | `/api/products` | Listar productos | ✅ |
| POST | `/api/products` | Crear producto | ✅ |
| GET | `/api/products/{id}` | Obtener producto | ✅ |
| PUT | `/api/products/{id}` | Actualizar producto | ✅ |
| DELETE | `/api/products/{id}` | Eliminar producto | ✅ |

### Inventario Endpoints

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|-------|
| GET | `/api/inventory` | Listar inventario | ✅ |
| POST | `/api/inventory` | Crear ítem de inventario | ✅ |
| GET | `/api/inventory/{id}` | Obtener ítem | ✅ |
| PUT | `/api/inventory/{id}` | Actualizar ítem | ✅ |
| DELETE | `/api/inventory/{id}` | Eliminar ítem | ✅ |

### Pagos Endpoints

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|-------|
| GET | `/api/payments` | Listar pagos | ✅ |
| POST | `/api/payments` | Crear pago | ✅ |
| PUT | `/api/payments/{id}` | Actualizar pago | ✅ |
| DELETE | `/api/payments/{id}` | Eliminar pago | ✅ |

---

## 🔒 Seguridad

### Sanitización de Inputs

```go
import (
    "regexp"
    "strings"
)

func sanitizeInput(input string) string {
    // Remover caracteres peligrosos
    re := regexp.MustCompile(`[<>{}\\]`)
    return re.ReplaceAllString(input, "")
}

func sanitizeEmail(input string) string {
    // Validar formato de email
    re := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
    if !re.MatchString(input) {
        return ""
    }
    return strings.ToLower(input)
}
```

### Rate Limiting

```go
// internal/middleware/ratelimit.go
package middleware

import (
    "net/http"
    "sync"
    "time"

    "golang.org/x/time/rate"
    "github.com/go-chi/chi/v5"
)

type RateLimiter struct {
    limiter *rate.Limiter
    visitors map[string]*rate.Limiter
    mu      sync.Mutex
}

func NewRateLimiter(rps int) *RateLimiter {
    return &RateLimiter{
        limiter: rate.NewLimiter(rate.Every(time.Second/time.Duration(rps)), rps),
        visitors: make(map[string]*rate.Limiter),
    }
}

func (rl *RateLimiter) Middleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        ip := r.RemoteAddr
        rl.mu.Lock()
        limiter, exists := rl.visitors[ip]
        if !exists {
            rl.visitors[ip] = rate.NewLimiter(rate.Limit, 1)
            limiter = rl.visitors[ip]
        }
        rl.mu.Unlock()

        if !limiter.Allow() {
            http.Error(w, "Too many requests", http.StatusTooManyRequests)
            return
        }

        next.ServeHTTP(w, r)
    })
}
```

---

## 📊 Logging

### Middleware de Logging

```go
// internal/middleware/logging.go
package middleware

import (
    "log/slog"
    "net/http"
    "time"

    "github.com/go-chi/chi/v5"
)

func LoggingMiddleware(logger *slog.Logger) func(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()

        // Log request
        logger.Info("Request",
            slog.String("method", r.Method),
            slog.String("path", r.URL.Path),
            slog.String("ip", r.RemoteAddr),
        )

        // Call next handler
        next.ServeHTTP(w, r)

        // Log response duration
        duration := time.Since(start)
        logger.Info("Response",
            slog.String("method", r.Method),
            slog.String("path", r.URL.Path),
            slog.Duration("duration", duration),
            slog.Int("status", w.(*responseRecorder).Status()),
        )
    })
}
```

---

## 🚀 Build y Despliegue

### Build Binario

```bash
# Build para Linux (producción)
CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server/main.go

# Build para macOS
GOOS=darwin GOARCH=amd64 go build -o server-mac ./cmd/server/main.go

# Build para Windows
GOOS=windows GOARCH=amd64 go build -o server.exe ./cmd/server/main.go
```

### Build con Docker

```bash
# Build imagen
docker build -t eventosapp-backend .

# Ejecutar contenedor
docker run -p 8080:8080 \
    -e DATABASE_URL=postgres://... \
    -e JWT_SECRET=... \
    eventosapp-backend
```

---

## 🐛 Troubleshooting

### Error: "connection refused"

Verificar que PostgreSQL esté corriendo:
```bash
# En macOS
brew services list | grep postgresql

# En Linux
systemctl status postgresql

# En Docker
docker ps | grep postgres
```

### Error: "invalid JWT token"

Verificar que `JWT_SECRET` sea el mismo en servidor y cliente:
```bash
# En el backend
echo $JWT_SECRET

# En el frontend (o móvil)
echo $VITE_JWT_SECRET  # o similar
```

### Error: "table does not exist"

Ejecutar migraciones:
```bash
go run ./cmd/migrate/main.go
```

---

## 📚 Recursos

- [Go Documentation](https://go.dev/doc/)
- [Chi Router](https://github.com/go-chi/chi)
- [pgx Documentation](https://github.com/jackc/pgx)
- [JWT for Go](https://github.com/golang-jwt/jwt)
- [Testify](https://github.com/stretchr/testify)

---

Última actualización: 2026-02-17
