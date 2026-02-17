# Documentación — EventosApp

## Índice

- [Arquitectura](#arquitectura)
- [Stack Tecnológico](#stack-tecnológico)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Base de datos](#base-de-datos)
- [IVA y facturación](#iva-y-facturación)
- [Autenticación](#autenticación)
- [Multi‑usuario](#multiusuario)
- [Documentación por Módulo](#documentación-por-módulo)

## Arquitectura

EventosApp es una aplicación de gestión de eventos con la siguiente arquitectura:

```
┌─────────────┐      HTTP/REST      ┌─────────────┐      SQL       ┌─────────────┐
│   Web App   │ ◄─────────────────► │  Go Backend │ ◄────────────► │  PostgreSQL │
│  (React)    │     (JWT Auth)      │   (Chi)     │                │             │
└─────────────┘                     └─────────────┘                └─────────────┘
       │
       │ Opcional
       ▼
┌─────────────┐
│    Flutter  │
│    (App)    │
└─────────────┘
```

## Stack Tecnológico

### Frontend (Web)
- **Framework:** React 18 + TypeScript
- **Build Tool:** Vite
- **Estilos:** Tailwind CSS
- **Forms:** React Hook Form + Zod
- **Charts:** Recharts
- **PDF:** jsPDF + jspdf-autotable
- **Testing:** Playwright (E2E)

### Backend
- **Lenguaje:** Go 1.21+
- **Router:** Chi
- **Base de datos:** PostgreSQL 15+
- **Driver:** pgx
- **Auth:** JWT (golang-jwt/jwt)
- **Passwords:** bcrypt
- **Migrations:** Embebidas (go:embed)

### Mobile (Opcional)
- **Framework:** Flutter
- **State Management:** Riverpod
- **HTTP Client:** Dio

## Estructura del Proyecto

```
eventosapp/
├── web/                    # Aplicación web (React)
│   ├── src/
│   │   ├── components/    # Componentes reutilizables
│   │   ├── contexts/      # Contextos React
│   │   ├── hooks/         # Custom hooks
│   │   ├── lib/           # Utilidades
│   │   ├── pages/         # Páginas
│   │   ├── services/      # Servicios API
│   │   └── types/         # Tipos TypeScript
│   ├── public/            # Archivos estáticos
│   └── tests/             # Tests E2E
│
├── backend/               # Backend API (Go)
│   ├── internal/
│   │   ├── config/        # Configuración
│   │   ├── database/      # Conexión y migraciones
│   │   ├── handlers/      # HTTP handlers
│   │   ├── middleware/    # Middleware (auth, CORS)
│   │   ├── models/        # Modelos de datos
│   │   ├── repository/    # Acceso a datos
│   │   ├── router/        # Definición de rutas
│   │   └── services/      # Lógica de negocio
│   └── migrations/        # SQL migrations
│
├── flutter/               # App móvil (Flutter) - Opcional
│   └── ...
│
├── docs/                  # Documentación
│   ├── web/              # Docs específicas web
│   ├── flutter/          # Docs Flutter
│   └── deploy.md         # Guía de despliegue
│
└── .context/             # Contexto para agentes IA
    ├── docs/             # Documentación técnica
    └── agents/           # Playbooks de agentes
```

## Base de Datos

### Esquema

El esquema de base de datos está definido en migraciones SQL en `backend/internal/database/migrations/`.

### Tablas principales

| Tabla | Descripción |
|-------|-------------|
| `users` | Usuarios registrados (perfil, configuración) |
| `clients` | Clientes de cada usuario |
| `events` | Eventos/cotizaciones |
| `products` | Catálogo de productos/servicios |
| `inventory` | Inventario de ingredientes y equipo |
| `event_products` | Productos asociados a eventos |
| `event_extras` | Extras/servicios adicionales |
| `product_ingredients` | Ingredientes por producto (recetas) |
| `payments` | Pagos recibidos |

### Seguridad a Nivel de Datos

- **Aislamiento:** Cada usuario solo puede acceder a sus propios datos
- **Filtrado:** Todas las queries incluyen `user_id` como filtro
- **Prepared Statements:** Previenen SQL injection
- **No RLS:** La seguridad se maneja en la capa de aplicación (Go)

## IVA y Facturación

- Cuando `requires_invoice = true`, el IVA se calcula automáticamente
- La tasa se controla con `tax_rate` (por defecto 16%)
- El resultado se guarda en `tax_amount` y se suma al `total_amount`

## Autenticación

### Flujo JWT

1. **Registro:** `POST /api/auth/register`
   - Crea usuario con password hasheado (bcrypt)
   - Retorna tokens JWT

2. **Login:** `POST /api/auth/login`
   - Valida credenciales
   - Retorna access token (24h) y refresh token (7 días)

3. **Uso:**
   - Incluir token en header: `Authorization: Bearer <token>`
   - El middleware valida el token en cada petición protegida

4. **Refresh:** `POST /api/auth/refresh`
   - Usar refresh token para obtener nuevo access token

### Seguridad

- Tokens con expiración automática
- Refresh tokens rotativos
- Passwords hasheados con bcrypt
- HTTPS en producción

## Multi‑usuario

La aplicación actualmente soporta múltiples usuarios independientes. Cada usuario:
- Tiene su propio conjunto de clientes, eventos, productos e inventario
- No puede acceder a datos de otros usuarios
- Se autentica con email/password propios

### Futuro: Equipos/Organizaciones

Sugerencia de diseño para habilitar equipos:

1. Crear tabla `organizations` y `organization_members`
2. Agregar columna `organization_id` a tablas principales
3. Implementar roles (admin, member, viewer)
4. Agregar panel de administración de equipo

## Documentación por Módulo

### Web App
- [Setup y Desarrollo](../web/README.md)
- [Setup y Desarrollo](web/setup.md)
- [Integración API](web/api-integration.md)
- [Seguridad](../web/SECURITY_AUDIT.md)

### Backend
- [README del Backend](backend/README.md)

### Backend
- [README del Backend](../backend/README.md) (crear si no existe)

### Flutter (Opcional)
- [Documentación Flutter](flutter/README.md)
- [Arquitectura](flutter/01-architecture.md)
- [Endpoints API](flutter/03-api-endpoints.md)

### Despliegue
- [Guía de Despliegue](deploy.md)
- [Checklist MVP](mvp-checklist.md)
- [Testing E2E](testing.md)

### Desarrollo
- [Contribuir al Proyecto](../CONTRIBUTING.md)
- [Mejoras y Roadmap](mejoras.md)

## Recursos Adicionales

- [Arquitectura del Sistema](../.context/docs/architecture.md)
- [Flujo de Datos](../.context/docs/data-flow.md)
- [Workflow de Desarrollo](../.context/docs/development-workflow.md)

---

Para información sobre cómo contribuir, ver [CONTRIBUTING.md](../CONTRIBUTING.md).
