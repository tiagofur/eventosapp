# Code Review — Febrero 2025

Revisión exhaustiva del repositorio EventosApp (frontend React + backend Go).
Documento generado para dar continuidad al trabajo de corrección.

---

## Resumen ejecutivo

| Categoría | Encontrados | Corregidos | Pendientes |
|-----------|:-----------:|:----------:|:----------:|
| Bugs críticos | 7 | 7 | 0 |
| Seguridad | 3 | 3 | 0 |
| Dark mode / UI | 6 | 6 | 0 |
| Typos / i18n | 4 | 4 | 0 |
| Debug code en producción | 1 | 1 | 0 |
| Mejoras de arquitectura | 6 | 0 | 6 |

**Total: 27 issues encontrados, 21 corregidos, 6 pendientes para futuro.**

---

## CORREGIDOS (Commit 1: `ac5761d`)

### Frontend

#### 1. Typo en botón de Payments — `Payments.tsx:129`
- **Antes:** `Cambiar estado ag "Confirmado"`
- **Después:** `Cambiar estado a "Confirmado"`

#### 2. Error silencioso al crear pago — `Payments.tsx:88`
- **Problema:** Si la API fallaba al crear un pago, el error se tragaba con `logError()` sin feedback al usuario.
- **Fix:** Agregado `addToast("Error al registrar el pago.", "error")` en el catch.

#### 3. Null pointer en `client.total_spent` — `ClientDetails.tsx:133`
- **Problema:** `client.total_spent.toFixed(2)` crashea si el backend retorna `null`.
- **Fix:** `(client.total_spent ?? 0).toFixed(2)`. Mismo fix aplicado a `event.total_amount`.

#### 4. Error de carga sin feedback — `ClientDetails.tsx:31-44`
- **Problema:** Si la API falla al cargar un cliente, el usuario ve "Cliente no encontrado" en vez de un mensaje de error real.
- **Fix:** Agregado estado `error` con UI de feedback y botón para volver.

#### 5. Race condition con `setTimeout` — `EventForm.tsx:352`
- **Problema:** `setTimeout(() => setValue("client_id", ...), 100)` — el delay de 100ms es arbitrario y puede fallar en dispositivos lentos.
- **Fix:** Reemplazado con `queueMicrotask()` que ejecuta después del flush de React state.

#### 6. Descuento sin validación — `EventProducts.tsx:107`
- **Problema:** El campo de descuento permitía valores mayores al precio unitario, generando precios negativos.
- **Fix:** Agregado `max={item.price}` y validación `val <= item.price` en el onChange.

#### 7. Errores de punto flotante en cálculos financieros — `EventForm.tsx:245-250`
- **Problema:** Cálculos de descuento, IVA y total acumulaban errores de floating-point (ej: `$1000.0000000001`).
- **Fix:** Cada paso intermedio usa `Math.round(x * 100) / 100` para redondear a 2 decimales.

### Backend

#### 8. CORS: credentials enviado a orígenes no permitidos — `cors.go:25`
- **Problema:** `Access-Control-Allow-Credentials: true` se enviaba siempre, incluso para orígenes no whitelisteados. Viola la spec CORS y puede filtrar credenciales.
- **Fix:** Solo se envía `Allow-Credentials` dentro del `if originsSet[origin]`.

#### 9. Webhook RevenueCat sin validación — `subscription_handler.go:232`
- **Problema:** Si `REVENUECAT_WEBHOOK_SECRET` estaba vacío, el webhook aceptaba cualquier request sin verificar.
- **Fix:** Ahora retorna 500 si el secret no está configurado, rechazando todo.

#### 10. Error de JSON encoding ignorado — `helpers.go:12`
- **Problema:** `json.NewEncoder(w).Encode(data)` ignoraba errores de serialización.
- **Fix:** Agregado `if err := ...; err != nil { slog.Error(...) }`.

#### 11. Errores de `UpdateClientStats` ignorados — `crud_handler.go:260,296,321`
- **Problema:** `_ = h.eventRepo.UpdateClientStats(...)` descartaba errores silenciosamente, las estadísticas del cliente podían quedar desincronizadas.
- **Fix:** Reemplazado con `slog.Warn()` para loguear errores.

#### 12. Nil pointer en Login — `auth_handler.go:116`
- **Problema:** Si `GetByEmail` retornaba `nil` sin error, `user.PasswordHash` causaba panic.
- **Fix:** Agregado `|| user == nil` al check.

---

## CORREGIDOS (Commit 2: `3332799`)

#### 13. Hover color incorrecto en Register — `Register.tsx:195`
- **Problema:** Botón de registro usaba `hover:bg-brand-green` (verde) mientras el resto de la app usa naranja.
- **Fix:** Cambiado a `hover:bg-orange-600`.

#### 14. Error alert sin dark mode — `Register.tsx:95`
- **Problema:** Fondo blanco fijo (`bg-red-50`) y texto oscuro (`text-red-700`), ilegible en dark mode.
- **Fix:** Agregado `dark:bg-red-900/20`, `dark:border-red-800`, `dark:text-red-300`.

#### 15. `console.log` en producción — `Login.tsx:39`
- **Problema:** `console.log('Login response:', res)` dejado en producción, expone datos sensibles en la consola.
- **Fix:** Eliminado junto con el `console.error` redundante.

#### 16. Error alert sin dark mode — `Login.tsx:101`
- **Fix:** Mismo patrón que Register — agregadas clases dark mode.

#### 17. ForgotPassword sin dark mode — `ForgotPassword.tsx` (página completa)
- **Problema:** Toda la página usaba fondos blancos/grises sin variantes dark. También usaba un logo externo de Tailwind UI (`tailwindui.com`) y colores azules inconsistentes con el brand naranja.
- **Fix:** Dark mode completo, eliminado logo externo, colores alineados a `brand-orange`.

#### 18. Tildes faltantes — `Search.tsx:81,82,55,124`
- `operacion` → `operación`
- `termino` → `término`
- `busqueda` → `búsqueda` (en 2 lugares)

#### 19. Error silencioso en Dashboard — `Dashboard.tsx:126-128`
- **Problema:** Si la carga de eventos del mes fallaba, el error solo se logueaba, el usuario no veía nada.
- **Fix:** Agregado `setError("Error al cargar los datos del mes. Intenta recargar.")`.

---

## PENDIENTES (Para futuro)

### P1. Rate limiting en endpoints de auth
- **Archivo:** `backend/internal/router/router.go`
- **Riesgo:** Los endpoints `/api/auth/login` y `/api/auth/register` no tienen rate limiting, vulnerables a fuerza bruta.
- **Recomendación:** Agregar middleware de rate limiting (ej: `golang.org/x/time/rate` o `github.com/ulule/limiter`). Mínimo 5 intentos/minuto por IP en login.

### P2. N+1 queries en ingredientes de productos
- **Archivo:** `web/src/services/productService.ts:45-58`
- **Problema:** `getIngredientsForProducts()` hace una llamada API individual por cada producto (`Promise.all` con N requests). Con 20 productos = 20 API calls.
- **Recomendación:** Crear un endpoint batch en el backend: `POST /api/products/ingredients/batch` que acepte un array de product IDs.

### P3. Casts `as any` en resolvers de formularios
- **Archivos:**
  - `web/src/pages/Events/EventForm.tsx:111` — `zodResolver(eventSchema) as any`
  - `web/src/pages/Products/ProductForm.tsx:43` — `zodResolver(productSchema) as any`
  - `web/src/pages/Inventory/InventoryForm.tsx:46` — `zodResolver(inventorySchema) as any`
- **Problema:** Pérdida de type safety. El cast existe porque los tipos de zod no coinciden exactamente con los de react-hook-form.
- **Recomendación:** Investigar si actualizar `@hookform/resolvers` resuelve la incompatibilidad, o crear tipos wrapper.

### P4. Composite indexes faltantes en la base de datos
- **Archivos:** `backend/internal/database/migrations/`
- **Problema:** Las queries más frecuentes filtran por `(user_id, event_date)` pero no hay un composite index.
- **Recomendación:** Crear migración `014_add_composite_indexes.up.sql`:
  ```sql
  CREATE INDEX IF NOT EXISTS idx_events_user_date ON events(user_id, event_date);
  CREATE INDEX IF NOT EXISTS idx_clients_user_name ON clients(user_id, name);
  ```

### P5. `ON DELETE CASCADE` faltante en payments
- **Archivo:** `backend/internal/database/migrations/007_create_payments_subscriptions.up.sql:5`
- **Problema:** `user_id UUID NOT NULL REFERENCES users(id)` sin `ON DELETE CASCADE`. Si se elimina un usuario, los pagos quedan huérfanos. Inconsistente con las demás tablas que sí usan CASCADE.
- **Recomendación:** Crear migración para agregar el CASCADE:
  ```sql
  ALTER TABLE payments DROP CONSTRAINT payments_user_id_fkey;
  ALTER TABLE payments ADD CONSTRAINT payments_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
  ```

### P6. Carga de calendario sin paginación
- **Archivo:** `web/src/pages/Calendar/CalendarView.tsx:45-46`
- **Problema:** Carga todos los eventos de 2 años (año anterior + año siguiente). Con muchos eventos puede ser lento.
- **Recomendación:** Cargar solo el mes visible + 1 mes de buffer a cada lado, y hacer fetch dinámico al navegar.

---

## Archivos modificados (referencia rápida)

### Commit 1 — `ac5761d` — Bugs críticos y seguridad
```
backend/internal/handlers/auth_handler.go
backend/internal/handlers/crud_handler.go
backend/internal/handlers/helpers.go
backend/internal/handlers/subscription_handler.go
backend/internal/middleware/cors.go
web/src/pages/Clients/ClientDetails.tsx
web/src/pages/Events/EventForm.tsx
web/src/pages/Events/components/EventProducts.tsx
web/src/pages/Events/components/Payments.tsx
```

### Commit 2 — `3332799` — Dark mode, UI, typos
```
web/src/pages/Dashboard.tsx
web/src/pages/ForgotPassword.tsx
web/src/pages/Login.tsx
web/src/pages/Register.tsx
web/src/pages/Search.tsx
```

### Branch: `claude/code-review-improvements-aF2ks`
