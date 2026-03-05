# Screen Improvements — Marzo 2026

**Branch:** `claude/screen-improvement-review-czfoL`
**Inicio:** 5 de marzo de 2026
**Objetivo:** Alinear todas las pantallas web al design system (`primary`, `error`, `premium-gradient`, tipografía `font-black tracking-tight`) y mejorar la utilidad de las pantallas de detalle.

---

## Criterios de mejora aplicados

| Criterio | Antes | Después |
|---|---|---|
| Títulos de página | `font-bold text-text` | `font-black tracking-tight text-text` |
| Botones CTA primarios | `bg-brand-orange hover:bg-orange-600` | `premium-gradient hover:opacity-90` |
| Color de acento | `text-brand-orange` / `text-red-*` | `text-primary` / `text-error` |
| Inputs focus ring | `focus:ring-brand-orange` | `focus:ring-primary/40` |
| Estado de carga | `animate-spin` spinner | `SkeletonTable` / `SkeletonCard` |
| Estado de error | `text-red-500` | `text-error` |
| Alertas | `bg-red-50 dark:bg-red-900/20 text-red-700` | `bg-error/5 border-error/30 text-error` |
| Precios | `.toFixed(2)` | `.toLocaleString('es-MX', { minimumFractionDigits: 2 })` |
| Avatar sin imagen | `bg-surface-alt text-text-secondary` | `bg-primary/10 text-primary` |
| Colores hardcoded | `gray-500 dark:gray-400` | `text-text-secondary` |

---

## Pantallas completadas ✅

### Auth / Landing
| Pantalla | Archivo | Cambios principales |
|---|---|---|
| Landing | `Landing.tsx` | Rediseño split-panel, secciones de features, testimonios |
| Login | `Login.tsx` | Split-panel layout, diseño visual mejorado |
| Register | `Register.tsx` | Split-panel layout, consistencia con Login |
| ForgotPassword | `ForgotPassword.tsx` | Split-panel layout |

### Dashboard
| Pantalla | Archivo | Cambios principales |
|---|---|---|
| Dashboard | `Dashboard.tsx` | Rediseño KPI cards, sección upcoming events, tokens primary |

### Clientes
| Pantalla | Archivo | Cambios principales |
|---|---|---|
| Lista de clientes | `Clients/ClientList.tsx` | font-black, premium-gradient, badges emerald, toLocaleString, primary tokens |
| Detalle de cliente | `Clients/ClientDetails.tsx` | StatusBadge local, tabla de historial de eventos, premium-gradient "Nuevo Evento", primary tokens |

### Productos
| Pantalla | Archivo | Cambios principales |
|---|---|---|
| Lista de productos | `Products/ProductList.tsx` | font-black, premium-gradient, bg-primary/10 avatar, font-semibold nombre, toLocaleString, primary badge categoría |
| Detalle de producto | `Products/ProductDetails.tsx` | Skeleton loading, primary tokens, preview imagen/placeholder, toLocaleString, font-semibold headings |
| Formulario de producto | `Products/ProductForm.tsx` | text-text-secondary, premium-gradient save, border-error alert, primary focus ring, primary Layers icon |

### Inventario
| Pantalla | Archivo | Cambios principales |
|---|---|---|
| Lista de inventario | `Inventory/InventoryList.tsx` | error tokens (alertas, low stock), primary tokens (sección Consumibles, modal ajuste) |
| Detalle de inventario | `Inventory/InventoryDetails.tsx` | **Rediseño completo** — ver sección dedicada abajo |

#### InventoryDetails — Rediseño completo
- **4 KPI cards**: Stock Actual (rojo si bajo mínimo) · Stock Mínimo · Costo Unitario · Valor en Stock
- **Panel "Demanda por Fecha"**: carga eventos confirmados futuros → productos por evento → ingredientes en batch → calcula demanda real de este ítem por fecha de evento. Lista con dots de urgencia (rojo/amarillo/neutro).
- **Card de alerta inteligente**: calcula demanda próximos 7 días vs stock actual y muestra uno de: "¡Stock insuficiente! Faltan X unidades", "Stock quedará bajo el mínimo", "Stock suficiente", "Sin demanda próxima"
- **Barras de nivel de stock**: Stock actual · Mínimo recomendado · Demanda 7 días con colores coherentes

### Eventos
| Pantalla | Archivo | Cambios principales |
|---|---|---|
| Formulario de evento | `Events/EventForm.tsx` | font-black title, spinner primary, step indicator primary, error alert error tokens, save button premium-gradient |
| Resumen/detalle de evento | `Events/EventSummary.tsx` | spinner, tabs hover, dropdown bg, progress bar track, signature borders, section icons → primary; status CONFIG preserved |
| Info general del evento | `Events/components/EventGeneralInfo.tsx` | client link primary, error messages text-error, focus rings primary |
| Productos del evento | `Events/components/EventProducts.tsx` | remove button text-error, focus rings primary, gray text → text-text-secondary |
| Extras del evento | `Events/components/EventExtras.tsx` | remove button, checkboxes, focus rings, subtotal label → primary/error tokens |
| Equipo del evento | `Events/components/EventEquipment.tsx` | icon primary, info box primary, focus rings primary, remove button text-error |
| Financieros del evento | `Events/components/EventFinancials.tsx` | checkbox text-primary, all focus rings primary, total amount text-primary |
| Pagos del evento | `Events/components/Payments.tsx` | pending banner primary, CTA buttons premium-gradient, progress bar primary, balance card error tokens |
| Modal cliente rápido | `Events/components/QuickClientModal.tsx` | labels text-text-secondary, inputs border-border/bg-card, validation text-error, submit premium-gradient |
| Pago exitoso | `Events/EventPaymentSuccess.tsx` | loading text-primary, error state text-error/border-error tokens |

---

## Pantallas pendientes 🔲

### Prioridad Alta (mayor uso por el usuario)

| Pantalla | Archivos | Tokens pendientes aprox. | Notas |
|---|---|---|---|
| Formulario de cliente | `Clients/ClientForm.tsx` | ~16 | Aún tiene gray-500, red-* |
| Formulario de inventario | `Inventory/InventoryForm.tsx` | ~18 | brand-orange en focus rings |

### Prioridad Media

| Pantalla | Archivos | Tokens pendientes aprox. | Notas |
|---|---|---|---|
| Configuración | `Settings.tsx` | ~40 | Perfil, branding, contratos |
| Calendario | `Calendar/CalendarView.tsx` | ~25 | Vista mensual/semanal |
| Búsqueda | `Search.tsx` | ~24 | Búsqueda global |
| Pago exitoso | `Events/EventPaymentSuccess.tsx` | ~10 | Pantalla post-pago Stripe |
| Restablecimiento contraseña | `ResetPassword.tsx` | ~18 | Flujo desde email |

### Prioridad Baja (raramente visitadas)

| Pantalla | Archivos | Tokens pendientes aprox. | Notas |
|---|---|---|---|
| Precios | `Pricing.tsx` | ~9 | Página pública de planes |
| Acerca de | `About.tsx` | ~19 | Página informativa |
| Términos | `Terms.tsx` | 0 | Solo texto |
| Privacidad | `Privacy.tsx` | 0 | Solo texto |
| No encontrado | `NotFound.tsx` | ~5 | 404 |
| Admin Dashboard | `Admin/AdminDashboard.tsx` | — | Solo para admins internos |
| Admin Users | `Admin/AdminUsers.tsx` | — | Solo para admins internos |

---

## Componentes compartidos — estado

| Componente | Estado | Notas |
|---|---|---|
| `Layout.tsx` | ✅ Sin cambios necesarios | Nav y sidebar ya usan tokens correctos |
| `Skeleton.tsx` | ✅ OK | `SkeletonTable`, `SkeletonCard`, `SkeletonLine` disponibles |
| `ConfirmDialog.tsx` | ✅ OK | Ya usa design system |
| `UpgradeBanner.tsx` | ✅ OK | Ya usa design system |
| `Pagination.tsx` | ✅ OK | Ya usa tokens |
| `Empty.tsx` | ✅ OK | Acepta `action` prop para CTA |

---

## Próximos pasos recomendados

1. **Eventos** (`EventSummary` + todos sus sub-componentes) — es la pantalla más crítica y la que más uso tiene
2. **ClientForm** e **InventoryForm** — para completar el ciclo CRUD de las secciones ya mejoradas
3. **Settings** — alta visibilidad para usuarios frecuentes
4. **Calendar** y **Search** — completar la experiencia de navegación
