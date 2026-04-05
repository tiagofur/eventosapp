#android #roadmap #mejoras

# Roadmap Android — Hacia la Paridad y Más Allá

> [!tip] Filosofía
> Priorizado por **impacto en usuario** × **esfuerzo técnico**. Alineado con el [[Roadmap Web]] para mantener paridad cross-platform. Las fases son incrementales — cada una deja la app shippable.

---

## Estado de Paridad con Web

| Feature | Web | Android | Gap |
|---------|-----|---------|-----|
| CRUD Eventos | ✅ | ✅ | — |
| CRUD Clientes | ✅ | ✅ | — |
| CRUD Productos | ✅ | ✅ | — |
| CRUD Inventario | ✅ | ✅ | — |
| Registro de pagos | ✅ | ✅ | — |
| Calendario | ✅ | ✅ | — |
| Dashboard con KPIs | ✅ | ✅ | — |
| Generación de PDFs | ✅ Funcional | ✅ Nativo (PdfDocument) | **Fase 0 OK** |
| Pagos online (Stripe) | ✅ Stripe | ❌ Solo registro manual | Fase 3 |
| Onboarding checklist | ✅ | ✅ | — |
| Cotización rápida | ✅ | ✅ | — |
| Detección conflictos equipo | ✅ | ✅ | — |
| Sugerencias equipo/insumos | ✅ | ✅ | — |
| Búsqueda global | ✅ | ✅ + App Search | Android adelante |
| Dark mode | ✅ | ✅ | — |
| Auth biométrica | ❌ | ✅ | Android adelante |
| Widgets home screen | ❌ | ✅ | Android adelante |
| Quick Settings tile | ❌ | ✅ | Android adelante |
| Deep links | ❌ | ✅ | Android adelante |
| Offline-first | ❌ | ✅ (parcial) | Android adelante |
| React Query / cache | 🔄 En progreso | N/A (Room) | — |
| Push notifications | ❌ | ⚠️ Stub | **P1** |
| Test coverage | ❌ 0% | 🔄 15% (Infra OK) | Ambos |
| i18n | ❌ | ❌ | Ambos |
| Analytics | ❌ | ❌ | Ambos |
| Suscripciones (billing) | ❌ | ⚠️ RevenueCat stub | **P1** |

---

## Fase 0: Blockers Críticos (Pre-Release)

> [!success] Impacto: Crítico | Esfuerzo: Bajo-Medio
> Sin esto, la app NO está lista para producción.

### 0.1 Resolver Dependencia de PDFs ✅

- [x] Elegir librería: `Android PdfDocument` (nativo)
- [x] Integrar en `build.gradle.kts` (no requiere deps externas)
- [x] Verificar que los 7 generadores de PDF funcionan en runtime
- [x] Testear share sheet con PDFs generados

**Por qué**: Resuelto usando la API nativa de Android para máxima ligereza.

### 0.2 Migraciones de Room Incrementales

- [ ] Reemplazar `fallbackToDestructiveMigration` por migraciones versionadas
- [ ] Crear `Migration(4, 5)` como template
- [ ] Documentar proceso de migración para futuros cambios de schema

### 0.3 SSL Pinning

- [ ] Configurar `CertificatePinner` en OkHttp/Ktor
- [ ] Agregar pins para `api.solennix.com`
- [ ] Manejar rotación de certificados

---

## Fase 1: Foundation (Estabilidad y Robustez) ✅

> [!success] Impacto: Alto | Esfuerzo: Medio
> Base sólida para todo lo que viene después.

### 1.1 Test Coverage Mínimo ✅

- [x] Setup: JUnit 5 + MockK + Turbine + Hilt Testing
- [x] Tests para `AuthManager` (tokens, refresh, biometric state)
- [x] Tests para repositories (sync logic, entity mapping)
- [ ] Tests para ViewModels clave (Dashboard, EventForm, EventDetail)
- [ ] Tests para type converters de Room
- [🔄] Target: 40% coverage en `core/` modules (Infraestructura lista)

### 1.2 Paginación con Paging 3 ✅

- [x] Integrar Paging 3 + room-paging
- [x] Paginar EventList (mayor volumen de datos)
- [ ] Paginar ClientList, ProductList, InventoryList
- [x] Loading indicators en scroll

### 1.3 Error Handling Robusto ✅

- [x] Retry con exponential backoff en API calls regulares (HttpRequestRetry)
- [x] Mapeo de errores server-specific para mensajes contextuales (ApiService wrap)
- [x] Snackbar con acción "Reintentar" en errores de red
- [ ] Estado offline visible en UI (banner "Sin conexión")

### 1.4 Optimizar Recomposiciones ✅

- [ ] Auditar con Composition Tracing
- [x] Agregar `remember` y `derivedStateOf` donde corresponda
- [x] Keys estables en `LazyColumn` items (`itemKey`)
- [x] `distinctUntilChanged()` en Flows compuestos (`debounce` + grouping)

---

## Fase 2: UX Excellence (Alineado con Web)

> [!success] Impacto: Alto | Esfuerzo: Medio-Alto
> De "funcional" a "un placer de usar". Paridad con las mejoras planificadas en Web.

### 2.1 Push Notifications (Firebase)

- [ ] Completar `FirebaseMessagingService`
- [ ] Registrar FCM token en backend
- [ ] Notificaciones de eventos próximos (backend-driven)
- [ ] Notificaciones de pagos recibidos
- [ ] Deep links desde notificaciones
- [ ] Notification channels por tipo (eventos, pagos, sistema)

### 2.2 Suscripciones con Play Billing

- [ ] Completar integración RevenueCat → Play Billing
- [ ] Flujo de compra en `PricingScreen`
- [ ] Verificación de suscripción server-side
- [ ] Enforcing de plan limits en features premium
- [ ] Restore purchases
- [ ] Manejo de grace period y billing retry

### 2.3 Búsqueda Avanzada

- [ ] Filtros combinables en EventList (fecha + status + cliente)
- [ ] Búsqueda por rango de fechas
- [ ] Filtros en ClientList, ProductList, InventoryList
- [ ] Chips de filtros activos con clear

### 2.4 Drag & Drop en Evento

- [ ] Reordenar productos dentro del evento
- [ ] Reordenar extras
- [ ] Feedback háptico durante drag
- [ ] `LazyColumn` con `dragAndDropModifier`

### 2.5 Sync Bidireccional

- [ ] Detectar cambios locales pendientes de sync
- [ ] Queue de operaciones offline
- [ ] Sync de cambios locales → server cuando hay conexión
- [ ] Resolución básica de conflictos (last-write-wins o prompt al usuario)
- [ ] Indicador visual de datos pendientes de sync

---

## Fase 3: Polish Premium

... rest of file unchanged ...
