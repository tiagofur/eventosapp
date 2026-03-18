# Auditoría y Estado del Proyecto

> **Última actualización:** 2026-03-02

Este documento resume el estado general del proyecto Solennix.

## Estado Actual

- **Web**: 97% completa — producto funcional y pulido, fotos, export CSV
- **Mobile (React Native)**: 95% completa — excelente paridad con web, fotos de eventos
- **iOS Nativa (SwiftUI)**: 85% completa — Vistas core conectadas, componentes y diseño nativo premium, con paridad de características críticas (Quick Quote, Plan Limits) y onboarding TipKit.
- **Backend**: 97% completo — la mayoría de endpoints consumidos por frontends
- **Tests**: 783 tests web (100% passing), tests backend passing
- **Diseño**: Estandarizado entre plataformas (colores, iconos, UX patterns)

---

## Logros Recientes (2026-03-18)

### App Nativa iOS (Fases A a D)
- [x] **Conectividad Total Core:** Remoción de placeholders en Dashboard, Caledar y ClientList.
- [x] **Quick Quote & Pending Events:** Implementación nativa en sheets y overlays para paridad Web.
- [x] **Límites de Plan & Banners:** Integración de alertas y popover tips para bloqueos de plan básico.
- [x] **Native Polish:** Incorporación Haptics centralizada, TipKit onboarding guías, y SKStoreReview triggers.
- [x] **Gestión Error Toast:** Conexión de APIClient directo al layout overlay de ToastManager.

---

## Logros Anteriores (2026-03-02)

### Seguridad y Auth
- [x] Token refresh implementado en web y mobile (deduplicación de requests concurrentes)
- [x] Logout usa endpoint `/api/auth/logout` en ambas plataformas
- [x] Mobile almacena tokens en SecureStore (no AsyncStorage)

### Cross-Platform Feature Parity
- [x] **Skeleton loading** en listas web (Clientes, Productos, Inventario)
- [x] **Barra de progreso de cobro** en EventSummary web
- [x] **"Pagar restante" quick action** en EventSummary web
- [x] **Contacto directo** (tel/email links) en ClientList y ClientDetails web
- [x] **QuickClientSheet** — crear cliente inline en EventForm mobile
- [x] **SortSelector** — ordenamiento por columna en 3 listas mobile
- [x] **Calendario mejorado** mobile — vista dual (calendario/lista), búsqueda, filtros por status
- [x] **Pantallas legales** — About, Privacy, Terms en web
- [x] **Pago online de eventos** — ruta y botón Stripe activados

### Fotos y Export (Sesión 2)
- [x] **Upload foto de cliente** en web — preview circular, foto en lista y detalle
- [x] **Galería de fotos de eventos** — tab "Fotos" en EventSummary (web), PhotoGallery en EventDetailScreen (mobile)
- [x] **Export a CSV** — botón en ClientList, ProductList, InventoryList, CalendarView con BOM para Excel

### Documentación
- [x] CLAUDE.md actualizado con info de app React Native mobile
- [x] AGENTS.md actualizado (Flutter → React Native/Expo)
- [x] Roadmap de mejoras cross-platform documentado

---

## Logros Anteriores

- **Global Toast Notifications:** Infraestructura `useToast` para feedback inmediato.
- **Seguridad en Acciones Destructivas:** `ConfirmDialog` en todas las entidades.
- **Dashboard Mejorado:** KPIs financieros, inventario bajo, gráfica comparativa, onboarding.
- **Empty States Rediseñados:** Componente `Empty` con ilustraciones y glassmorphism.
- **Generación de PDFs:** 5 tipos (presupuesto, contrato, lista compras, reporte pagos, factura).
- **Sistema de Pagos:** Registro de abonos y saldo pendiente en tiempo real.
- **Mobile Completa:** Auth, CRUD completo, calendario, búsqueda, PDFs, suscripción RevenueCat.

---

## Pendientes por Prioridad

### Alta (completadas)
- [x] **Upload foto de cliente** en web — foto circular en formulario, display en lista y detalle
- [x] **Fotos de eventos** — galería con upload múltiple (web tab + mobile PhotoGallery)
- [x] **Export a CSV** — botón en 4 listas principales (clientes, productos, inventario, eventos)

### Alta (requieren backend + frontend)
- [ ] **Notificaciones push** (mobile) — Expo Notifications + backend service
- [ ] **Reportes/Analytics avanzados** — gráficas de tendencia, margen, top clientes

### Media
- [ ] **Activity log / Historial de cambios** — auditoría de modificaciones
- [ ] **Gráfica financiera comparativa** en Dashboard mobile (Fase 5 pendiente)
- [ ] **KPI cobrado por fecha de evento** en Dashboard mobile (Fase 5 pendiente)

### Baja (nice-to-have)
- [ ] Offline mode (mobile)
- [ ] Multi-idioma (i18n)
- [ ] Roles de usuario (admin/staff)
- [ ] Google Calendar sync
- [ ] Templates de eventos
- [ ] Duplicar evento
- [ ] Bulk actions en listas
- [ ] Dashboard configurable
- [ ] API pública / Webhooks

---

## Roadmap Sugerido (Siguiente Fase)

### Fase: Fotos y Export — COMPLETADA
- [x] Upload de foto de cliente en web
- [x] Galería de fotos de eventos (web + mobile)
- [x] Export a CSV/Excel en listas principales

### Fase: Inteligencia y Comunicación
- [ ] Notificaciones push (mobile)
- [ ] Reportes y analytics avanzados
- [ ] Recordatorios automáticos por email
