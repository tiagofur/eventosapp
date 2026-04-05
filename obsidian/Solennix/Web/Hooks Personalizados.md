# Hooks Personalizados

#web #hooks #infraestructura

> [!abstract] Resumen
> 5 custom hooks que encapsulan lógica reutilizable: autenticación, tema, notificaciones, paginación, y límites de plan.

---

## Inventario de Hooks

### useAuth

```
contexts/AuthContext.tsx → useAuth()
```

| Retorna | Tipo | Descripción |
|---------|------|-------------|
| `user` | `User \| null` | Usuario autenticado |
| `profile` | `User \| null` | Perfil completo (misma entidad) |
| `loading` | `boolean` | Cargando estado de auth |
| `checkAuth()` | `() => Promise<void>` | Re-verificar sesión |
| `signOut()` | `() => void` | Cerrar sesión |
| `updateProfile()` | `(data) => Promise<void>` | Actualizar perfil |

Usado en: Prácticamente toda la app

---

### useTheme

```
hooks/useTheme.ts (via ThemeContext)
```

| Retorna | Tipo | Descripción |
|---------|------|-------------|
| `theme` | `'light' \| 'dark'` | Tema actual |
| `isDark` | `boolean` | Shortcut para dark mode |
| `toggleTheme()` | `() => void` | Cambiar tema |

Persiste en `localStorage`. Aplica `.dark` / `.light` en `<html>`.

---

### useToast

```
hooks/useToast.ts (Zustand store)
```

| Retorna | Tipo | Descripción |
|---------|------|-------------|
| `toasts` | `Toast[]` | Lista de toasts activos |
| `addToast()` | `(msg, type) => void` | Agregar toast (auto-dismiss 3s) |
| `removeToast()` | `(id) => void` | Remover toast manualmente |

Tipos: `success`, `error`, `info`

---

### usePagination

```
hooks/usePagination.ts
```

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `data` | `T[]` | Array de datos a paginar |
| `itemsPerPage` | `number` | Ítems por página |
| `initialSortKey` | `keyof T` | Campo de sort inicial |
| `initialSortOrder` | `'asc' \| 'desc'` | Orden inicial |

| Retorna | Tipo | Descripción |
|---------|------|-------------|
| `currentData` | `T[]` | Datos de la página actual (sorted) |
| `currentPage` | `number` | Página actual |
| `totalPages` | `number` | Total de páginas |
| `totalItems` | `number` | Total de ítems filtrados |
| `handlePageChange()` | `(page) => void` | Cambiar de página |
| `handleSort()` | `(key) => void` | Cambiar sort (toggle asc/desc) |
| `sortKey` | `keyof T` | Campo actual de sort |
| `sortOrder` | `'asc' \| 'desc'` | Orden actual |

Usado en: EventList, ClientList, ProductList, InventoryList, AdminUsers

---

### usePlanLimits

```
hooks/usePlanLimits.ts
```

| Retorna | Tipo | Descripción |
|---------|------|-------------|
| `isBasicPlan` | `boolean` | Si el usuario está en plan básico |
| `canCreateEvent` | `boolean` | Si puede crear más eventos |
| `canCreateClient` | `boolean` | Si puede crear más clientes |
| `canCreateCatalogItem` | `boolean` | Si puede crear más productos |
| `eventsCount` | `number` | Eventos actuales |
| `clientsCount` | `number` | Clientes actuales |
| `catalogCount` | `number` | Productos actuales |
| `eventLimit` | `number` | Límite de eventos (3 en básico) |
| `clientLimit` | `number` | Límite de clientes (50 en básico) |
| `catalogLimit` | `number` | Límite de catálogo (20 en básico) |
| `loading` | `boolean` | Cargando conteos |

Usado con `UpgradeBanner` cuando se alcanzan los límites.

## Relaciones

- [[Manejo de Estado]] — Hooks como capa de acceso al estado
- [[Componentes Compartidos]] — Componentes que usan estos hooks
- [[Autenticación]] — useAuth
