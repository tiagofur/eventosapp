# Guia de Colaboracion con Claude Code: Solennix (4 Plataformas)

**Guia unificada para maximizar Claude Code en el desarrollo de iOS, Android, Web y Backend.**

---

## 1. Que Hace Bien Claude Code

### Backend (Go)

- **Handlers HTTP completos** -- genera endpoints REST con validacion, error handling y respuestas tipadas.
- **Repository pattern** -- queries SQL con pgx, parametros seguros, manejo de nulls.
- **Middleware** -- auth, rate limiting, CORS, security headers.
- **Migrations SQL** -- creacion de tablas, indices, constraints, ALTER TABLE.
- **Tests** -- handler tests con httptest, repository tests, mocks.
- **Modelos de datos** -- structs Go con JSON tags, validacion, relaciones.

### Web (React + TypeScript)

- **Componentes React** -- paginas completas, formularios con react-hook-form + zod, tablas, modales.
- **Servicios API** -- funciones tipadas para cada endpoint, error handling.
- **Tailwind UI** -- layouts responsivos, dark mode, componentes reutilizables.
- **Charts y dashboards** -- configuracion de recharts, KPIs, graficas.
- **PDF generation** -- templates con jsPDF, tablas, formateo.
- **Tests** -- Vitest unit tests, Playwright E2E.

### iOS (SwiftUI)

- **Vistas SwiftUI** -- pantallas completas, formularios multi-step, listas, detail views.
- **ViewModels @Observable** -- estado reactivo, llamadas API, manejo de errores.
- **Widgets WidgetKit** -- configuracion, timeline providers, UI de widget.
- **Live Activity** -- ActivityKit attributes, vistas compactas/expandidas.
- **PDF generators** -- generacion de documentos con UIGraphicsPDFRenderer.
- **SwiftData models** -- cache offline, CacheManager.
- **Navigation** -- Route enum, deep linking, Spotlight indexing.

### Android (Kotlin/Compose)

- **Compose screens** -- Material 3, formularios, listas, adaptive layouts.
- **ViewModels con Hilt** -- inyeccion de dependencias, StateFlow, estado de UI.
- **Room entities + DAOs** -- database offline, migrations, type converters.
- **Ktor client** -- configuracion HTTP, serialization, interceptors.
- **Navigation Compose** -- nav graphs, deep linking, argumentos tipados.
- **Modulos Hilt** -- provides, binds, singleton vs activity scope.

### Todas las Plataformas

- **Traduccion de patrones** -- implementar la misma logica en Go, Swift, Kotlin y TypeScript.
- **Code review** -- revision cruzada para consistencia entre plataformas.
- **Refactoring** -- mejoras de calidad, eliminacion de codigo muerto.
- **Testing** -- generacion de tests unitarios y de integracion.
- **Documentacion** -- actualizacion del PRD, comments en codigo complejo.

---

## 2. Que Requiere Intervencion Humana

| Area | Razon | Aplica a |
|------|-------|----------|
| Decisiones de diseno visual | Claude Code construye cualquier layout descrito, pero no toma decisiones esteticas subjetivas | Todas |
| Testing en dispositivos reales | Simuladores no reflejan comportamiento real (hapticos, bateria, conectividad) | Mobile |
| Problemas especificos de OEM | Comportamiento inconsistente entre fabricantes Android | Android |
| App Store / Play Store submission | Screenshots, metadata, compliance con guidelines | Mobile |
| Configuracion de Stripe | Dashboard de Stripe, webhooks, product IDs | Backend + Web |
| Certificados y firma | Signing, provisioning profiles, keystores | Mobile |
| Configuracion de dominio/DNS | SSL, subdominios, DNS records | Backend |
| Profiling de rendimiento | Instruments (iOS) y Android Profiler requieren herramientas interactivas | Mobile |
| Decisions de pricing | Precios, tiers, descuentos regionales | Negocio |
| Push notification certificates | APNs keys, Firebase config | Backend + Mobile |

---

## 3. Workflow Recomendado

### Manana (Planificacion)
1. Abrir el PRD y verificar la fase/tarea actual (consultar `PRD/09_ROADMAP.md` y `PRD/11_CURRENT_STATUS.md`).
2. Decidir que plataforma(s) se trabajan hoy.
3. Indicar a Claude Code la tarea especifica.

### Construccion (Implementacion)
4. Claude Code genera el codigo (handler + screen + ViewModel + tests).
5. Revisar el codigo generado, ajustar al gusto.
6. Pedir implementaciones especificas detalladas.
7. Ejecutar tests — si fallan, pegar el error para correccion.

### Tarde (Revision)
8. Pedir revision del codigo del dia: "Revisa todos los archivos cambiados buscando bugs y mejores practicas".
9. **Verificar paridad**: si se trabajo en una plataforma, verificar que el equivalente exista en las demas.
10. Commit con mensaje descriptivo (Conventional Commits).
11. Actualizar PRD si se completo una feature (`PRD/11_CURRENT_STATUS.md`, `PRD/02_FEATURES.md`).

---

## 4. Prompts de Inicio de Sesion

### Nueva Feature (Backend)
> "Estoy construyendo [endpoint/feature] para Solennix Backend. Lee `PRD/07_TECHNICAL_ARCHITECTURE_BACKEND.md` para contexto. Necesito un nuevo endpoint [POST /api/...] que [descripcion]. Crea el handler, repository, y actualiza router.go."

### Nueva Feature (Web)
> "Estoy construyendo [pagina/componente] para Solennix Web. Lee `PRD/08_TECHNICAL_ARCHITECTURE_WEB.md`. Necesito una nueva pagina para [descripcion]. Crea el componente, el servicio API, y agrega la ruta en App.tsx."

### Nueva Feature (iOS)
> "Estoy construyendo [feature] para Solennix iOS. Lee `PRD/05_TECHNICAL_ARCHITECTURE_IOS.md`. Necesito [descripcion]. Crea el ViewModel (@Observable), la vista SwiftUI, y actualiza la navegacion."

### Nueva Feature (Android)
> "Estoy construyendo [feature] para Solennix Android. Lee `PRD/06_TECHNICAL_ARCHITECTURE_ANDROID.md`. Necesito [descripcion]. Crea el ViewModel (Hilt), la screen Compose, y actualiza el nav graph."

### Correccion de Bug
> "Hay un bug en Solennix [plataforma]: [describir bug]. Los archivos relevantes son [listar]. Debuggea y propone un fix. Luego verifica si el mismo bug existe en las otras plataformas."

### Sesion de Refactor
> "Revisa la implementacion actual de [feature] en [plataforma]. Sugiere mejoras para: calidad de codigo, testabilidad, rendimiento. Luego implementa los cambios."

### Verificacion de Paridad Cross-Platform
> "Acabo de implementar [feature/fix] en [plataforma]. Verifica que el equivalente existe en las otras plataformas. Si hay diferencias, implementa la paridad."

### Sesion de PDFs
> "Necesito mejorar el PDF de [tipo: cotizacion/contrato/presupuesto/checklist] en [plataforma]. Lee el generador actual y mejora [formateo/contenido/diseno]. Asegurate de que coincida con las otras plataformas."

---

## 5. Integracion con SDD (Spec-Driven Development)

El workflow SDD permite planificar y ejecutar features sustanciales de forma estructurada:

1. **`/sdd-new nombre-feature`** -- Claude Code crea una propuesta enfocada.
2. **`/sdd-ff nombre-feature`** -- Fast-forward a traves de specs, diseno y desglose de tareas.
3. **`/sdd-apply nombre-feature`** -- Implementacion en lotes.
4. **`/sdd-verify nombre-feature`** -- Verificacion automatizada contra la spec.

### Cuando Usar SDD
- Features nuevas sustanciales (ej: push notifications, export CSV, WhatsApp integration).
- Refactors que tocan multiples archivos o capas.
- Cualquier cambio que requiera coordinacion entre 2+ plataformas.
- Nuevos endpoints de backend + UI correspondiente en web/mobile.

### Cuando NO Usar SDD
- Bug fixes simples de una sola plataforma.
- Cambios cosmeticos o de estilos.
- Ajustes de configuracion o environment variables.
- Actualizaciones de dependencias.

---

## 6. Regla de Paridad Cross-Platform (OBLIGATORIA)

Este es un proyecto de 4 plataformas: **iOS**, **Android**, **Web** y **Backend**.

| Plataforma cambiada | Tambien revisar y actualizar |
|---------------------|------------------------------|
| Backend (API) | iOS + Android + Web (consumidores del API) |
| Web | iOS + Android (misma feature?) + Backend (endpoint necesario?) |
| iOS | Android (paridad mobile) + Backend (endpoint necesario?) |
| Android | iOS (paridad mobile) + Backend (endpoint necesario?) |
| iOS + Android | Web (si aplica) + Backend |

### Excepciones Aceptables (no requieren paridad)

| Feature | Solo en | Razon |
|---------|---------|-------|
| Widgets (WidgetKit/Glance) | Mobile | No existe concepto en web |
| Live Activity / Dynamic Island | iOS | Feature exclusiva de Apple |
| Core Spotlight | iOS | Indexacion del sistema Apple |
| Admin panel | Web | Interfaz administrativa solo web |
| Biometric unlock | Mobile | No aplica en web |
| Siri Shortcuts | iOS | Feature exclusiva de Apple |

### Proceso
1. Implementar en la plataforma primaria.
2. **INMEDIATAMENTE** verificar/implementar en las plataformas contraparte.
3. Verificar todas antes de marcar como completo.

---

## 7. Archivos Clave para Contexto

Al iniciar cualquier sesion, cargar estos archivos segun la plataforma:

### Generales (siempre)
- `PRD/01_PRODUCT_VISION.md` — que estamos construyendo y por que
- `PRD/02_FEATURES.md` — catalogo de features con estado de paridad
- `PRD/11_CURRENT_STATUS.md` — estado actual de implementacion
- `CLAUDE.md` — convenciones del proyecto y reglas del orquestador

### Backend
- `PRD/07_TECHNICAL_ARCHITECTURE_BACKEND.md` — arquitectura Go
- `backend/internal/router/router.go` — rutas existentes
- `backend/internal/models/models.go` — modelos de dominio

### Web
- `PRD/08_TECHNICAL_ARCHITECTURE_WEB.md` — arquitectura React
- `web/src/App.tsx` — rutas y estructura
- `web/src/services/` — capa de servicios API

### iOS
- `PRD/05_TECHNICAL_ARCHITECTURE_IOS.md` — arquitectura SwiftUI
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/` — modulos de features
- `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/APIClient.swift` — red

### Android
- `PRD/06_TECHNICAL_ARCHITECTURE_ANDROID.md` — arquitectura Compose
- `android/feature/` — modulos de features
- `android/core/network/` — capa de red

---

## 8. Efectividad Estimada de Claude Code por Fase

| Fase | Backend | Web | iOS | Android | Mejor Usado Para |
|------|---------|-----|-----|---------|-------------------|
| Foundation | 70% | 75% | 65% | 65% | CRUD, scaffolding, boilerplate, modelos |
| Features/Ecosystem | 60% | 65% | 50% | 55% | Widgets, PDFs, forms, charts |
| Polish/Premium | 50% | 55% | 45% | 50% | Accessibility, tests, bug fixes |
| Launch | 30% | 40% | 35% | 30% | Store listings, landing pages |

### Donde Claude Code Ahorra Mas Tiempo
1. **Generacion de CRUD completo** (handler + repo + screen + ViewModel + tests) — ahorra 60-70% del tiempo
2. **Traduccion cross-platform** (misma feature en Swift/Kotlin/TypeScript/Go) — ahorra 50-60%
3. **PDF templates** — codigo repetitivo de formateo y layout — ahorra 70-80%
4. **Tests unitarios** — generacion formulaica — ahorra 60-70%
5. **Migraciones SQL** — CREATE TABLE, ALTER, indices — ahorra 80%

### Donde Claude Code Necesita Mas Guia
1. **Diseno visual** — describir exactamente lo que se quiere
2. **Edge cases de billing** — restore purchases, grace periods, family sharing
3. **Offline sync** — conflict resolution, merge strategies
4. **Performance** — profiling requiere herramientas interactivas

---

## 9. Tips para Maximizar Productividad

### Estrategia de Contexto
- Cargar multiples archivos relacionados a la vez (ViewModel + View + Service + Model).
- Pedir revisiones completas a traves de multiples archivos.
- Generar features completas (backend endpoint + web page + mobile screen) en una sola sesion.

### Optimizacion de Sesiones
- **Agrupar trabajo por plataforma** — no cambiar entre iOS y Android a mitad de sesion.
- **Usar sub-agentes** para tareas de investigacion (documentacion, APIs disponibles).
- **Dejar que Claude Code escriba lo repetitivo** — enfocar energia creativa en UX y decisiones de producto.
- **Sesiones diarias de code review** — prevencion barata contra deuda tecnica.

### Orden Optimo de Implementacion para Features Nuevas
1. **Backend** — endpoint API primero (todos los clientes dependen de esto)
2. **Web** — implementacion rapida para validar UX
3. **iOS** — plataforma movil mas avanzada
4. **Android** — adaptar de iOS, mantener paridad

### Commits
- Commit despues de cada unidad logica de trabajo
- Conventional Commits: `feat(ios): add event PDF export`
- Incluir siempre el scope de plataforma
- Co-author: `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>`
