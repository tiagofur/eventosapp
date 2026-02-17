# API Endpoints

Documentación completa de los endpoints del backend Go para la app Flutter.

## 🔗 Base URL

```
Development: http://localhost:8080
Production: https://api.eventosapp.com
```

## 📝 Headers

### Request Headers

```dart
{
  'Content-Type': 'application/json',
  'Authorization': 'Bearer {access_token}',
}
```

### Response Headers

```dart
{
  'Content-Type': 'application/json',
}
```

---

## 🔐 Auth Endpoints

### Register
**POST** `/api/auth/register`

Registra un nuevo usuario.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "business_name": null,
    "default_deposit_percent": null,
    "default_cancellation_days": null,
    "default_refund_percent": null,
    "plan": "basic",
    "stripe_customer_id": null,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "tokens": {
    "access_token": "jwt_token",
    "refresh_token": "jwt_token",
    "expires_in": 3600
  }
}
```

### Login
**POST** `/api/auth/login`

Inicia sesión con email y contraseña.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    ...
  },
  "tokens": {
    "access_token": "jwt_token",
    "refresh_token": "jwt_token",
    "expires_in": 3600
  }
}
```

### Refresh Token
**POST** `/api/auth/refresh`

Renueva el access token usando el refresh token.

**Request Body:**
```json
{
  "refresh_token": "jwt_token"
}
```

**Response (200 OK):**
```json
{
  "access_token": "new_jwt_token",
  "refresh_token": "new_jwt_token",
  "expires_in": 3600
}
```

### Forgot Password
**POST** `/api/auth/forgot-password`

Envía email de recuperación de contraseña.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset email sent"
}
```

### Get Current User
**GET** `/api/auth/me`

Obtiene el perfil del usuario autenticado.

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200 OK):**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "name": "John Doe",
  "business_name": "My Business",
  "default_deposit_percent": 50.0,
  "default_cancellation_days": 15.0,
  "default_refund_percent": 0.0,
  "plan": "premium",
  "stripe_customer_id": null,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### Update Profile
**PUT** `/api/users/me`

Actualiza el perfil del usuario.

**Request Body:**
```json
{
  "name": "John Doe Updated",
  "business_name": "Updated Business",
  "default_deposit_percent": 50.0,
  "default_cancellation_days": 15.0,
  "default_refund_percent": 0.0
}
```

**Response (200 OK):**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "name": "John Doe Updated",
  ...
}
```

---

## 👥 Clients Endpoints

### List Clients
**GET** `/api/clients`

Obtiene la lista de clientes del usuario.

**Headers:**
```
Authorization: Bearer {access_token}
```

**Query Parameters:**
- `search` (optional): Buscar por nombre, email, teléfono
- `page` (optional): Número de página (default 1)
- `limit` (optional): Ítems por página (default 20)

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "name": "Jane Smith",
    "phone": "+52 55 1234 5678",
    "email": "jane@example.com",
    "address": "123 Main St",
    "city": "Mexico City",
    "notes": "VIP client",
    "total_events": 5,
    "total_spent": 25000.00,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

### Get Client
**GET** `/api/clients/{id}`

Obtiene un cliente por ID.

**Response (200 OK):**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "name": "Jane Smith",
  ...
}
```

### Create Client
**POST** `/api/clients`

Crea un nuevo cliente.

**Request Body:**
```json
{
  "name": "Jane Smith",
  "phone": "+52 55 1234 5678",
  "email": "jane@example.com",
  "address": "123 Main St",
  "city": "Mexico City",
  "notes": "VIP client"
}
```

**Response (201 Created):**
```json
{
  "id": "uuid",
  "name": "Jane Smith",
  ...
}
```

### Update Client
**PUT** `/api/clients/{id}`

Actualiza un cliente.

**Request Body:** (mismo que create)

**Response (200 OK):** (mismo que create)

### Delete Client
**DELETE** `/api/clients/{id}`

Elimina un cliente.

**Response (204 No Content)**

---

## 📅 Events Endpoints

### List Events
**GET** `/api/events`

Obtiene la lista de eventos del usuario.

**Headers:**
```
Authorization: Bearer {access_token}
```

**Query Parameters:**
- `client_id` (optional): Filtrar por cliente
- `start` (optional): Fecha inicio (ISO 8601)
- `end` (optional): Fecha fin (ISO 8601)
- `status` (optional): Filtrar por status (quoted, confirmed, completed, cancelled)
- `page` (optional): Número de página
- `limit` (optional): Ítems por página

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "client_id": "uuid",
    "clients": {
      "name": "Jane Smith"
    },
    "event_date": "2024-06-15",
    "start_time": "18:00",
    "end_time": "23:00",
    "service_type": "Boda",
    "num_people": 150,
    "status": "confirmed",
    "discount": 0,
    "requires_invoice": true,
    "tax_rate": 16.0,
    "tax_amount": 3200.00,
    "total_amount": 23200.00,
    "location": "Grand Hotel",
    "city": "Mexico City",
    "deposit_percent": 50.0,
    "cancellation_days": 15.0,
    "refund_percent": 0.0,
    "notes": "Requiere DJ",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

### Get Upcoming Events
**GET** `/api/events/upcoming`

Obtiene los próximos eventos.

**Query Parameters:**
- `limit` (optional): Número de eventos (default 5)

**Response (200 OK):** (mismo que List Events)

### Get Event
**GET** `/api/events/{id}`

Obtiene un evento por ID con datos relacionados.

**Response (200 OK):**
```json
{
  "id": "uuid",
  ...
  "clients": {
    "id": "uuid",
    "name": "Jane Smith",
    "phone": "+52 55 1234 5678",
    ...
  }
}
```

### Create Event
**POST** `/api/events`

Crea un nuevo evento.

**Request Body:**
```json
{
  "client_id": "uuid",
  "event_date": "2024-06-15",
  "start_time": "18:00",
  "end_time": "23:00",
  "service_type": "Boda",
  "num_people": 150,
  "status": "quoted",
  "discount": 0,
  "requires_invoice": true,
  "tax_rate": 16.0,
  "tax_amount": 3200.00,
  "total_amount": 23200.00,
  "location": "Grand Hotel",
  "city": "Mexico City",
  "deposit_percent": 50.0,
  "cancellation_days": 15.0,
  "refund_percent": 0.0,
  "notes": "Requiere DJ"
}
```

**Response (201 Created):** (mismo que Get Event)

### Update Event
**PUT** `/api/events/{id}`

Actualiza un evento.

**Request Body:** (mismo que create)

**Response (200 OK):** (mismo que create)

### Delete Event
**DELETE** `/api/events/{id}`

Elimina un evento.

**Response (204 No Content)**

### Get Event Products
**GET** `/api/events/{id}/products`

Obtiene los productos de un evento.

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "event_id": "uuid",
    "product_id": "uuid",
    "product_name": "Paquete Boda Premium",
    "quantity": 1.0,
    "unit_price": 20000.00,
    "discount": 0,
    "total_price": 20000.00,
    "created_at": "2024-01-01T00:00:00Z"
  }
]
```

### Get Event Extras
**GET** `/api/events/{id}/extras`

Obtiene los extras de un evento.

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "event_id": "uuid",
    "description": "DJ adicional",
    "cost": 2000.00,
    "price": 3000.00,
    "exclude_utility": false,
    "created_at": "2024-01-01T00:00:00Z"
  }
]
```

### Update Event Items
**PUT** `/api/events/{id}/items`

Actualiza productos y extras de un evento en una sola transacción.

**Request Body:**
```json
{
  "products": [
    {
      "product_id": "uuid",
      "quantity": 1.0,
      "unit_price": 20000.00,
      "discount": 0
    }
  ],
  "extras": [
    {
      "description": "DJ adicional",
      "cost": 2000.00,
      "price": 3000.00,
      "exclude_utility": false
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "status": "ok"
}
```

---

## 📦 Products Endpoints

### List Products
**GET** `/api/products`

Obtiene la lista de productos del usuario.

**Query Parameters:**
- `category` (optional): Filtrar por categoría
- `is_active` (optional): Filtrar por estado (true/false)

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "name": "Paquete Boda Premium",
    "category": "Boda",
    "base_price": 20000.00,
    "recipe": null,
    "is_active": true,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

### Get Product
**GET** `/api/products/{id}`

Obtiene un producto por ID.

**Response (200 OK):** (mismo que List Products)

### Create Product
**POST** `/api/products`

Crea un nuevo producto.

**Request Body:**
```json
{
  "name": "Paquete Boda Premium",
  "category": "Boda",
  "base_price": 20000.00,
  "recipe": null,
  "is_active": true
}
```

**Response (201 Created):** (mismo que Get Product)

### Update Product
**PUT** `/api/products/{id}`

Actualiza un producto.

**Request Body:** (mismo que create)

**Response (200 OK):** (mismo que create)

### Delete Product
**DELETE** `/api/products/{id}`

Elimina un producto.

**Response (204 No Content)**

### Get Product Ingredients
**GET** `/api/products/{id}/ingredients`

Obtiene los ingredientes de un producto.

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "product_id": "uuid",
    "inventory_id": "uuid",
    "ingredient_name": "Arroz",
    "unit": "kg",
    "quantity_required": 5.0,
    "unit_cost": 20.00,
    "created_at": "2024-01-01T00:00:00Z"
  }
]
```

### Update Product Ingredients
**PUT** `/api/products/{id}/ingredients`

Actualiza los ingredientes de un producto.

**Request Body:**
```json
{
  "ingredients": [
    {
      "inventory_id": "uuid",
      "quantity_required": 5.0
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "status": "ok"
}
```

---

## 📦 Inventory Endpoints

### List Inventory
**GET** `/api/inventory`

Obtiene la lista de inventario del usuario.

**Query Parameters:**
- `type` (optional): Filtrar por tipo (ingredient, equipment)
- `low_stock` (optional): Solo ítems con stock bajo

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "ingredient_name": "Arroz",
    "current_stock": 50.0,
    "minimum_stock": 10.0,
    "unit": "kg",
    "unit_cost": 20.00,
    "type": "ingredient",
    "last_updated": "2024-01-01T00:00:00Z"
  }
]
```

### Get Inventory Item
**GET** `/api/inventory/{id}`

Obtiene un ítem de inventario por ID.

**Response (200 OK):** (mismo que List Inventory)

### Create Inventory Item
**POST** `/api/inventory`

Crea un nuevo ítem de inventario.

**Request Body:**
```json
{
  "ingredient_name": "Arroz",
  "current_stock": 50.0,
  "minimum_stock": 10.0,
  "unit": "kg",
  "unit_cost": 20.00,
  "type": "ingredient"
}
```

**Response (201 Created):** (mismo que Get Inventory Item)

### Update Inventory Item
**PUT** `/api/inventory/{id}`

Actualiza un ítem de inventario.

**Request Body:** (mismo que create)

**Response (200 OK):** (mismo que create)

### Delete Inventory Item
**DELETE** `/api/inventory/{id}`

Elimina un ítem de inventario.

**Response (204 No Content)**

---

## 💰 Payments Endpoints

### List Payments
**GET** `/api/payments`

Obtiene la lista de pagos.

**Query Parameters:**
- `event_id` (optional): Filtrar por evento
- `start` (optional): Fecha inicio (ISO 8601)
- `end` (optional): Fecha fin (ISO 8601)
- `event_ids` (optional): Lista de event IDs separados por comas

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "event_id": "uuid",
    "user_id": "uuid",
    "amount": 11600.00,
    "payment_date": "2024-06-01",
    "payment_method": "transfer",
    "notes": "Anticipo 50%",
    "created_at": "2024-01-01T00:00:00Z"
  }
]
```

### Create Payment
**POST** `/api/payments`

Crea un nuevo pago.

**Request Body:**
```json
{
  "event_id": "uuid",
  "amount": 11600.00,
  "payment_date": "2024-06-01",
  "payment_method": "transfer",
  "notes": "Anticipo 50%"
}
```

**Response (201 Created):** (mismo que List Payments)

### Update Payment
**PUT** `/api/payments/{id}`

Actualiza un pago.

**Request Body:** (mismo que create)

**Response (200 OK):** (mismo que create)

### Delete Payment
**DELETE** `/api/payments/{id}`

Elimina un pago.

**Response (204 No Content)**

---

## 🔍 Search Endpoints

### Global Search
**GET** `/api/search`

Búsqueda global en clientes, eventos y productos.

**Query Parameters:**
- `q` (required): Término de búsqueda

**Response (200 OK):**
```json
{
  "clients": [
    {
      "id": "uuid",
      "name": "Jane Smith",
      "phone": "+52 55 1234 5678",
      ...
    }
  ],
  "events": [
    {
      "id": "uuid",
      "service_type": "Boda",
      "event_date": "2024-06-15",
      ...
    }
  ],
  "products": [
    {
      "id": "uuid",
      "name": "Paquete Boda Premium",
      ...
    }
  ]
}
```

---

## 📊 Dashboard Endpoints

### Get Dashboard Stats
**GET** `/api/dashboard/stats`

Obtiene estadísticas para el dashboard.

**Query Parameters:**
- `month` (optional): Mes (YYYY-MM), default: mes actual

**Response (200 OK):**
```json
{
  "net_sales": 150000.00,
  "cash_collected": 80000.00,
  "cash_applied_to_month": 75000.00,
  "vat_collected": 24000.00,
  "vat_outstanding": 8000.00,
  "events_this_month": 8,
  "low_stock_count": 3,
  "events_by_status": {
    "quoted": 2,
    "confirmed": 4,
    "completed": 2,
    "cancelled": 0
  },
  "upcoming_events": [
    {
      "id": "uuid",
      "event_date": "2024-06-20",
      "service_type": "Cumpleaños",
      "num_people": 80,
      "clients": {
        "name": "John Doe"
      }
    }
  ]
}
```

---

## 📄 PDF Endpoints

### Generate Budget PDF
**GET** `/api/events/{id}/budget-pdf`

Genera un PDF del presupuesto de un evento.

**Response (200 OK):**
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="Presupuesto_Cliente.pdf"

[BINARY PDF DATA]
```

### Generate Contract PDF
**GET** `/api/events/{id}/contract-pdf`

Genera un PDF del contrato de un evento.

**Response (200 OK):**
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="Contrato_Cliente.pdf"

[BINARY PDF DATA]
```

---

## ❌ Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid request body",
  "details": "Email is required"
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized",
  "details": "Invalid or expired token"
}
```

### 403 Forbidden
```json
{
  "error": "Forbidden",
  "details": "You don't have permission to access this resource"
}
```

### 404 Not Found
```json
{
  "error": "Not Found",
  "details": "Resource not found"
}
```

### 409 Conflict
```json
{
  "error": "Conflict",
  "details": "Email already registered"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal Server Error",
  "details": "Something went wrong"
}
```

---

## 🔄 Pagination

Los endpoints que retornan listas soportan paginación:

**Query Parameters:**
- `page`: Número de página (default 1)
- `limit`: Ítems por página (default 20, max 100)

**Response Headers:**
```
X-Total-Count: 150
X-Total-Pages: 8
X-Current-Page: 1
X-Per-Page: 20
```

---

## 🔍 Filtering & Sorting

### Filtering
Use query parameters para filtrar resultados:

```
/api/events?status=confirmed&start=2024-01-01&end=2024-12-31
```

### Sorting
La mayoría de endpoints soportan sorting por campos:

```
/api/events?sort=-event_date  # Descendente
/api/events?sort=event_date   # Ascendente
```

---

## 📡 Rate Limiting

- **Límite**: 100 requests por minuto por IP
- **Headers:**
  ```
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 95
  X-RateLimit-Reset: 1711234567
  ```

---

## 🔒 CORS

Orígenes permitidos (configurables):
- `http://localhost:3000` (dev web)
- `http://localhost:8080` (dev mobile)
- `https://eventosapp.com` (production)
- `https://app.eventosapp.com` (mobile app)

---

## 🧪 Testing

### Health Check
**GET** `/health`

**Response:**
```json
{
  "status": "ok"
}
```

---

## 📝 Notas

- Todos los timestamps están en formato **ISO 8601** (UTC)
- Los montos monetarios están en formato **decimal** (2 decimales)
- Los IDs son **UUID v4**
- Todos los endpoints protegidos requieren token JWT válido
- Los tokens expiran en **1 hora** (configurable)
- El refresh token expira en **30 días** (configurable)
