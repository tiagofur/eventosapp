# Tasks: ios-products-feature

**Change:** ios-products-feature
**Depends on:** proposal.md, exploration.md
**Phase:** 4 (Products Feature)
**Total tasks:** 7
**Estimated files:** ~10 Swift files

---

## Task 1: ProductListViewModel

Create the ViewModel for the product list with API integration, search, filtering, and sorting state management. This is the foundation that ProductListView depends on.

- [ ] Create `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/` directory
- [ ] Create `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/ViewModels/` directory
- [ ] Write `ProductListViewModel.swift` — `@Observable` class with:
  - `products: [Product]` — Full list from API
  - `filteredProducts: [Product]` — Computed based on search/filter/sort
  - `searchText: String` — Bound to `.searchable`
  - `selectedCategory: String?` — Category filter (nil = all)
  - `sortOption: SortOption` — Enum: nameAsc, priceAsc, priceDesc, category
  - `categories: [String]` — Unique categories extracted from products
  - `isLoading: Bool`, `error: String?`
  - `showDeleteConfirmation: Bool`, `productToDelete: Product?`
  - `fetchProducts()` — GET /products via APIClient
  - `deleteProduct(id:)` — DELETE /products/{id} via APIClient
  - `confirmDelete(product:)` — Sets productToDelete and showDeleteConfirmation
  - `executeDelete()` — Calls deleteProduct, removes from local list
  - Private filtering/sorting logic in computed property

**Files:**
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/ViewModels/ProductListViewModel.swift`

**Depends on:** nothing (uses existing SolennixCore models, SolennixNetwork APIClient)

**Acceptance Criteria:**
- [ ] ViewModel compiles with no syntax errors
- [ ] `filteredProducts` correctly applies search text filter (name + category)
- [ ] `filteredProducts` correctly applies category filter when selectedCategory is set
- [ ] `filteredProducts` correctly applies sort option
- [ ] `fetchProducts()` calls correct endpoint and populates products array
- [ ] `deleteProduct()` calls correct endpoint and removes product from local state
- [ ] Categories are dynamically extracted from products list
- [ ] Loading and error states are properly managed

---

## Task 2: ProductFormViewModel

Create the ViewModel for product create/edit form with validation, image handling, and recipe management.

- [ ] Write `ProductFormViewModel.swift` — `@Observable` class with:
  - `mode: FormMode` — Enum: create, edit(productId: String)
  - `name: String`, `category: String`, `customCategory: String`
  - `price: Double`, `isActive: Bool`
  - `selectedImageData: Data?`, `existingImageUrl: String?`
  - `ingredients: [RecipeItem]`, `equipment: [RecipeItem]`, `supplies: [RecipeItem]`
  - `RecipeItem` struct: inventoryItemId, quantity, inventoryItem (for display)
  - `availableCategories: [String]` — Fetched from existing products
  - `inventoryItems: [InventoryItem]` — For recipe picker
  - `isLoading: Bool`, `isSaving: Bool`, `error: String?`
  - `isValid: Bool` — Computed: name.isNotEmpty && (category.isNotEmpty || customCategory.isNotEmpty)
  - `loadProduct(id:)` — GET /products/{id} for edit mode
  - `loadInventoryItems()` — GET /inventory for recipe picker
  - `fetchCategories()` — Extract from products or dedicated endpoint
  - `addRecipeItem(type:inventoryItem:quantity:)` — Add to appropriate array
  - `removeRecipeItem(type:at:)` — Remove from appropriate array
  - `save()` — POST or PUT based on mode, includes image upload if selectedImageData
  - `uploadImage()` — Multipart upload to /upload or inline base64

**Files:**
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/ViewModels/ProductFormViewModel.swift`

**Depends on:** Task 1 (directory structure)

**Acceptance Criteria:**
- [ ] ViewModel compiles with no syntax errors
- [ ] Form validation correctly requires name and category
- [ ] Recipe items can be added and removed for all three types
- [ ] Edit mode loads existing product data including recipe
- [ ] Save correctly creates new product or updates existing
- [ ] Image data is properly handled for upload
- [ ] Inventory items are fetched for recipe picker

---

## Task 3: ProductCard & CategoryChips Components

Create reusable UI components for the product list view.

- [ ] Create `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/Components/` directory
- [ ] Write `ProductCard.swift` — SwiftUI View with:
  - Props: `product: Product`, `onTap: () -> Void`
  - AsyncImage for product.imageUrl with placeholder
  - Name, category, price display
  - Active/inactive indicator
  - Uses SolennixDesign colors, typography, spacing
  - Card styling with shadow
- [ ] Write `CategoryChips.swift` — SwiftUI View with:
  - Props: `categories: [String]`, `selected: Binding<String?>`, `showAll: Bool`
  - Horizontal ScrollView with chip buttons
  - "Todos" chip when showAll is true (selects nil)
  - Selected chip has highlighted background
  - Uses SolennixDesign colors

**Files:**
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/Components/ProductCard.swift`
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/Components/CategoryChips.swift`

**Depends on:** Task 1 (directory structure)

**Acceptance Criteria:**
- [ ] ProductCard displays image, name, category, price correctly
- [ ] ProductCard handles missing image with placeholder
- [ ] ProductCard shows active/inactive status visually
- [ ] CategoryChips renders horizontal scrollable list
- [ ] CategoryChips shows "Todos" option that clears filter
- [ ] Selected category is visually highlighted
- [ ] Components use design system tokens

---

## Task 4: RecipeEditor & DemandForecastChart Components

Create the recipe editor component for ProductFormView and the demand chart for ProductDetailView.

- [ ] Write `RecipeEditor.swift` — SwiftUI View with:
  - Props: `title: String`, `type: RecipeType`, `items: Binding<[RecipeItem]>`, `inventoryItems: [InventoryItem]`, `onAdd: () -> Void`
  - `RecipeType` enum: ingredients, equipment, supplies (with Spanish labels)
  - Section header with title and add button
  - List of RecipeItemRow for each item (shows inventory name, quantity, unit, delete button)
  - Empty state when no items
  - Sheet for adding new item (inventory picker + quantity field)
- [ ] Write `DemandForecastChart.swift` — SwiftUI View with:
  - Props: `productId: String`
  - Uses Swift Charts (`import Charts`)
  - Fetches demand data from API (events using this product)
  - BarMark or LineMark showing quantity per upcoming event date
  - Loading and empty states
  - Spanish labels for axes

**Files:**
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/Components/RecipeEditor.swift`
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/Components/DemandForecastChart.swift`

**Depends on:** Task 2 (RecipeItem type definition)

**Acceptance Criteria:**
- [ ] RecipeEditor displays section with title and add button
- [ ] RecipeEditor lists current recipe items with quantity and unit
- [ ] RecipeEditor allows removing items via delete button
- [ ] RecipeEditor sheet allows selecting inventory item and quantity
- [ ] DemandForecastChart fetches and displays demand data
- [ ] Chart uses Swift Charts framework correctly
- [ ] Both components handle loading and empty states

---

## Task 5: ProductListView

Create the main product list view with search, filter, sort, and swipe actions.

- [ ] Create `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/Views/` directory
- [ ] Write `ProductListView.swift` — SwiftUI View with:
  - `@State private var viewModel = ProductListViewModel()`
  - `@Environment(\.apiClient)` for dependency injection
  - `.searchable(text:)` modifier for search
  - `CategoryChips` below nav bar for category filtering
  - `Menu` with `Picker` for sort options (Nombre A-Z, Precio, Categoria)
  - `List` or `LazyVGrid` of `ProductCard` items
  - `.swipeActions` on each row: Edit (blue), Delete (red)
  - `.confirmationDialog` for delete confirmation
  - FAB overlay (bottom-right) for create new product
  - `.refreshable` for pull-to-refresh
  - `.redacted(reason: .placeholder)` skeleton loading state
  - `EmptyStateView` when no products or no search results
  - Plan limit warning banner when approaching 20 products (basic plan)
  - Navigation to ProductDetailView on tap
  - Navigation to ProductFormView on FAB tap or edit swipe

**Files:**
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/Views/ProductListView.swift`

**Depends on:** Task 1 (ViewModel), Task 3 (Components)

**Acceptance Criteria:**
- [ ] List displays all products from API with correct card layout
- [ ] Search filters products in real-time as user types
- [ ] Category chips filter products when selected
- [ ] Sort menu changes product order correctly
- [ ] Swipe left reveals edit and delete actions
- [ ] Delete shows confirmation dialog before executing
- [ ] FAB is visible and navigates to create form
- [ ] Pull-to-refresh reloads products from API
- [ ] Skeleton loading displays during initial load
- [ ] Empty state shows when no products exist
- [ ] Empty state shows when search yields no results
- [ ] Plan limit warning shows when products.count >= 18 (basic plan)

---

## Task 6: ProductFormView & ProductDetailView

Create the product create/edit form and the product detail view.

- [ ] Write `ProductFormView.swift` — SwiftUI View with:
  - `@State private var viewModel: ProductFormViewModel`
  - Init accepts optional productId for edit mode
  - SwiftUI `Form` with sections:
    - Image section: `PhotosPicker` (PhotosUI) + preview
    - Info section: Name field, Category picker (sheet with existing + custom input), Price field
    - Status section: Active `Toggle`
    - Recipe sections: 3x `RecipeEditor` (ingredients, equipment, supplies)
  - Toolbar: Cancel button, Save button (disabled when !isValid or isSaving)
  - `.sheet` for category picker with:
    - List of existing categories
    - "Otra categoria" option that shows TextField for custom
  - Loading overlay when saving
  - Error alert on save failure
- [ ] Write `ProductDetailView.swift` — SwiftUI View with:
  - `let productId: String`
  - `@State` for loaded product data
  - Sections:
    - Header: Image, name, category badge, price, active status
    - Recipe section: Grouped list of ingredients, equipment, supplies
    - Demand section: `DemandForecastChart`
  - Toolbar: Edit button (navigates to ProductFormView), Delete button
  - `.confirmationDialog` for delete confirmation
  - Loading and error states

**Files:**
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/Views/ProductFormView.swift`
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/Views/ProductDetailView.swift`

**Depends on:** Task 2 (ViewModel), Task 4 (Components)

**Acceptance Criteria:**
- [ ] ProductFormView displays all form fields correctly
- [ ] PhotosPicker allows selecting image from library
- [ ] Category picker shows existing categories and custom input option
- [ ] Recipe editor sections allow managing all three recipe types
- [ ] Form validation prevents saving invalid data
- [ ] Create mode saves new product and dismisses
- [ ] Edit mode loads existing data and updates on save
- [ ] ProductDetailView displays all product information
- [ ] Recipe list shows all items grouped by type
- [ ] Demand forecast chart renders correctly
- [ ] Edit button navigates to form in edit mode
- [ ] Delete shows confirmation and removes product

---

## Task 7: Navigation Wiring

Wire the Products feature into the app navigation system.

- [ ] Modify `ios/Solennix/Navigation/RouteDestination.swift`:
  - Replace `.productDetail(id:)` placeholder with `ProductDetailView(productId: id)`
  - Replace `.productForm(id:)` placeholder with `ProductFormView(productId: id)`
- [ ] Modify `ios/Solennix/Navigation/SidebarSplitLayout.swift`:
  - In `.products` section case, replace placeholder with `ProductListView()`
- [ ] Modify `ios/Solennix/Navigation/CompactTabLayout.swift`:
  - In MoreMenuView, add Products navigation item with:
    - SF Symbol: `shippingbox.fill`
    - Label: "Productos"
    - NavigationLink to ProductListView
- [ ] Verify all imports are correct (`import SolennixFeatures`)

**Files:**
- `ios/Solennix/Navigation/RouteDestination.swift` (modify)
- `ios/Solennix/Navigation/SidebarSplitLayout.swift` (modify)
- `ios/Solennix/Navigation/CompactTabLayout.swift` (modify)

**Depends on:** Task 5, Task 6 (all views must exist)

**Acceptance Criteria:**
- [ ] ProductListView appears when selecting Products in iPad sidebar
- [ ] ProductListView appears when tapping Products in iPhone MoreMenu
- [ ] ProductDetailView opens when navigating to `.productDetail(id:)` route
- [ ] ProductFormView opens when navigating to `.productForm(id:)` route
- [ ] Navigation works correctly in both compact (iPhone) and regular (iPad) layouts
- [ ] Back navigation works correctly from all product screens

---

## Dependency Graph

```
Task 1 (ProductListViewModel)
  |
  +---> Task 5 (ProductListView)
  |       |
  |       +---> Task 7 (Navigation Wiring)
  |
Task 2 (ProductFormViewModel)
  |
  +---> Task 4 (RecipeEditor, DemandForecastChart)
  |       |
  |       +---> Task 6 (ProductFormView, ProductDetailView)
  |               |
  |               +---> Task 7 (Navigation Wiring)
  |
Task 3 (ProductCard, CategoryChips)
  |
  +---> Task 5 (ProductListView)
```

**Critical path:** 1 -> 5 -> 7 (for list functionality) and 2 -> 4 -> 6 -> 7 (for form/detail functionality)

**Parallelizable:**
- Tasks 1, 2, and 3 can all start in parallel (no dependencies on each other)
- Task 4 depends only on Task 2
- Task 5 depends on Tasks 1 and 3
- Task 6 depends on Tasks 2 and 4
- Task 7 depends on Tasks 5 and 6

---

## Execution Notes

- **No compiler available:** All code is written on Windows. Swift syntax must follow Swift 5.9+ / iOS 17+ conventions carefully. The user validates on a Mac with Xcode.
- **Existing infrastructure:** All models (Product, ProductIngredient, InventoryItem), API endpoints, and navigation routes already exist from Phase 1.
- **PhotosUI import:** ProductFormView requires `import PhotosUI` for `PhotosPicker`.
- **Charts import:** DemandForecastChart requires `import Charts` for Swift Charts framework.
- **Spanish UI strings:** All user-facing text is in Spanish (Mexico). Labels: "Productos", "Buscar", "Todos", "Nombre", "Categoria", "Precio", "Activo", "Guardar", "Cancelar", "Eliminar", "Editar", "Nuevo Producto", "Composicion", "Equipo Necesario", "Insumos por Evento", "Demanda Proxima".
- **Recipe types mapping:**
  - Composicion/Insumos = ingredients
  - Equipo Necesario = equipment
  - Insumos por Evento = supplies
- **Plan limit:** Basic plan allows 20 products max. Show warning banner when count >= 18.
