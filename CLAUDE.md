# Solennix — Instrucciones para Claude Code

---

## Regla de Paridad Cross-Platform (OBLIGATORIA)

Solennix es un proyecto multi-plataforma: **iOS (SwiftUI)**, **Android (Kotlin/Compose)**, **Web (React/TypeScript)** y **Backend (Go)**.

Cada vez que se corrija un bug o se implemente una feature en CUALQUIER plataforma, DEBES verificar y aplicar el equivalente en TODAS las demás plataformas antes de considerar la tarea completa.

| Plataforma modificada | Debe revisarse y actualizarse también |
|-----------------------|---------------------------------------|
| iOS                   | Android, Web, Backend                 |
| Android               | iOS, Web, Backend                     |
| Web                   | iOS, Android, Backend                 |
| Backend               | iOS, Android, Web                     |
| iOS + Android         | Web, Backend                          |
| iOS + Web             | Android, Backend                      |
| Android + Web         | iOS, Backend                          |
| Frontend (todos)      | Backend                               |
| Backend               | iOS, Android, Web                     |

### Archivos clave por plataforma

| Área de cambio | iOS | Android | Web | Backend |
|----------------|-----|---------|-----|---------|
| Modelo de datos | `ios/Packages/SolennixCore/Sources/SolennixCore/Models/` | `android/core/model/` | `web/src/types/` | `backend/internal/model/` |
| Llamadas API / Red | `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/` | `android/core/network/` | `web/src/services/` o `web/src/api/` | `backend/internal/handler/` |
| ViewModels / Estado | `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/**/ViewModels/` | `android/feature/**/viewmodel/` | `web/src/stores/` o `web/src/hooks/` | N/A |
| Vistas / UI | `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/**/Views/` | `android/feature/**/ui/` | `web/src/pages/` y `web/src/components/` | N/A |
| Navegación | `ios/Solennix/Navigation/` | `android/app/src/main/java/**/navigation/` | `web/src/router/` | N/A |
| Autenticación | `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/AuthManager.swift` | `android/core/network/**/AuthInterceptor.kt` | `web/src/contexts/AuthContext.tsx` o `web/src/stores/authStore.ts` | `backend/internal/handler/auth.go` y `backend/internal/middleware/auth.go` |
| Repositorio / DB | N/A | N/A | N/A | `backend/internal/repository/` |
| Rutas API | N/A | N/A | N/A | `backend/internal/router/` o `backend/cmd/` |

**Esto no es opcional.** El objetivo es mantener todas las plataformas funcionalmente idénticas y libres de los mismos bugs. Siempre revisa proactivamente las plataformas equivalentes — no esperes a que el usuario lo solicite.

---

## Regla de Mantenimiento del PRD (OBLIGATORIA)

El PRD unificado vive en `PRD/` con los siguientes documentos:

| # | Archivo | Contenido |
|---|---------|-----------|
| 01 | `PRODUCT_VISION.md` | Visión, objetivos, usuarios objetivo, propuesta de valor |
| 02 | `FEATURES.md` | Features completas con tabla de paridad cross-platform |
| 03 | `COMPETITIVE_ANALYSIS.md` | Análisis competitivo en el mercado LATAM |
| 04 | `MONETIZATION.md` | Precios, tiers (Gratis/Pro/Business), feature gating |
| 05 | `TECHNICAL_ARCHITECTURE_IOS.md` | Arquitectura iOS: SwiftUI + SPM packages |
| 06 | `TECHNICAL_ARCHITECTURE_ANDROID.md` | Arquitectura Android: Compose + multi-module |
| 07 | `TECHNICAL_ARCHITECTURE_WEB.md` | Arquitectura Web: React + TypeScript |
| 08 | `TECHNICAL_ARCHITECTURE_BACKEND.md` | Arquitectura Backend: Go + PostgreSQL |
| 09 | `ROADMAP.md` | Timeline y estimaciones todas las plataformas |
| 10 | `COLLABORATION_GUIDE.md` | Guía de trabajo con Claude Code |
| 11 | `CURRENT_STATUS.md` | Estado actual de implementación + brechas |

**Después de completar cualquier feature, bug fix o modificación significativa**, DEBES verificar si el cambio afecta algún documento del PRD y actualizarlo:

| Tipo de cambio | Documentos del PRD a actualizar |
|----------------|--------------------------------|
| Nueva feature implementada | `02_FEATURES.md` (tabla de paridad), `11_CURRENT_STATUS.md` |
| Bug fix | `11_CURRENT_STATUS.md` (si era una brecha conocida) |
| Cambio de arquitectura iOS | `05_TECHNICAL_ARCHITECTURE_IOS.md`, `11_CURRENT_STATUS.md` |
| Cambio de arquitectura Android | `06_TECHNICAL_ARCHITECTURE_ANDROID.md`, `11_CURRENT_STATUS.md` |
| Cambio de arquitectura Web | `07_TECHNICAL_ARCHITECTURE_WEB.md`, `11_CURRENT_STATUS.md` |
| Cambio de arquitectura Backend | `08_TECHNICAL_ARCHITECTURE_BACKEND.md`, `11_CURRENT_STATUS.md` |
| Nueva dependencia agregada | Doc de arquitectura de la plataforma correspondiente |
| Cambio de monetización/precios | `04_MONETIZATION.md` |
| Nuevo competidor descubierto | `03_COMPETITIVE_ANALYSIS.md` |
| Hito del roadmap alcanzado | `09_ROADMAP.md`, `11_CURRENT_STATUS.md` |
| Nueva integración de plataforma | `02_FEATURES.md`, `11_CURRENT_STATUS.md` |
| Cambio en visión o público objetivo | `01_PRODUCT_VISION.md` |
| Cambio en flujos de trabajo con Claude | `10_COLLABORATION_GUIDE.md` |

**Esto no es opcional.** Mantener el PRD sincronizado con el codebase asegura que futuras sesiones tengan contexto preciso.

---

## Regla de Auto-Commit (OBLIGATORIA)

Después de completar cualquier corrección, cambio, mejora o nueva feature, DEBES crear un commit de git inmediatamente — no esperes a que el usuario lo solicite.

### Convención de Commits

- **Formato**: Conventional Commits → `type(scope): description`
- **Idioma**: Inglés para mensajes de commit
- **Co-autor**: Siempre incluir `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>`

### Types permitidos

| Type | Uso |
|------|-----|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `refactor` | Reestructuración sin cambio funcional |
| `docs` | Documentación (PRD, README, comentarios) |
| `test` | Agregar o modificar tests |
| `chore` | Mantenimiento, configuración, dependencias |
| `style` | Formato, linting, sin cambio funcional |
| `perf` | Mejora de rendimiento |

### Scopes permitidos

| Scope | Plataforma |
|-------|------------|
| `ios` | iOS (SwiftUI, SPM packages) |
| `android` | Android (Kotlin, Compose, Gradle) |
| `web` | Web (React, TypeScript) |
| `backend` | Backend (Go, API, DB) |
| `prd` | Documentos del PRD |
| `infra` | Infraestructura, CI/CD, Docker |

### Ejemplos

```
feat(ios): add quick quote generation from client detail
feat(android): implement inventory search with filters
fix(backend): correct event date parsing for timezone offset
fix(web): resolve payment status not updating in real-time
refactor(ios,android): extract shared validation logic
docs(prd): update feature parity table after inventory release
chore(infra): upgrade PostgreSQL to 16.x in docker-compose
test(backend): add unit tests for event repository
```

### Cuándo hacer commit

| Situación | Acción |
|-----------|--------|
| Feature implementada en una plataforma | Commit inmediatamente |
| Misma feature en múltiples plataformas | Un commit por plataforma, o uno combinado |
| Bug fix | Commit inmediatamente después de verificar |
| Refactor / mejora | Commit inmediatamente |
| Actualización del PRD o documentación | Commit inmediatamente |
| Varios cambios pequeños relacionados | Agrupar en un commit lógico |

### Qué NO hacer commit

- Trabajo incompleto (features a medio implementar)
- Archivos con secretos (`.env`, credenciales, API keys)
- Archivos generados que deberían estar en `.gitignore` (`node_modules/`, `build/`, `.gradle/`, `DerivedData/`)
- Código temporal de debug (`print()`, `console.log()` de depuración)
- Artefactos de build (`.ipa`, `.apk`, `.aab`)

**Esto no es opcional.** Commits atómicos y frecuentes crean un historial limpio y reducen el riesgo de perder trabajo.

---

## Terminología del Dominio Solennix

Estos términos deben usarse de forma consistente en toda la aplicación, UI, código y documentación:

| Término | Descripción | Contexto |
|---------|-------------|----------|
| **Evento** | Celebración o acontecimiento que el usuario organiza | Entidad principal del sistema |
| **Cliente** | Persona que contrata al organizador para un evento | Vinculado a uno o más eventos |
| **Producto** | Servicio o artículo que el organizador ofrece (ej. pastel, decoración, show) | Forma parte de la cotización |
| **Inventario** (Item de inventario) | Artículo físico que el organizador posee y puede asignar a eventos | Se rastrea cantidad disponible vs. asignada |
| **Cotización** | Presupuesto o propuesta económica para un evento | Incluye productos, extras, descuentos |
| **Contrato** | Documento legal/formal entre organizador y cliente | Se genera desde la cotización |
| **Pago** | Registro de abono o liquidación del cliente | Vinculado a un evento, puede ser parcial |
| **Equipo** (Equipment) | Artículo reutilizable del inventario (ej. mesas, sillas, manteles) | Subcategoría de inventario |
| **Insumo** (Supply) | Material consumible (ej. globos, servilletas, velas) | Subcategoría de inventario |
| **Extra** | Artículo o servicio adicional fuera del catálogo estándar | Se agrega ad-hoc a un evento |
| **Receta** (Recipe/Ingredients) | Lista de ingredientes o materiales necesarios para un producto | Vinculada a un producto |
| **Plan** | Nivel de suscripción (Gratis, Pro, Business) | Determina features disponibles |
| **Checklist** | Lista de tareas pendientes para un evento | Ayuda al seguimiento del evento |
| **Dashboard** | Panel principal con KPIs y resumen | Pantalla de inicio |

### Reglas de uso

- En la **UI**: siempre en español (el idioma de la app es español para el mercado LATAM).
- En el **código** (variables, funciones, structs, clases): inglés. Ej: `Event`, `Client`, `Product`, `InventoryItem`, `Quote`, `Contract`, `Payment`, `EventExtra`.
- En la **base de datos**: inglés con `snake_case`. Ej: `events`, `clients`, `products`, `inventory_items`, `quotes`, `contracts`, `payments`, `event_extras`.
- En **endpoints API**: inglés con `kebab-case` o `snake_case`. Ej: `/api/events`, `/api/clients`, `/api/inventory-items`.

---

## Convenciones de la App

### General

| Aspecto | Convención |
|---------|------------|
| Idioma de la UI | Español (mercado LATAM) |
| Idioma del código | Inglés |
| API base path | `/api/` |
| Autenticación | JWT Bearer tokens en header `Authorization` |
| Base de datos | PostgreSQL con columnas en `snake_case` |
| Formato de fechas API | ISO 8601 (`2026-03-20T15:30:00Z`) |
| Formato de moneda | Peso mexicano (MXN) como default, configurable por usuario |
| Zona horaria | Almacenar en UTC, mostrar en zona local del usuario |

### iOS — SwiftUI

| Aspecto | Convención |
|---------|------------|
| Framework UI | SwiftUI (no UIKit, excepto cuando sea estrictamente necesario) |
| Arquitectura | MVVM con `@Observable` (Observation framework, iOS 17+) |
| Gestión de paquetes | Swift Package Manager (SPM) |
| Estructura de paquetes | `SolennixCore` (modelos), `SolennixNetwork` (API), `SolennixFeatures` (features) |
| Navegación | `NavigationStack` + `NavigationSplitView` con enum `Route` |
| Inyección de dependencias | SwiftUI Environment (`@Environment`) |
| Async/Await | `async/await` nativo (no Combine para nuevas features) |
| Naming | `PascalCase` para tipos, `camelCase` para variables/funciones |
| Archivos de vistas | Sufijo `View.swift` (ej. `EventFormView.swift`) |
| Archivos de ViewModels | Sufijo `ViewModel.swift` (ej. `EventFormViewModel.swift`) |
| Target mínimo | iOS 17.0 |
| Proyecto | Xcode project con `project.yml` (XcodeGen) |

### Android — Kotlin / Jetpack Compose

| Aspecto | Convención |
|---------|------------|
| Framework UI | Jetpack Compose (no XML layouts) |
| Arquitectura | MVVM con `ViewModel` de AndroidX |
| Inyección de dependencias | Hilt (Dagger) |
| Estructura de módulos | Multi-module: `app`, `core/network`, `core/model`, `feature/*` |
| Navegación | Compose Navigation con type-safe routes |
| Networking | Ktor Client |
| Serialización | Kotlinx Serialization |
| Naming | `PascalCase` para clases, `camelCase` para funciones/variables |
| Archivos de UI | Sufijo `Screen.kt` (ej. `EventFormScreen.kt`) |
| Archivos de ViewModels | Sufijo `ViewModel.kt` (ej. `EventFormViewModel.kt`) |
| Min SDK | 26 (Android 8.0) |
| Build system | Gradle con Kotlin DSL |

### Web — React / TypeScript

| Aspecto | Convención |
|---------|------------|
| Framework | React 18+ con TypeScript |
| Estilos | Tailwind CSS |
| Estado global | Zustand |
| Routing | React Router |
| HTTP Client | Axios o fetch con wrapper tipado |
| Naming componentes | `PascalCase` (ej. `EventFormScreen.tsx`) |
| Naming hooks/utils | `camelCase` (ej. `useEventForm.ts`) |
| Estructura | `pages/`, `components/`, `services/`, `stores/`, `types/`, `hooks/` |
| Formularios | React Hook Form + Zod para validación |
| Build tool | Vite |

### Backend — Go

| Aspecto | Convención |
|---------|------------|
| Router | Chi (`go-chi/chi`) |
| Arquitectura | Repository pattern: `handler` → `service` → `repository` |
| Base de datos | PostgreSQL via `pgx` o `sqlx` |
| Migraciones | SQL files versionados |
| Autenticación | JWT con middleware |
| Estructura | `cmd/` (entrypoints), `internal/` (código privado), `pkg/` (código reutilizable) |
| Naming | `PascalCase` para exportados, `camelCase` para internos, `snake_case` para JSON/DB |
| Error handling | Errores explícitos (no panic), errors envueltos con `fmt.Errorf("...: %w", err)` |
| Logging | Structured logging (slog o zerolog) |
| Config | Variables de entorno (12-factor app) |
| API responses | JSON con estructura consistente: `{ "data": ..., "error": ..., "message": ... }` |

---

## Enlaces Legales

- Términos de uso: https://creapolis.dev/terms-of-use/
- Política de privacidad: https://creapolis.dev/privacy-policy/

---

## Design Context

### Users
Event organizers and service professionals in LATAM (México, Argentina, and similar markets). They manage weddings, quinceañeras, corporate events, and social gatherings. Primary device: desktop. Mobile is secondary but important for quick lookups.

**Emotional goals**: Feel in control of their business. Look professional to their clients. Reduce mental load. Eliminate the chaos of WhatsApp threads, spreadsheets, and paper notes.

### Brand Personality
Elegante · profesional · confiable

The tone of a trusted business partner for creative professionals. Warm and composed — not cold corporate, not startup-casual. References: Honeybook, Dubsado.

### Aesthetic Direction
The existing palette is correct — preserve it:
- **Primary**: `#C4A265` — warm gold. Use with intention, not decoration.
- **Accent**: `#1B2A4A` — deep navy. Anchors hierarchy and dark mode.
- **Light mode**: Warm cream/beige surfaces — inviting, not clinical.
- **Dark mode**: Navy-tinted surfaces — rich and composed.

**Anti-references**: No cyan/purple AI gradients, no glassmorphism as decoration, no generic icon+heading+text card grids, no cold enterprise SaaS aesthetic.

### Design Principles
1. **Warmth through precision** — Every pixel intentional. Gold used sparingly. Spacing generous and breathable.
2. **Professional without sterile** — Should inspire confidence, not feel like a 2015 CRM.
3. **Information-first hierarchy** — Complex data (clients, quotes, payments). The most important things must be immediately obvious.
4. **Light and dark are equally first-class** — Both modes equally polished. Dark = navy-rich, not generic gray.
5. **Typography carries the brand** — Clear scale, decisive weight contrast. No timid size differences.
