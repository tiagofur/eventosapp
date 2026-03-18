# Changelog - Solennix Native Android

Todos los cambios notables en la app nativa Android de Solennix.

---

## [1.0.0] - 2026-03-18

### Feature Parity Alcanzada

Primera version con paridad completa de features respecto a las apps Mobile (React Native) y Web.

### Agregado

#### Fase 1: Event Form Enhancement
- **6-step wizard** para creacion de eventos (antes eran 5)
- **StepEquipment**: Seleccion de equipo con deteccion de conflictos por fecha
- **StepSupplies**: Suministros sugeridos basados en productos seleccionados
- Seccion "From Stock" vs "To Purchase" en supplies
- Warnings en amber/warning para conflictos de equipo

#### Fase 2: Event Checklist
- **EventChecklistScreen**: Checklist interactivo para preparacion de eventos
- Tres secciones: Equipment, Stock Supplies, Purchase Supplies
- Persistencia de estado via DataStore
- Progress bar con porcentaje de completitud
- Integracion con exportar a PDF

#### Fase 3: Calendar Enhancements
- **Vista dual**: Toggle entre Calendar y List view
- **Filtros por status**: FilterChips para todos/pendiente/confirmado/etc
- **Busqueda**: TextField en vista lista
- **StatusBadge** en event cards
- Contador de eventos en filter chips

#### Fase 4: Photo Gallery
- **PhotoGallerySheet**: Bottom sheet para ver/agregar fotos
- Soporte para camara y galeria via `PickVisualMedia`
- Upload a servidor con loading states
- Visualizacion con Coil 3 AsyncImage
- Zoom y navegacion entre fotos

#### Fase 5: PDF Generation
- **ShoppingListPdfGenerator**: Lista de compras para eventos
- **InvoicePdfGenerator**: Factura completa con:
  - Desglose de productos y extras
  - Calculo de descuentos (% o fijo)
  - IVA desglosado
  - Historial de pagos
  - Saldo pendiente

#### Fase 6: Plan Limits & Onboarding
- **PlanLimitsManager**: Control de limites por plan
  - Basic: 3 eventos/mes, 50 clientes, 20 productos
  - Pro: Ilimitado
- **UpgradeBanner**: Banner CTA cuando se acerca al limite
- **OnboardingChecklist**: Wizard de primeros pasos
  - Crear primer cliente
  - Agregar producto/servicio
  - Crear primer evento
- Progress tracking persistente

#### Fase 7: In-App Billing
- **BillingManager**: Integracion Google Play Billing v7
- **SubscriptionScreen**: UI para ver planes y comprar
- **SubscriptionViewModel**: Estado de billing
- Soporte para `pro_monthly` ($99 MXN) y `pro_annual` ($899 MXN)
- Verificacion de purchases con backend

#### Fase 8: Lower Priority Features
- **HapticFeedbackManager**: Feedback tactil nativo
  - LIGHT_TAP, MEDIUM_TAP, HEAVY_TAP
  - SUCCESS, WARNING, ERROR
  - SELECTION_CHANGED, LONG_PRESS
- **SyncWorker**: Sincronizacion en background
  - Periodic sync cada 15 minutos
  - Network-aware (solo con conexion)
  - Battery-aware (no en bateria baja)
  - Exponential backoff retry
- **rememberHapticFeedback()**: Composable helper

### Dependencias Nuevas

```toml
billing = "7.1.1"
workmanager = "2.10.0"
```

### Archivos Clave Creados

| Archivo | Descripcion |
|---------|-------------|
| `StepEquipment.kt` | Paso equipment del wizard |
| `StepSupplies.kt` | Paso supplies del wizard |
| `EventChecklistScreen.kt` | Pantalla de checklist |
| `EventChecklistViewModel.kt` | ViewModel del checklist |
| `PhotoGallerySheet.kt` | Bottom sheet de fotos |
| `EventPhoto.kt` | Modelo de foto |
| `ShoppingListPdfGenerator.kt` | PDF de lista de compras |
| `InvoicePdfGenerator.kt` | PDF de factura |
| `PlanLimitsManager.kt` | Gestion de limites |
| `UpgradeBanner.kt` | Banner de upgrade |
| `OnboardingChecklist.kt` | Checklist de onboarding |
| `BillingManager.kt` | Google Play Billing |
| `SubscriptionScreen.kt` | UI de suscripciones |
| `SubscriptionViewModel.kt` | ViewModel de billing |
| `HapticFeedback.kt` | Utilidad de haptics |
| `SyncWorker.kt` | Worker de sincronizacion |

### Actualizados

| Archivo | Cambios |
|---------|---------|
| `CalendarScreen.kt` | Vista dual, filtros, busqueda |
| `CalendarViewModel.kt` | ViewMode, StatusFilter, search state |
| `EventFormScreen.kt` | 6 pasos (equipment + supplies) |
| `EventFormViewModel.kt` | Estado para equipment/supplies |
| `EventDetailScreen.kt` | Integracion fotos |
| `EventDetailViewModel.kt` | Estado de fotos |
| `libs.versions.toml` | Billing y WorkManager deps |
| `app/build.gradle.kts` | WorkManager y Hilt Work deps |
| `settings/build.gradle.kts` | Billing dep |

### Pendiente para v1.1

- [ ] Accessibility audit (TalkBack, font scaling)
- [ ] Performance tuning (baseline profiles, R8 optimization)
- [ ] Screenshot tests (Paparazzi)
- [ ] QA testing en dispositivos reales
- [ ] Play Store listing y metadata
- [ ] Internal testing track

---

## Estructura del Proyecto

```
android/
├── app/src/main/java/com/creapolis/solennix/
│   ├── sync/SyncWorker.kt
│   └── service/NewEventTileService.kt
├── core/
│   ├── data/plan/PlanLimitsManager.kt
│   ├── designsystem/
│   │   ├── component/UpgradeBanner.kt
│   │   └── util/HapticFeedback.kt
│   └── model/EventPhoto.kt
├── feature/
│   ├── calendar/ (actualizado)
│   ├── dashboard/ui/OnboardingChecklist.kt
│   ├── events/
│   │   ├── pdf/ShoppingListPdfGenerator.kt
│   │   ├── pdf/InvoicePdfGenerator.kt
│   │   ├── ui/EventChecklistScreen.kt
│   │   ├── ui/PhotoGallerySheet.kt
│   │   ├── ui/StepEquipment.kt
│   │   └── ui/StepSupplies.kt
│   └── settings/
│       ├── billing/BillingManager.kt
│       └── ui/SubscriptionScreen.kt
└── widget/ (sin cambios)
```

---

*Solennix Native Android v1.0.0*
