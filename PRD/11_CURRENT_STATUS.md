# Estado Actual del Proyecto — Solennix

**Fecha:** Marzo 2026
**Version:** 1.0

---

## 1. Estado General

| Plataforma | Estado | Notas |
|------------|--------|-------|
| Backend (Go) | Funcional ✅ | API completa, 27 migraciones, auth multi-proveedor, Stripe, RevenueCat + sync bidireccional |
| Web (React) | Funcional ✅ | Todas las paginas principales, panel admin, cotizacion rapida |
| iOS (SwiftUI) | En desarrollo 🔄 | Features principales + widgets (4 tipos) + Live Activity + 7 generadores PDF |
| Android (Jetpack Compose) | En desarrollo 🔄 | Features principales, arquitectura modular multi-feature |

---

## 2. Backend — Implementado

### Autenticacion y Usuarios
- ✅ Registro de usuario (`POST /api/auth/register`)
- ✅ Login con JWT (`POST /api/auth/login`)
- ✅ Logout con cookie httpOnly (`POST /api/auth/logout`)
- ✅ Refresh token (`POST /api/auth/refresh`)
- ✅ Forgot password (`POST /api/auth/forgot-password`)
- ✅ Reset password con token (`POST /api/auth/reset-password`)
- ✅ Google Sign-In (`POST /api/auth/google`)
- ✅ Apple Sign-In (`POST /api/auth/apple`)
- ✅ Obtener perfil (`GET /api/auth/me`)
- ✅ Cambiar contrasena (`POST /api/auth/change-password`)
- ✅ Actualizar perfil (`PUT /api/users/me`)

### Eventos
- ✅ CRUD completo (`GET/POST /api/events`, `GET/PUT/DELETE /api/events/{id}`)
- ✅ Eventos proximos (`GET /api/events/upcoming`)
- ✅ Items de evento: productos, extras, equipamiento, suministros (`GET/PUT /api/events/{id}/items`)
- ✅ Fotos de evento (`GET/POST /api/events/{id}/photos`, `DELETE /api/events/{id}/photos/{photoId}`)
- ✅ Deteccion de conflictos de equipamiento (`GET/POST /api/events/equipment/conflicts`)
- ✅ Sugerencias de equipamiento (`GET/POST /api/events/equipment/suggestions`)
- ✅ Sugerencias de suministros (`GET/POST /api/events/supplies/suggestions`)
- ✅ Pago de eventos via Stripe (`POST /api/events/{id}/checkout-session`)

### Clientes
- ✅ CRUD completo (`GET/POST /api/clients`, `GET/PUT/DELETE /api/clients/{id}`)

### Productos
- ✅ CRUD completo (`GET/POST /api/products`, `GET/PUT/DELETE /api/products/{id}`)
- ✅ Ingredientes por producto (`GET/PUT /api/products/{id}/ingredients`)
- ✅ Ingredientes en lote (`POST /api/products/ingredients/batch`)

### Inventario
- ✅ CRUD completo (`GET/POST /api/inventory`, `GET/PUT/DELETE /api/inventory/{id}`)

### Pagos
- ✅ CRUD completo (`GET/POST /api/payments`, `PUT/DELETE /api/payments/{id}`)

### Suscripciones
- ✅ Estado de suscripcion (`GET /api/subscriptions/status`)
- ✅ Checkout session Stripe (`POST /api/subscriptions/checkout-session`)
- ✅ Portal session Stripe (`POST /api/subscriptions/portal-session`)
- ✅ Webhook Stripe (`POST /api/subscriptions/webhook/stripe`)
- ✅ Webhook RevenueCat (`POST /api/subscriptions/webhook/revenuecat`)
- ✅ Debug upgrade/downgrade (admin only)

### Busqueda
- ✅ Busqueda global (`GET /api/search`) — rate limited 30/min

### Uploads
- ✅ Subida de imagenes (`POST /api/uploads/image`) — rate limited 5/min
- ✅ Servicio de archivos estaticos (`GET /api/uploads/*`) — con cache 1 ano

### Administracion
- ✅ Dashboard de estadisticas (`GET /api/admin/stats`)
- ✅ Lista de usuarios (`GET /api/admin/users`)
- ✅ Detalle de usuario (`GET /api/admin/users/{id}`)
- ✅ Upgrade de usuario (`PUT /api/admin/users/{id}/upgrade`)
- ✅ Lista de suscripciones (`GET /api/admin/subscriptions`)

### Device Tokens
- ✅ Registro de dispositivo (`POST /api/devices/register`)
- ✅ Baja de dispositivo (`POST /api/devices/unregister`)

### Fechas No Disponibles
- ✅ CRUD (`GET/POST /api/unavailable-dates`, `DELETE /api/unavailable-dates/{id}`)

### Middleware
- ✅ Recovery (panic recovery)
- ✅ CORS (origenes configurables)
- ✅ Security Headers (X-Frame-Options, CSP, HSTS, etc.)
- ✅ Logger
- ✅ Auth (JWT middleware)
- ✅ AdminOnly (verificacion de rol)
- ✅ Rate Limiting (configurable por grupo de rutas)

### Migraciones (26 total)
- ✅ 001: Tabla de usuarios
- ✅ 002: Tabla de clientes
- ✅ 003: Tabla de eventos
- ✅ 004: Tabla de productos
- ✅ 005: Tabla de inventario
- ✅ 006: Tablas de union (junction tables)
- ✅ 007: Pagos y suscripciones
- ✅ 008-011: Campos adicionales (logo, brand color, show business name)
- ✅ 012-013: Extension de suscripciones y fix de constraint
- ✅ 014: Indices y cascadas
- ✅ 015: Campos de imagen
- ✅ 016: Equipamiento de eventos
- ✅ 017: Template de contrato en usuarios
- ✅ 018: Rol de usuario (admin)
- ✅ 019: Expiracion de plan
- ✅ 020: Tipo de descuento en eventos + capacidad de equipamiento
- ✅ 021: Campo "bring to event"
- ✅ 022: Fechas no disponibles
- ✅ 023: Tipo de suministro y tabla
- ✅ 024: Excluir costo en suministros de evento
- ✅ 025: IDs OAuth de usuario
- ✅ 026: Device tokens

### Pendiente Backend
- ⬜ Push notifications (device tokens almacenados pero sin envio implementado)
- ⬜ Notificaciones por email (solo reset de contrasena implementado)
- ⬜ Verificacion de recibos de App Store / Play Store

---

## 3. Web — Implementado

### Paginas Publicas
- ✅ Landing page
- ✅ Login
- ✅ Registro
- ✅ Forgot password
- ✅ Reset password
- ✅ Acerca de (About)
- ✅ Politica de privacidad
- ✅ Terminos de servicio
- ✅ 404 Not Found

### Paginas Protegidas
- ✅ Dashboard (KPIs, resumen)
- ✅ Busqueda global
- ✅ Calendario con vista de eventos
- ✅ Lista de eventos (EventList) con filtros: Todos, Proximos, Pasados, Borradores
- ✅ Cotizacion rapida (Quick Quote)

### Eventos
- ✅ Formulario de evento (nuevo/editar) con componentes:
  - ✅ Informacion general (EventGeneralInfo)
  - ✅ Productos (EventProducts)
  - ✅ Extras (EventExtras)
  - ✅ Equipamiento (EventEquipment)
  - ✅ Suministros (EventSupplies)
  - ✅ Finanzas (EventFinancials)
  - ✅ Pagos (Payments)
- ✅ Resumen de evento (EventSummary)
- ✅ Pago exitoso de evento (EventPaymentSuccess)
- ✅ Modal de cliente rapido (QuickClientModal)
- ✅ Modal de fechas no disponibles (UnavailableDatesModal)

### Clientes
- ✅ Lista de clientes
- ✅ Detalle de cliente
- ✅ Formulario de cliente (nuevo/editar)

### Productos
- ✅ Lista de productos
- ✅ Detalle de producto
- ✅ Formulario de producto (nuevo/editar)

### Inventario
- ✅ Lista de inventario
- ✅ Detalle de inventario
- ✅ Formulario de inventario (nuevo/editar)

### Configuracion
- ✅ Settings (perfil, contrasena, negocio)
- ✅ Pricing / planes

### Admin
- ✅ Admin Dashboard (estadisticas, metricas)
- ✅ Admin Users (gestion de usuarios)

### Navegacion Web
- ✅ Sidebar desktop — 6 secciones + Config abajo (sin Cotizacion/CotizacionRapida/Buscar)
- ✅ Bottom Tab Bar mobile — 5 tabs: Inicio, Calendario, Eventos, Clientes, Mas
- ✅ Menu "Mas" mobile — Productos, Inventario, Configuracion
- ✅ QuickActionsFAB — visible solo en mobile
- ✅ CommandPalette (Cmd+K/Ctrl+K) con navegacion a /events
- ✅ Ruta /events agregada en App.tsx

### Infraestructura Web
- ✅ ProtectedRoute (autenticacion requerida)
- ✅ AdminRoute (rol admin requerido)
- ✅ Layout compartido
- ✅ AuthContext + ThemeContext
- ✅ Tests unitarios para la mayoria de paginas

---

## 4. iOS — Implementado

### Autenticacion
- ✅ Login (LoginView)
- ✅ Registro (RegisterView)
- ✅ Biometric gate (BiometricGateView)
- ✅ Forgot password (ForgotPasswordView)
- ✅ Reset password (ResetPasswordView)

### Eventos
- ✅ Lista de eventos (EventListView)
- ✅ Detalle de evento (EventDetailView)
- ✅ Formulario de evento 5 pasos (EventFormView):
  - ✅ Step 1: Informacion general (Step1GeneralView)
  - ✅ Step 2: Productos (Step2ProductsView)
  - ✅ Step 3: Extras (Step3ExtrasView)
  - ✅ Step 4: Suministros y equipamiento (Step4SuppliesEquipmentView)
  - ✅ Step 5: Finanzas (Step5FinancesView)
- ✅ Checklist de evento (EventChecklistView)
- ✅ Quick client sheet (QuickClientSheet)

### Clientes
- ✅ Lista de clientes (ClientListView)
- ✅ Detalle de cliente (ClientDetailView)
- ✅ Formulario de cliente (ClientFormView)
- ✅ Cotizacion rapida (QuickQuoteView)

### Productos
- ✅ Lista de productos (ProductListView) — con busqueda, filtros por categoria, ordenamiento
- ✅ Detalle de producto (ProductDetailView) — KPI cards (precio, costo/unidad, margen, eventos), alerta inteligente, tablas de composicion con costos, demanda por fecha con urgencia y revenue
- ✅ Formulario de producto (ProductFormView) — con gestion estructurada de ingredientes/equipo/insumos con costos estimados

### Inventario
- ✅ Lista de inventario (InventoryListView) — con busqueda, filtro stock bajo, ordenamiento
- ✅ Detalle de inventario (InventoryDetailView) — KPI cards (costo, valor en stock), pronostico de demanda, alerta inteligente 7 dias, barras de salud de stock, ajuste rapido
- ✅ Formulario de inventario (InventoryFormView)

### Calendario
- ✅ Vista de calendario (CalendarView)
- ✅ Grid de calendario (CalendarGridView)

### Dashboard
- ✅ Dashboard principal (DashboardView)
- ✅ Tarjetas KPI (KPICardView)
- ✅ Grafico de estado de eventos (EventStatusChart)
- ✅ Modal de eventos pendientes (PendingEventsModalView)

### Configuracion
- ✅ Pantalla de configuracion (SettingsView)
- ✅ Editar perfil (EditProfileView)
- ✅ Cambiar contrasena (ChangePasswordView)
- ✅ Configuracion de negocio (BusinessSettingsView)
- ✅ Defaults de contrato (ContractDefaultsView)
- ✅ Precios / planes (PricingView)
- ✅ Acerca de (AboutView)
- ✅ Privacidad (PrivacyView)
- ✅ Terminos (TermsView)

### Busqueda
- ✅ Busqueda global (SearchView)
- ✅ Core Spotlight indexing (SpotlightIndexer)

### Onboarding
- ✅ Onboarding view (OnboardingView)
- ✅ Paginas de onboarding (OnboardingPageView)

### Generacion de PDF (7 tipos)
- ✅ Presupuesto (BudgetPDFGenerator)
- ✅ Contrato (ContractPDFGenerator)
- ✅ Lista de compras (ShoppingListPDFGenerator)
- ✅ Checklist (ChecklistPDFGenerator)
- ✅ Reporte de pagos (PaymentReportPDFGenerator)
- ✅ Factura (InvoicePDFGenerator)
- ✅ Lista de equipamiento (EquipmentListPDFGenerator)

### Widgets (4 tipos)
- ✅ KPI Widget (KPIWidget)
- ✅ Eventos proximos (UpcomingEventsWidget)
- ✅ Lock Screen widget (LockScreenWidget)
- ✅ Widget interactivo (InteractiveWidget)

### Live Activity
- ✅ SolennixLiveActivityAttributes
- ✅ SolennixLiveActivityView
- ✅ LiveActivityManager

### Networking
- ✅ APIClient (actor-based, URLSession)
- ✅ AuthManager con refresh automatico de tokens
- ✅ KeychainHelper para almacenamiento seguro
- ✅ NetworkMonitor para estado de conectividad

### Helpers
- ✅ HapticsHelper (feedback haptico)
- ✅ StoreReviewHelper (solicitud de resena)
- ✅ OnboardingTips
- ✅ SentryHelper (crash reporting)
- ✅ SpotlightIndexer
- ✅ LiveActivityManager

### Navegacion
- ✅ CompactTabLayout — 5 tabs: Inicio, Calendario, Eventos, Clientes, Mas
- ✅ SidebarSplitLayout — 6 secciones + Config abajo (sin Cotizacion/CotizacionRapida/Buscar)
- ✅ MoreMenuView — 3 items: Productos, Inventario, Configuracion
- ✅ QuickActionsFAB — FAB flotante con Nuevo Evento + Cotizacion Rapida (phones)
- ✅ Botones contextuales en EventListView (iPad) — Nuevo Evento + Cotizacion Rapida
- ✅ Busqueda en topbar via .searchable()
- ✅ DeepLinkHandler
- ✅ Route + RouteDestination

### Plan Limits
- ✅ PlanLimitsManager (verificacion de limites por plan)

### Pendiente iOS
| Item | Prioridad | Notas |
|------|-----------|-------|
| Modo offline completo | P1 | SwiftData existe pero falta sincronizacion offline-first completa |
| Push notifications | P1 | Device tokens se registran pero no hay manejo de notificaciones entrantes |
| ~~StoreKit 2 flujo de compra completo~~ | ✅ | Reemplazado por RevenueCat SDK — flujo completo implementado |
| Feature gating enforcement | P0 | Limites de plan definidos pero no enforced en todas las vistas |
| ~~Apple Sign-In en UI~~ | ✅ | Wired AppleSignInService a LoginView y RegisterView |
| ~~Google Sign-In en UI~~ | ✅ | GoogleSignIn SDK integrado con GoogleSignInService |

---

## 5. Android — Implementado

### Autenticacion
- ✅ Login (LoginScreen)
- ✅ Registro (RegisterScreen)
- ✅ Google Sign-In (GoogleSignInButton — Credential Manager)
- ✅ Apple Sign-In (AppleSignInButton — WebView OAuth flow)
- ✅ Biometric gate (BiometricGateScreen)
- ✅ Forgot password (ForgotPasswordScreen)
- ✅ Reset password (ResetPasswordScreen)

### Eventos
- ✅ Lista de eventos (EventListScreen)
- ✅ Detalle de evento (EventDetailScreen)
- ✅ Formulario de evento 6 pasos (EventFormScreen):
  - ✅ StepGeneralInfo
  - ✅ StepProducts
  - ✅ StepExtras
  - ✅ StepEquipment
  - ✅ StepSupplies
  - ✅ StepSummary
- ✅ Checklist de evento (EventChecklistScreen)

### Clientes
- ✅ Lista de clientes (ClientListScreen)
- ✅ Detalle de cliente (ClientDetailScreen)
- ✅ Formulario de cliente (ClientFormScreen)
- ✅ Cotizacion rapida (QuickQuoteScreen, QuickQuoteViewModel, QuickQuotePdfGenerator)

### Productos
- ✅ Lista de productos (ProductListScreen) — con busqueda, filtros por categoria, ordenamiento (nombre/precio/categoria)
- ✅ Detalle de producto (ProductDetailScreen) — KPI cards (precio, costo/unidad, margen, eventos), alerta inteligente, tablas de composicion con costos, demanda por fecha con urgencia y revenue
- ✅ Formulario de producto (ProductFormScreen) — con gestion estructurada de ingredientes/equipo/insumos con picker de inventario y costos estimados

### Inventario
- ✅ Lista de inventario (InventoryListScreen) — con busqueda, filtro stock bajo, ordenamiento (nombre/stock/minimo/costo), costo unitario visible por item
- ✅ Detalle de inventario (InventoryDetailScreen) — KPI cards (stock, minimo, costo, valor), pronostico de demanda, alerta inteligente 7 dias, barras de salud, ajuste rapido de stock
- ✅ Formulario de inventario (InventoryFormScreen)

### Calendario
- ✅ Vista de calendario (CalendarScreen)

### Dashboard
- ✅ Dashboard principal (DashboardScreen)
- ✅ Onboarding (OnboardingScreen)

### Configuracion
- ✅ Pantalla de configuracion (SettingsScreen)
- ✅ Editar perfil (EditProfileScreen)
- ✅ Cambiar contrasena (ChangePasswordScreen)
- ✅ Configuracion de negocio (BusinessSettingsScreen)
- ✅ Defaults de contrato (ContractDefaultsScreen)
- ✅ Precios / suscripcion (PricingScreen, SubscriptionScreen)
- ✅ Acerca de (AboutScreen)
- ✅ Privacidad (PrivacyScreen)
- ✅ Terminos (TermsScreen)

### Busqueda
- ✅ Busqueda global (SearchScreen)

### Networking
- ✅ KtorClient (OkHttp engine, Ktor 3.1.0)
- ✅ AuthManager con tokens Bearer
- ✅ Content negotiation (kotlinx.serialization)

### Plan Limits
- ✅ PlanLimitsManager (verificacion de limites por plan)
- ✅ UpgradePlanDialog (prompt de upgrade)
- ✅ Enforcement en EventFormViewModel, ClientFormViewModel, ProductFormViewModel
- ✅ Enforcement en ClientListScreen, ProductListScreen

### Widgets
- ✅ QuickActionsWidget (Glance) — eventos del dia + acciones rapidas (nuevo evento, cotizacion rapida, calendario)

### Graficos
- ✅ DemandForecastChart (Canvas-based bar chart en ProductDetailScreen)

### Navegacion
- ✅ Bottom navigation — 5 tabs: Inicio, Calendario, Eventos, Clientes, Mas
- ✅ MoreMenuScreen — 3 items: Productos, Inventario, Configuracion
- ✅ QuickActionsFAB — FAB con Nuevo Evento + Cotizacion Rapida (phones)
- ✅ Botones contextuales en EventListScreen (tablet) — Nuevo Evento + Cotizacion Rapida
- ✅ SearchBar en TopAppBar
- ✅ Arquitectura modular multi-feature

### Pendiente Android
| Item | Prioridad | Notas |
|------|-----------|-------|
| ~~Widgets (Glance)~~ | ✅ | QuickActionsWidget implementado con eventos del dia + acciones rapidas |
| Generacion de PDF | P1 | No implementado (excepto QuickQuotePdfGenerator) |
| ~~Play Billing~~ | ✅ | Implementado via RevenueCat SDK |
| ~~Google Sign-In mock~~ | ✅ | Reemplazado mock con Credential Manager real |
| ~~RevenueCat sync en register/Google~~ | ✅ | Agregado logInWith despues de register y Google sign-in |
| Push notifications (FCM) | P1 | No implementado |
| Deep linking completo | P2 | Parcial |
| Navigation Rail (tablets) | P2 | Parcialmente implementado via AdaptiveNavigationRailLayout — falta completar refactor de sidebar |
| Live Activity equivalente (notificacion persistente) | P2 | No implementado |
| ~~Cotizacion rapida (Quick Quote)~~ | ✅ | QuickQuoteScreen + QuickQuoteViewModel + QuickQuotePdfGenerator |
| ~~Feature gating enforcement~~ | ✅ | PlanLimitsManager wired into EventForm, ClientForm, ProductForm + UpgradePlanDialog |
| Offline mode (Room + sync) | P1 | No implementado |

---

## 6. Tabla de Paridad Detallada

### Eventos

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Lista de eventos | ✅ | ✅ | ✅ | ✅ | Web: EventList con filtros |
| Detalle de evento | ✅ | ✅ | ✅ (Summary) | ✅ | |
| Formulario de evento | ✅ 5 pasos | ✅ 6 pasos | ✅ Multi-seccion | ✅ | Android incluye paso Summary |
| Productos en evento | ✅ | ✅ | ✅ | ✅ | |
| Extras en evento | ✅ | ✅ | ✅ | ✅ | |
| Equipamiento en evento | ✅ | ✅ | ✅ | ✅ | |
| Suministros en evento | ✅ | ✅ | ✅ | ✅ | |
| Conflictos de equipamiento | ✅ | ✅ | ✅ | ✅ | |
| Sugerencias de equipamiento | ✅ | ✅ | ✅ | ✅ | |
| Fotos de evento | ✅ | ⬜ | ⬜ | ✅ | Solo iOS tiene UI de fotos |
| Checklist de evento | ✅ | ✅ | ⬜ | ➖ | Cliente-side |
| Pago de evento (Stripe) | ⬜ | ⬜ | ✅ | ✅ | Solo web tiene checkout |
| Eventos proximos | ✅ | ✅ | ✅ | ✅ | |
| Quick client en evento | ✅ | ⬜ | ✅ | ✅ | |

### Clientes

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Lista de clientes | ✅ | ✅ | ✅ | ✅ | |
| Detalle de cliente | ✅ | ✅ | ✅ | ✅ | |
| Formulario de cliente | ✅ | ✅ | ✅ | ✅ | |
| Cotizacion rapida | ✅ | ✅ | ✅ | ➖ | Cliente-side |

### Productos

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Lista de productos | ✅ | ✅ | ✅ | ✅ | |
| Ordenamiento de lista | ✅ | ✅ | ✅ | ✅ | Nombre, Precio, Categoria |
| Detalle de producto | ✅ | ✅ | ✅ | ✅ | |
| KPI cards (precio, costo, margen, eventos) | ✅ | ✅ | ✅ | ✅ | |
| Tablas de composicion (insumos, equipo, suministros) | ✅ | ✅ | ✅ | ✅ | Con costos estimados |
| Alerta inteligente de demanda | ✅ | ✅ | ✅ | ✅ | Demanda 7 dias + revenue estimado |
| Demanda por fecha con urgencia | ✅ | ✅ | ✅ | ✅ | Badges Hoy/Manana, revenue por evento |
| Formulario de producto | ✅ | ✅ | ✅ | ✅ | |
| Gestion de ingredientes/equipo/insumos en form | ✅ | ✅ | ✅ | ✅ | Con picker de inventario y costos |
| Ingredientes | ✅ | ✅ | ✅ | ✅ | |
| Exportar CSV | ⬜ | ⬜ | ✅ | ➖ | Solo web |

### Inventario

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Lista de inventario | ✅ | ✅ | ✅ | ✅ | |
| Ordenamiento de lista | ✅ | ✅ | ✅ | ✅ | Nombre, Stock, Minimo, Costo |
| Detalle de inventario | ✅ | ✅ | ✅ | ✅ | |
| KPI cards (stock, minimo, costo, valor) | ✅ | ✅ | ✅ | ✅ | |
| Pronostico de demanda desde eventos | ✅ | ✅ | ✅ | ✅ | Calcula demanda por ingredientes de productos |
| Alerta inteligente de stock 7 dias | ✅ | ✅ | ✅ | ✅ | Critico/advertencia/OK |
| Barras de salud de stock | ✅ | ✅ | ✅ | ✅ | Stock actual vs minimo vs demanda |
| Ajuste rapido de stock | ✅ | ✅ | ✅ | ✅ | Con botones -10/-1/+1/+10 |
| Formulario de inventario | ✅ | ✅ | ✅ | ✅ | |
| Exportar CSV | ⬜ | ⬜ | ✅ | ➖ | Solo web |

### Calendario

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Vista mensual (unica vista) | ✅ | ✅ | ✅ | ✅ | Vista lista ELIMINADA — migrada a seccion Eventos |
| Fechas no disponibles (long-press) | ✅ | ✅ | 🔄 | ✅ | Web: pendiente agregar right-click. iOS: pendiente rangos en long-press |
| Gestion centralizada de bloqueos | 🔄 | ✅ | 🔄 | ✅ | iOS: crear BlockedDatesSheet. Web: expandir modal. Android: ya tiene BottomSheet |
| Toolbar simplificado | 🔄 | 🔄 | 🔄 | ➖ | Refactor pendiente: solo "Gestionar Bloqueos" + "Hoy" |
| Panel de dia seleccionado | ✅ | ✅ | ✅ | ➖ | Split view en tablet/desktop |

### Autenticacion

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Login email/password | ✅ | ✅ | ✅ | ✅ | |
| Registro | ✅ | ✅ | ✅ | ✅ | |
| Forgot password | ✅ | ✅ | ✅ | ✅ | |
| Reset password | ✅ | ✅ | ✅ | ✅ | |
| Google Sign-In | ✅ | ✅ | ✅ | ✅ | iOS: GoogleSignIn SDK, Android: Credential Manager, Web: GSI |
| Apple Sign-In | ✅ | ✅ | ✅ | ✅ | iOS: AuthenticationServices, Android: WebView OAuth, Web: Apple JS SDK |
| Biometric gate | ✅ | ✅ | ➖ | ➖ | Solo movil |
| Refresh token | ✅ | ✅ | ✅ | ✅ | |

### Dashboard

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Dashboard principal | ✅ | ✅ | ✅ | ✅ | |
| Header (saludo + fecha) | ✅ | 🔄 | ✅ | ➖ | Android Phone: pendiente agregar saludo |
| KPI cards (8) | ✅ | ✅ | ✅ | ✅ | Pendiente unificar nombre "Ventas Netas" en Android |
| Alertas de Atencion | 🔄 | ✅ | 🔄 | ✅ | NUEVO. iOS y Web: pendiente crear. Android: expandir con criterio "sin confirmar 14 dias" |
| Quick Actions (2) | 🔄 | 🔄 | 🔄 | ➖ | Pendiente reducir de 4 a 2 en tablet/desktop |
| Chart: Distribucion estados | ✅ | ✅ | ✅ | ➖ | |
| Chart: Comparacion financiera | ✅ | ✅ | ✅ | ➖ | |
| Stock Bajo | ✅ | ✅ | ✅ | ➖ | |
| Proximos Eventos | ✅ | ✅ | ✅ | ✅ | iOS: pendiente agregar dropdown cambio estado inline |
| Onboarding Checklist | ✅ | 🔄 | ✅ | ➖ | Android: pendiente agregar inline en Dashboard |
| Orden alertas primero | 🔄 | 🔄 | 🔄 | ➖ | Pendiente reordenar en las 3 plataformas |

### Pagos

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Lista de pagos | ⬜ | ⬜ | ✅ | ✅ | Solo web |
| Crear pago | ⬜ | ⬜ | ✅ | ✅ | Solo web |
| Pago de evento (Stripe) | ⬜ | ⬜ | ✅ | ✅ | Solo web |

### PDFs

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Presupuesto PDF | ✅ | ⬜ | ⬜ | ➖ | Solo iOS |
| Contrato PDF | ✅ | ⬜ | ⬜ | ➖ | Solo iOS |
| Lista de compras PDF | ✅ | ⬜ | ⬜ | ➖ | Solo iOS |
| Checklist PDF | ✅ | ⬜ | ⬜ | ➖ | Solo iOS |
| Reporte de pagos PDF | ✅ | ⬜ | ⬜ | ➖ | Solo iOS |
| Factura PDF | ✅ | ⬜ | ⬜ | ➖ | Solo iOS |
| Lista de equipamiento PDF | ✅ | ⬜ | ⬜ | ➖ | Solo iOS |

### Busqueda

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Busqueda global | ✅ | ✅ | ✅ | ✅ | |
| Spotlight / search indexing | ✅ | ⬜ | ➖ | ➖ | Solo iOS |

### Widgets y Extensiones

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| KPI Widget | ✅ | ⬜ | ➖ | ➖ | iOS only |
| Eventos proximos widget | ✅ | ✅ | ➖ | ➖ | QuickActionsWidget muestra eventos del dia |
| Lock Screen widget | ✅ | ⬜ | ➖ | ➖ | iOS only |
| Widget interactivo | ✅ | ✅ | ➖ | ➖ | QuickActionsWidget con acciones rapidas |
| Live Activity | ✅ | ⬜ | ➖ | ➖ | Android no tiene notificacion persistente |

### Suscripciones

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Ver estado de suscripcion | ✅ | ✅ | ✅ | ✅ | |
| Flujo de compra | ✅ | ✅ | ✅ (Stripe) | ✅ | iOS y Android via RevenueCat SDK, Web via Stripe |
| Portal de gestion | ⬜ | ⬜ | ✅ (Stripe) | ✅ | Solo web |
| Feature gating | 🔄 | 🔄 | 🔄 | ✅ | Backend enforced (403 structured), iOS PlanLimitsManager, Android PlanLimitsManager + UpgradePlanDialog, Web usePlanLimits |
| Webhook Stripe | ➖ | ➖ | ➖ | ✅ | |
| Webhook RevenueCat | ➖ | ➖ | ➖ | ✅ | |

### Admin

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Dashboard admin | ⬜ | ⬜ | ✅ | ✅ | Solo web |
| Gestion de usuarios | ⬜ | ⬜ | ✅ | ✅ | Solo web |
| Upgrade de usuario | ⬜ | ⬜ | ✅ | ✅ | Solo web |
| Lista de suscripciones | ⬜ | ⬜ | ✅ | ✅ | Solo web |

### Configuracion

| Feature | iOS | Android | Web | Backend | Notas |
|---------|-----|---------|-----|---------|-------|
| Editar perfil | ✅ | ✅ | ✅ | ✅ | |
| Cambiar contrasena | ✅ | ✅ | ✅ | ✅ | |
| Configuracion de negocio | ✅ | ✅ | ✅ | ✅ | |
| Defaults de contrato | ✅ | ✅ | ⬜ | ✅ | Falta en web |
| Precios / planes | ✅ | ✅ | ✅ | ✅ | |
| Acerca de | ✅ | ✅ | ✅ | ➖ | |
| Privacidad | ✅ | ✅ | ✅ | ➖ | |
| Terminos | ✅ | ✅ | ✅ | ➖ | |

---

## 7. Stack Actual

### Backend

| Capa | Tecnologia | Version | Notas |
|------|-----------|---------|-------|
| Lenguaje | Go | 1.21+ | |
| Router | chi | v5 | |
| Base de datos | PostgreSQL | 15+ | pgx/v5 driver |
| Migraciones | Custom (embed.FS) | 26 migraciones | Auto-apply on startup |
| Pagos | Stripe | API actual | Checkout Sessions + Webhooks |
| Suscripciones | RevenueCat SDK (iOS/Android) + Stripe (Web) | Webhooks bidireccionales | Cross-platform: compra en cualquier plataforma reconocida en todas |

### Web

| Capa | Tecnologia | Version | Notas |
|------|-----------|---------|-------|
| Framework | React | 18+ | |
| Routing | React Router | v6 | |
| Lenguaje | TypeScript | | |
| Estado | Context API | | AuthContext, ThemeContext |
| Build | Vite | | |

### iOS

| Capa | Tecnologia | Version | Notas |
|------|-----------|---------|-------|
| Lenguaje | Swift | 5.9+ | |
| UI | SwiftUI | iOS 17+ | |
| Arquitectura | MVVM | | ViewModels por feature |
| Networking | URLSession (actor APIClient) | Nativo | Token refresh automatico |
| Seguridad | Keychain Services | Nativo | KeychainHelper wrapper |
| Widgets | WidgetKit | iOS 17+ | 4 tipos |
| Live Activity | ActivityKit | iOS 16.1+ | |
| PDF | Core Graphics | Nativo | 7 generadores |
| Estructura | Swift Package Manager | | SolennixCore, SolennixNetwork, SolennixFeatures |
| Proyecto | Xcode Project + project.yml | | XcodeGen compatible |

### Android

| Capa | Tecnologia | Version | Notas |
|------|-----------|---------|-------|
| Lenguaje | Kotlin | 2.0+ | |
| UI | Jetpack Compose + Material 3 | | |
| Arquitectura | MVVM | | ViewModel por feature |
| DI | Hilt | | |
| Networking | Ktor | 3.1.0 | OkHttp engine |
| Serialization | kotlinx.serialization | | |
| Estructura | Multi-module Gradle | | core/network, feature/* |

---

## 8. Refactors UI/UX en Progreso (Marzo 2026)

Refactors planificados para lograr paridad total entre las 6 plataformas (iPhone, iPad, Android Phone, Android Tablet, Web Desktop, Web Mobile). Los planes detallados estan en archivos `*_REFACTOR_PLAN.md` en la raiz del proyecto.

### 8.1 Refactor de Navegacion (NAVIGATION_REFACTOR_PLAN.md)

**Estado:** En progreso — implementacion por plataforma en paralelo.

| Cambio | iOS | Android | Web | Descripcion |
|--------|-----|---------|-----|-------------|
| Bottom Tab Bar: 5 tabs | ✅ | ✅ | ✅ | Inicio, Calendario, Eventos (NUEVO), Clientes, Mas |
| Sidebar: 6+1 secciones | ✅ | 🔄 | ✅ | 6 secciones + Config abajo. Removidos: Cotizacion, Cotizacion Rapida, Buscar |
| Menu Mas: 3 items | ✅ | ✅ | ✅ | Solo Productos, Inventario, Config |
| FAB acciones rapidas | ✅ | ✅ | ✅ | Nuevo Evento + Cotizacion Rapida en phones |
| Busqueda en topbar | ✅ | ✅ | ✅ | Barra en desktop, icono en phones |
| Botones contextuales Eventos | ✅ | ✅ | ✅ | Header de EventList en tablet/desktop |
| Web Mobile bottom tab bar | ➖ | ➖ | ✅ | NUEVO: bottom tabs para web <1024px |

### 8.2 Refactor de Dashboard (DASHBOARD_REFACTOR_PLAN.md)

**Estado:** Planificado — pendiente implementacion.

| Cambio | iOS | Android | Web | Descripcion |
|--------|-----|---------|-----|-------------|
| Remover botones accion del header | 🔄 | 🔄 | 🔄 | Quick Quote, Search, Refresh → ya viven en FAB y topbar |
| Reducir Quick Actions de 4 a 2 | 🔄 | 🔄 | 🔄 | Solo Nuevo Evento + Nuevo Cliente |
| Crear widget Alertas de Atencion | 🔄 | ✅ (parcial) | 🔄 | Eventos con pago pendiente, vencidos, sin confirmar |
| Reordenar secciones | 🔄 | 🔄 | 🔄 | Alertas → KPIs → Actions → Charts → Stock → Eventos |
| Saludo en Android Phone | ➖ | 🔄 | ➖ | Agregar saludo (solo estaba en tablet) |
| Onboarding inline en Android | ➖ | 🔄 | ➖ | Agregar checklist como iOS y Web |
| Unificar nombre "Ventas Netas" | ✅ | 🔄 | ✅ | Android decia "Ventas del Mes" |

### 8.3 Refactor de Calendario (CALENDAR_REFACTOR_PLAN.md)

**Estado:** Planificado — pendiente implementacion.

| Cambio | iOS | Android | Web | Descripcion |
|--------|-----|---------|-----|-------------|
| Eliminar vista lista | 🔄 | 🔄 | 🔄 | Migrada a seccion Eventos. Eliminar toggle y codigo de lista |
| Simplificar toolbar | 🔄 | 🔄 | 🔄 | Solo "Gestionar Bloqueos" + "Hoy" |
| Renombrar titulo Web | ➖ | ➖ | 🔄 | De "Eventos" a "Calendario" |
| Crear gestion de bloqueos | 🔄 | ✅ | 🔄 | iOS: BlockedDatesSheet. Web: expandir modal |
| Long-press rangos (iOS) | 🔄 | ✅ | ➖ | Agregar campo "Fecha fin" al dialogo |
| Right-click bloqueo (Web) | ➖ | ➖ | 🔄 | onContextMenu para bloqueo rapido |
| Mover exportar CSV a Eventos | ➖ | ➖ | 🔄 | De CalendarView a EventList |

---

## 9. Resumen de Brechas Criticas

| Brecha | Plataformas Afectadas | Impacto | Esfuerzo Estimado | Prioridad |
|--------|----------------------|---------|-------------------|-----------|
| Feature gating no enforced | iOS, Web | Backend enforced (403 structured), Android PlanLimitsManager done, iOS y Web necesitan completar enforcement | 6-10h | P0 |
| ~~Play Billing no implementado~~ | ✅ | Implementado via RevenueCat SDK | 0h | ✅ |
| Push notifications no implementadas | iOS, Android | Sin engagement ni recordatorios de eventos | 15-20h | P1 |
| Generacion de PDF falta en Android | Android | Usuarios Android no pueden generar documentos | 20-25h | P1 |
| ~~Widgets falta en Android~~ | ✅ | QuickActionsWidget implementado (Glance) | 0h | ✅ |
| Modo offline incompleto en movil | iOS, Android | Sin funcionalidad sin conexion | 20-30h | P1 |
| ~~StoreKit 2 flujo incompleto~~ | ✅ | Reemplazado por RevenueCat SDK | 0h | ✅ |
| Notificaciones email limitadas | Backend | Solo reset de contrasena; sin recordatorios | 10-15h | P1 |
| ~~Google/Apple Sign-In sin UI~~ | ✅ | Implementado en todas las plataformas | 0h | ✅ |
| ~~Cotizacion rapida falta en Android~~ | ✅ | QuickQuoteScreen + QuickQuoteViewModel + QuickQuotePdfGenerator | 0h | ✅ |
| Fotos de evento falta en Android y Web | Android, Web | Solo iOS tiene galeria de fotos | 10-15h | P2 |
| Panel admin solo en web | iOS, Android | Administracion solo desde navegador | ➖ | P3 (aceptable) |
| Deep linking incompleto en Android | Android | Navegacion desde URLs externas limitada | 4-6h | P2 |
| Live Activity equivalente en Android | Android | Sin notificacion persistente durante eventos | 6-8h | P2 |
| ~~Graficos de estado en Dashboard~~ | ✅ | Implementado en las 3 plataformas (EventStatusChart + FinancialComparisonChart) | 0h | ✅ |
| Refactor Dashboard: Alertas de Atencion | iOS, Web | Widget critico para organizadores — Android tiene PendingEventsBanner, falta en iOS y Web | 6-8h | P1 |
| Refactor Calendario: Gestion de bloqueos | iOS, Web | Falta panel centralizado de gestion de bloqueos (Android tiene BottomSheet) | 4-6h | P1 |
| Refactor Calendario: Eliminar vista lista | iOS, Android, Web | Vista lista del calendario es redundante con nueva seccion Eventos | 2-4h | P1 |
