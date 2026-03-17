# Spec: iOS Products Feature

**Change:** ios-products-feature
**Depends on:** proposal.md, exploration.md
**Scope:** ProductListView, ProductFormView, ProductDetailView, ViewModels, Navigation integration

---

## 1. ProductListView

### 1.1 Layout

Primary list view displaying the user's product catalog with search, filter, sort, and CRUD actions.

**Structure (top to bottom):**
1. Navigation title: "Productos"
2. Search bar (`.searchable` modifier)
3. Category filter chips (horizontal `ScrollView`)
4. Sort menu (`Menu` with `Picker`)
5. Product list (`List` with `.swipeActions`)
6. FAB for new product (overlay)

### 1.2 Product Card

| Element | Type | Details |
|---------|------|---------|
| Image/Icon | `AsyncImage` / SF Symbol | 44x44pt, rounded corners; fallback: `shippingbox.fill` in `solennixGoldLight` box |
| Name | Text | `.headline` weight, single line truncation |
| Category badge | Text | `.caption2`, uppercase, `surface` background, `radiusSm` corners |
| Inactive badge | Text (conditional) | Shows "Inactivo" in `errorBg` with `error` text when `!isActive` |
| Price | Text | `.subheadline`, right-aligned, formatted as MXN currency |
| Chevron | `Image(systemName: "chevron.right")` | `tertiaryText` color |

### 1.3 Category Chips

- Horizontal `ScrollView` with `HStack`
- Each chip: `Button` with `capsule` shape
- Selected state: `solennixGold` background, `inverseText` text
- Unselected state: `card` background, `secondaryText` text
- Tap toggles filter (tap again to deselect)

### 1.4 Sort Menu

Implemented via `Menu` containing `Picker` with three options:

| Key | Label (Spanish) |
|-----|-----------------|
| `name` | "Nombre" |
| `base_price` | "Precio" |
| `category` | "Categoría" |

Default sort: `name` ascending.

### 1.5 Swipe Actions

| Direction | Action | Icon | Color |
|-----------|--------|------|-------|
| Trailing | Edit | `pencil` | `info` |
| Trailing | Delete | `trash` | `error` |

Edit navigates to `ProductFormView(id:)`. Delete shows `.confirmationDialog`.

### 1.6 FAB

- Position: Bottom-right corner, 24pt from edges
- Size: 56x56pt
- Shape: Circle
- Background: `solennixGold`
- Icon: `plus` in `inverseText`
- Shadow: `.shadowFab()`
- Action: Navigate to `ProductFormView(id: nil)` (create mode)

### 1.7 UI States

| State | Trigger | Display |
|-------|---------|---------|
| Loading | Initial load, `products == nil` | `.redacted(reason: .placeholder)` on skeleton cards (6 items) |
| Empty (no products) | `products.isEmpty && !isFiltered` | `EmptyStateView` with `shippingbox` icon, "Sin productos", "Agrega tu primer producto al catálogo.", CTA "Nuevo Producto" |
| Empty (filtered) | `filteredProducts.isEmpty && isFiltered` | `EmptyStateView` with "Sin resultados", "No se encontraron productos con los filtros aplicados." |
| Error | API failure | `EmptyStateView` with `exclamationmark.triangle` icon, error message, "Reintentar" CTA |
| Content | Products loaded | Product list with cards |

### 1.8 Plan Limit Warning

When `products.count >= 18` and user plan is `basic`:
- Show inline banner above FAB
- Text: "Cerca del límite de 20 productos (plan básico)"
- Style: `warningBg` background, `warning` text

---

## 2. ProductFormView

### 2.1 Layout

Create/edit form using SwiftUI `Form` with grouped sections.

**Sections:**
1. Image picker
2. Product information (name, category, price, active toggle)
3. Recipe: Composición/Insumos (ingredients)
4. Recipe: Equipo Necesario (equipment)
5. Recipe: Insumos por Evento (supplies)

### 2.2 Image Picker Section

- Full-width image area, 16:9 aspect ratio
- Uses `PhotosPicker` from PhotosUI framework
- Empty state: dashed border, `camera` icon, "Agregar foto" text
- With image: Display selected/existing image with `contentMode: .fill`
- Long-press: Alternative camera capture option (if available)

### 2.3 Product Information Section

| Field | Type | Validation | Notes |
|-------|------|------------|-------|
| name | `TextField` | Required, min 2 characters | Placeholder: "Ej: Paquete Premium" |
| category | Category picker button | Required, min 2 characters | Opens category selection sheet |
| basePrice | `TextField` | Required, >= 0 | `.keyboardType(.decimalPad)`, prefix "$" |
| isActive | `Toggle` | N/A | Label: "Producto Activo", sublabel: "Visible en cotizaciones" |

### 2.4 Category Picker Sheet

Presented via `.sheet` with `.presentationDetents([.medium])`:

1. **Header:** "Seleccionar Categoría"
2. **Existing categories list:** Each row shows category name; selected category has checkmark
3. **Custom category input:** `TextField` with "Nueva categoría..." placeholder + circular add button

On selection: Dismiss sheet, update form field.

### 2.5 Recipe Sections

Three identical recipe sections with type-specific filtering:

| Section | Title | Inventory Filter | Description |
|---------|-------|------------------|-------------|
| Ingredients | "Composición / Insumos" | `type == .ingredient` | "Solo insumos generan costo al producto." |
| Equipment | "Equipo Necesario" | `type == .equipment` | "Activos reutilizables. No se incluyen en el costo del producto." |
| Supplies | "Insumos por Evento" | `type == .supply` | "Costo fijo por evento (ej. aceite, gas). No escala con unidades del producto." |

**Recipe Row Layout:**

| Element | Description |
|---------|-------------|
| Inventory selector | Horizontal `ScrollView` with selectable chips |
| Quantity input | `TextField` with `.keyboardType(.decimalPad)` |
| Unit display | Text showing inventory item's unit |
| Remove button | `trash` icon in `error` color |

**Section Actions:**
- "Agregar" button (header right): Adds new empty recipe row
- Empty state: Italic text describing purpose

### 2.6 Form Validation Rules

| Field | Rule | Error Message |
|-------|------|---------------|
| name | `!name.trimmingCharacters(in: .whitespaces).isEmpty` | "El nombre es requerido" |
| name | `name.count >= 2` | "El nombre debe tener al menos 2 caracteres" |
| category | `!category.trimmingCharacters(in: .whitespaces).isEmpty` | "La categoría es requerida" |
| category | `category.count >= 2` | "La categoría debe tener al menos 2 caracteres" |
| basePrice | `basePrice >= 0` | "El precio no puede ser negativo" |

### 2.7 Save Button

- Position: Bottom toolbar or sticky footer
- State: Disabled while saving or if validation fails
- Loading: Shows `ProgressView` instead of text
- Text: "Crear Producto" (create) / "Actualizar" (edit)
- Style: `PremiumButton` with `.primary` style

---

## 3. ProductDetailView

### 3.1 Layout

Read-only display of product information with edit/delete actions.

**Sections:**
1. Header with image and basic info
2. Recipe sections (ingredients, equipment, supplies)
3. Demand forecast chart

### 3.2 Header Section

| Element | Details |
|---------|---------|
| Image | Full-width, 16:9 aspect ratio, or icon placeholder |
| Name | `.title2` weight |
| Category | Category badge (same style as list) |
| Price | `.title3` weight, MXN formatted |
| Status | "Activo" / "Inactivo" badge |

### 3.3 Recipe Display Sections

For each recipe type (ingredients, equipment, supplies):

**Section Header:** Type title + item count

**Item Row:**
| Element | Details |
|---------|---------|
| Name | Inventory item name |
| Quantity | Quantity required + unit |

Empty state: "No hay [tipo] asignados a este producto."

### 3.4 Demand Forecast Chart

Uses Swift Charts (`Chart`) to display product demand from upcoming events.

**Data Source:** Upcoming events containing this product, grouped by month.

**Chart Configuration:**
- Type: `BarMark`
- X-axis: Month labels (es_MX locale)
- Y-axis: Quantity
- Color: `solennixGold`
- Empty state: "No hay eventos próximos con este producto."

### 3.5 Actions

Toolbar actions:
| Action | Icon | Behavior |
|--------|------|----------|
| Edit | `pencil` | Navigate to `ProductFormView(id: product.id)` |
| Delete | `trash` | Show `.confirmationDialog` |

Delete confirmation:
- Title: "Eliminar producto"
- Message: "¿Eliminar \"[name]\"? Esta acción no se puede deshacer."
- Destructive action: "Eliminar"
- Cancel action: "Cancelar"

---

## 4. ViewModels

### 4.1 ProductListViewModel

```
@Observable class ProductListViewModel {
    // State
    var products: [Product]?
    var filteredProducts: [Product]
    var searchText: String
    var selectedCategory: String?
    var sortKey: SortKey
    var isLoading: Bool
    var error: Error?
    var deleteTarget: Product?

    // Computed
    var categories: [String]
    var isFiltered: Bool
    var showPlanLimitWarning: Bool

    // Actions
    func loadProducts() async
    func deleteProduct(_ product: Product) async
    func refresh() async
}

enum SortKey: String, CaseIterable {
    case name = "name"
    case basePrice = "base_price"
    case category = "category"
}
```

**Filtering Logic:**
1. If `selectedCategory != nil`: filter by category
2. If `searchText.isNotEmpty`: filter by name OR category containing search text (case-insensitive)
3. Sort by `sortKey`

### 4.2 ProductFormViewModel

```
@Observable class ProductFormViewModel {
    // Mode
    let productId: String?
    var isEditing: Bool { productId != nil }

    // Form state
    var name: String
    var category: String
    var basePrice: Double
    var isActive: Bool
    var imageUrl: String?
    var selectedImageData: Data?

    // Recipe state
    var ingredients: [RecipeItem]  // type == .ingredient
    var equipment: [RecipeItem]    // type == .equipment
    var supplies: [RecipeItem]     // type == .supply

    // Reference data
    var inventoryItems: [InventoryItem]
    var existingCategories: [String]

    // UI state
    var isLoading: Bool
    var isSaving: Bool
    var error: Error?
    var showCategoryPicker: Bool
    var customCategory: String

    // Validation
    var isValid: Bool
    var nameError: String?
    var categoryError: String?
    var priceError: String?

    // Actions
    func loadData() async
    func save() async throws
    func addRecipeItem(type: InventoryType)
    func removeRecipeItem(at index: Int, type: InventoryType)
    func updateRecipeItem(at index: Int, type: InventoryType, inventoryId: String?, quantity: Double)
    func selectCategory(_ category: String)
}

struct RecipeItem: Identifiable {
    let id: UUID
    var inventoryId: String
    var quantity: Double
    var inventory: InventoryItem?
}
```

### 4.3 ProductDetailViewModel

```
@Observable class ProductDetailViewModel {
    let productId: String

    // State
    var product: Product?
    var ingredients: [ProductIngredient]
    var demandForecast: [DemandDataPoint]
    var isLoading: Bool
    var error: Error?
    var showDeleteConfirmation: Bool

    // Actions
    func loadProduct() async
    func deleteProduct() async throws
}

struct DemandDataPoint: Identifiable {
    let id: UUID
    let month: Date
    let quantity: Int
}
```

---

## 5. API Integration

### 5.1 Endpoints Used

| Operation | Method | Endpoint | Request Body | Response |
|-----------|--------|----------|--------------|----------|
| List products | GET | `/products` | — | `[Product]` |
| Get product | GET | `/products/{id}` | — | `Product` |
| Create product | POST | `/products` | `CreateProductRequest` | `Product` |
| Update product | PUT | `/products/{id}` | `UpdateProductRequest` | `Product` |
| Delete product | DELETE | `/products/{id}` | — | `EmptyResponse` |
| Get ingredients | GET | `/products/{id}/ingredients` | — | `[ProductIngredient]` |
| Update ingredients | PUT | `/products/{id}/ingredients` | `[IngredientRequest]` | `[ProductIngredient]` |
| Batch ingredients | POST | `/products/ingredients/batch` | `BatchIngredientRequest` | `[ProductIngredient]` |
| Upload image | POST | `/uploads/image` | `multipart/form-data` | `UploadResponse` |
| List inventory | GET | `/inventory` | — | `[InventoryItem]` |
| Upcoming events | GET | `/events/upcoming` | — | `[Event]` |

### 5.2 Request/Response Types

```swift
struct CreateProductRequest: Encodable {
    let name: String
    let category: String
    let basePrice: Double
    let imageUrl: String?
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case name, category
        case basePrice = "base_price"
        case imageUrl = "image_url"
        case isActive = "is_active"
    }
}

struct UpdateProductRequest: Encodable {
    let name: String
    let category: String
    let basePrice: Double
    let imageUrl: String?
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case name, category
        case basePrice = "base_price"
        case imageUrl = "image_url"
        case isActive = "is_active"
    }
}

struct IngredientRequest: Encodable {
    let inventoryId: String
    let quantityRequired: Double

    enum CodingKeys: String, CodingKey {
        case inventoryId = "inventory_id"
        case quantityRequired = "quantity_required"
    }
}
```

### 5.3 Error Handling

| Error Code | User Message | Recovery Action |
|------------|--------------|-----------------|
| 401 | "Sesión expirada" | Redirect to login |
| 403 | "No tienes permiso para esta acción" | Show error toast |
| 404 | "Producto no encontrado" | Navigate back |
| 409 | "Ya existe un producto con este nombre" | Show inline field error |
| 422 | Validation error from server | Show inline field errors |
| 500+ | "Error del servidor. Intenta de nuevo." | Show retry option |
| Network | "Sin conexión a internet" | Show offline banner |

---

## 6. Scenarios

### SC-01: View Product List (Happy Path)
1. User navigates to Products section
2. `ProductListViewModel.loadProducts()` calls `GET /products`
3. Products array populates, `isLoading = false`
4. List displays with cards showing image/icon, name, category, price
5. Categories extracted and displayed as filter chips

### SC-02: Search Products
1. User types in search bar
2. `searchText` updates, filtering triggers
3. `filteredProducts` updates to show matching products
4. If no matches, empty state "Sin resultados" displays

### SC-03: Filter by Category
1. User taps category chip (e.g., "Postres")
2. `selectedCategory = "Postres"`
3. `filteredProducts` shows only products in that category
4. Chip appears selected (gold background)
5. User taps same chip again to clear filter

### SC-04: Sort Products
1. User taps sort menu button
2. Menu shows three options
3. User selects "Precio"
4. `sortKey = .basePrice`
5. Products re-sort by price ascending

### SC-05: Create Product (Happy Path)
1. User taps FAB
2. `ProductFormView(id: nil)` presented
3. User fills name: "Churros Premium", category: "Postres", price: 150
4. User adds ingredient: Harina (2 kg)
5. User taps "Crear Producto"
6. `ProductFormViewModel.save()` uploads image (if selected), then `POST /products`
7. Success toast "Producto creado", navigate back
8. List refreshes showing new product

### SC-06: Edit Product
1. User swipes product card, taps "Edit"
2. `ProductFormView(id: product.id)` loads
3. Form pre-populates with existing data
4. User changes price to 175
5. User taps "Actualizar"
6. `PUT /products/{id}` called
7. Success toast, navigate back

### SC-07: Delete Product
1. User swipes product card, taps "Delete"
2. `.confirmationDialog` appears
3. User confirms deletion
4. `DELETE /products/{id}` called
5. Product removed from list
6. Success toast "Producto eliminado"

### SC-08: Delete Product (From Detail)
1. User views product detail
2. Taps trash icon in toolbar
3. Confirmation dialog appears
4. User confirms
5. Product deleted, navigate back to list

### SC-09: Recipe Management
1. User editing product, taps "Agregar" in Ingredients section
2. New empty row appears
3. User scrolls ingredient chips, selects "Harina"
4. User enters quantity: 2
5. Unit displays automatically: "kg"
6. Repeat for equipment and supplies sections

### SC-10: Category Selection (Existing)
1. User taps category field
2. Sheet presents with existing categories
3. User taps "Postres"
4. Sheet dismisses, field shows "Postres"

### SC-11: Category Selection (Custom)
1. User taps category field
2. Sheet presents
3. User types "Bebidas Especiales" in custom input
4. User taps add button
5. Sheet dismisses, field shows "Bebidas Especiales"

### SC-12: View Product Detail
1. User taps product card
2. `ProductDetailView(id:)` loads
3. Header shows image, name, category, price, status
4. Recipe sections show grouped ingredients/equipment/supplies
5. Demand forecast chart shows upcoming event quantities

### SC-13: Plan Limit Warning
1. User has 18+ products (basic plan)
2. Warning banner appears above FAB
3. User can still create products until 20
4. At 20, create disabled with upgrade prompt

### SC-14: Offline Behavior
1. Network disconnected
2. User tries to load products
3. Error state shows with retry option
4. On reconnect, user taps retry
5. Products load successfully

### SC-15: Form Validation Errors
1. User submits form with empty name
2. Inline error "El nombre es requerido" appears
3. Save button remains disabled
4. User fills name, error clears
5. Form becomes submittable

---

## 7. Navigation Integration

### 7.1 RouteDestination Updates

```swift
// In RouteDestination.swift
case .productDetail(let id):
    ProductDetailView(productId: id)
case .productForm(let id):
    ProductFormView(productId: id)
```

### 7.2 SidebarSplitLayout Updates

```swift
// In SidebarSplitLayout.swift, content switch
case .products:
    ProductListView()
```

### 7.3 MoreMenuView Updates

```swift
// In CompactTabLayout.swift MoreMenuView
NavigationLink(value: SidebarSection.products) {
    Label("Productos", systemImage: "shippingbox.fill")
}
```

---

## 8. File Manifest

```
ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/
  Views/
    ProductListView.swift
    ProductFormView.swift
    ProductDetailView.swift
  ViewModels/
    ProductListViewModel.swift
    ProductFormViewModel.swift
    ProductDetailViewModel.swift
  Components/
    ProductCard.swift
    CategoryChips.swift
    RecipeSection.swift
    DemandForecastChart.swift
```

**Total: ~10 Swift files**
