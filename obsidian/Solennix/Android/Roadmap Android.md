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
| Offline-first | ❌ | ✅ (completo p/Eventos) | Android adelante |
| React Query / cache | 🔄 En progreso | N/A (Room) | — |
| Push notifications | ❌ | ✅ Activo (Firebase) | **Fase 2 OK** |
| Test coverage | ❌ 0% | 🔄 15% (Infra OK) | Ambos |
| i18n | ❌ | ❌ | Ambos |
| Analytics | ❌ | ❌ | Ambos |
| Suscripciones (billing) | ❌ | ✅ RevenueCat OK | **Fase 2 OK** |

---

## Fase 0: Blockers Críticos (Pre-Release) ✅

> [!success] Impacto: Crítico | Esfuerzo: Bajo-Medio
> Sin esto, la app NO está lista para producción.

### 0.1 Resolver Dependencia de PDFs ✅

- [x] Elegir librería: `Android PdfDocument` (nativo)
- [x] Integrar en `build.gradle.kts` (no requiere deps externas)
- [x] Verificar que los 7 generadores de PDF funcionan en runtime
- [x] Testear share sheet con PDFs generados

---

## Fase 1: Foundation (Estabilidad y Robustez) ✅

> [!success] Impacto: Alto | Esfuerzo: Medio
> Base sólida para todo lo que viene después.

### 1.1 Test Coverage Mínimo ✅

- [x] Setup: JUnit 5 + MockK + Turbine + Hilt Testing
- [x] Tests para `AuthManager` (tokens, refresh, biometric state)
- [x] Tests para repositories (sync logic, entity mapping)
- [ ] Tests para ViewModels clave (Dashboard, EventForm, EventDetail)
- [🔄] Target: 40% coverage en `core/` modules (Infraestructura lista)

### 1.2 Paginación con Paging 3 ✅

- [x] Integrar Paging 3 + room-paging
- [x] Paginar EventList (mayor volumen de datos)
- [x] Loading indicators en scroll

### 1.3 Error Handling Robusto ✅

- [x] Retry con exponential backoff (HttpRequestRetry)
- [x] Mapeo de errores server-specific (SolennixException)
- [x] Snackbar con acción "Reintentar"

### 1.4 Optimizar Recomposiciones ✅

- [x] Agregar `remember` y `derivedStateOf` donde corresponda
- [x] Keys estables en `LazyColumn` items (`itemKey`)
- [x] `distinctUntilChanged()` en Flows compuestos

---

## Fase 2: UX Excellence (Alineado con Web) ✅

> [!success] Impacto: Alto | Esfuerzo: Medio-Alto
> De "funcional" a "un placer de usar". Paridad con las mejoras planificadas en Web.

### 2.1 Push Notifications (Firebase) ✅

- [x] Completar `SolennixMessagingService`
- [x] Registrar FCM token en backend (MainActivity/onNewToken)
- [x] Canales de notificación configurados
- [x] Permiso `POST_NOTIFICATIONS` (Android 13+)

### 2.2 Suscripciones con Play Billing ✅

- [x] Completar integración RevenueCat
- [x] Flujo de "Restaurar Compras" implementado
- [x] Botón de restauración en `SubscriptionScreen`

### 2.3 Búsqueda Avanzada ✅

- [x] Filtros por rango de fechas en `EventList`
- [x] UI con `DateRangePicker` nativo y chips de filtros activos
- [x] Búsqueda combinada (Texto + Status + Fecha)

### 2.4 Drag & Drop / Reordenar ✅

- [x] Lógica de reordenación en `EventFormViewModel`
- [x] Botones de subir/bajar en productos y extras
- [x] Reactividad instantánea en el formulario

### 2.5 Sync Bidireccional ✅

- [x] Esquema Room con `syncStatus` (SYNCED, PENDING_*)
- [x] Lógica de "guardado local ante fallo" en Repositorios
- [x] `SyncWorker` refactorizado para subir cambios antes de descargar

---

## Fase 3: Polish Premium

... rest of file unchanged ...
