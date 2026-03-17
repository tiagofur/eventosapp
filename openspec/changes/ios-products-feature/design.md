# Design: iOS Products Feature (Phase 4)

## 1. File/Directory Structure

```
ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/
+-- Views/
|   +-- ProductListView.swift           # List/grid with search, category chips, sort, swipe actions
|   +-- ProductFormView.swift           # Create/edit form with image picker, recipe editor
|   +-- ProductDetailView.swift         # Detail view with info, recipe, demand forecast chart
+-- ViewModels/
|   +-- ProductListViewModel.swift      # List state, API calls, filtering, sorting
|   +-- ProductFormViewModel.swift      # Form state, validation, image upload, save logic
+-- Components/
|   +-- ProductCard.swift               # Reusable product row component
|   +-- CategoryChips.swift             # Horizontal scrolling category filter
|   +-- RecipeSection.swift             # Expandable recipe section (ingredients/equipment/supplies)
|   +-- DemandForecastChart.swift       # Swift Charts demand visualization
```

**Total: 9 new Swift files**

---

## 2. ViewModel Architecture (@Observable Pattern)

Following the established pattern from `ClientListViewModel`, all ViewModels use the iOS 17+ `@Observable` macro.

### ProductListViewModel

```swift
import Foundation
import Observation
import SolennixCore
import SolennixNetwork

// MARK: - Sort Key

public enum ProductSortKey: String, CaseIterable {
    case updatedAt
    case name
    case category
    case basePrice
    case createdAt

    public var label: String {
        switch self {
        case .updatedAt:  return "Ultima actualizacion"
        case .name:       return "Nombre"
        case .category:   return "Categoria"
        case .basePrice:  return "Precio"
        case .createdAt:  return "Fecha de creacion"
        }
    }
}

// MARK: - Product List View Model

@Observable
public final class ProductListViewModel {

    // MARK: - Properties

    public var products: [Product] = []
    public var filteredProducts: [Product] = []
    public var searchText: String = "" {
        didSet { applyFilters() }
    }
    public var selectedCategory: String? = nil {
        didSet { applyFilters() }
    }
    public var isLoading: Bool = false
    public var sortKey: ProductSortKey = .updatedAt {
        didSet { applyFilters() }
    }
    public var sortAscending: Bool = false {
        didSet { applyFilters() }
    }
    public var deleteTarget: Product?
    public var showDeleteConfirm: Bool = false
    public var errorMessage: String?

    // MARK: - Computed

    /// Unique categories extracted from loaded products
    public var categories: [String] {
        Array(Set(products.map { $0.category })).sorted()
    }

    /// Plan limit check: basic plan = 20 products
    public var isAtLimit: Bool {
        products.count >= 20
    }

    public var isNearLimit: Bool {
        products.count >= 15
    }

    // MARK: - Dependencies

    private let apiClient: APIClient

    // MARK: - Init

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Data Loading

    @MainActor
    public func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let result: [Product] = try await apiClient.get(Endpoint.products)
            products = result
            applyFilters()
        } catch {
            errorMessage = mapError(error)
        }

        isLoading = false
    }

    // MARK: - Delete

    @MainActor
    public func deleteProduct(_ product: Product) async {
        do {
            try await apiClient.delete(Endpoint.product(product.id))
            products.removeAll { $0.id == product.id }
            applyFilters()
        } catch {
            errorMessage = mapError(error)
        }
    }

    // MARK: - Filtering & Sorting

    public func applyFilters() {
        var result = products

        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Filter by search text
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { product in
                product.name.lowercased().contains(query)
                || product.category.lowercased().contains(query)
            }
        }

        // Sort
        result.sort { a, b in
            let ascending: Bool
            switch sortKey {
            case .updatedAt:
                ascending = a.updatedAt < b.updatedAt
            case .name:
                ascending = a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            case .category:
                ascending = a.category.localizedCaseInsensitiveCompare(b.category) == .orderedAscending
            case .basePrice:
                ascending = a.basePrice < b.basePrice
            case .createdAt:
                ascending = a.createdAt < b.createdAt
            }
            return sortAscending ? ascending : !ascending
        }

        filteredProducts = result
    }

    // MARK: - Category Selection

    public func selectCategory(_ category: String?) {
        selectedCategory = (selectedCategory == category) ? nil : category
    }

    // MARK: - Error Mapping

    private func mapError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.errorDescription ?? "Ocurrio un error inesperado."
        }
        return "Ocurrio un error inesperado. Intenta de nuevo."
    }
}
```

### ProductFormViewModel

```swift
import Foundation
import Observation
import PhotosUI
import SwiftUI
import SolennixCore
import SolennixNetwork

// MARK: - Recipe Item Type

public enum RecipeItemType: String, CaseIterable {
    case ingredient  // Composicion/Insumos
    case equipment   // Equipo Necesario
    case supply      // Insumos por Evento

    public var title: String {
        switch self {
        case .ingredient: return "Composicion"
        case .equipment:  return "Equipo Necesario"
        case .supply:     return "Insumos por Evento"
        }
    }

    public var icon: String {
        switch self {
        case .ingredient: return "leaf.fill"
        case .equipment:  return "wrench.and.screwdriver.fill"
        case .supply:     return "shippingbox.fill"
        }
    }
}

// MARK: - Recipe Item

public struct RecipeItem: Identifiable, Hashable {
    public var id = UUID()
    public var inventoryItemId: String
    public var inventoryItemName: String
    public var quantity: Double
    public var unit: String
    public var type: RecipeItemType
}

// MARK: - Product Form View Model

@Observable
public final class ProductFormViewModel {

    // MARK: - Form State

    public var name: String = ""
    public var category: String = ""
    public var basePrice: String = ""
    public var isActive: Bool = true
    public var imageSelection: PhotosPickerItem?
    public var imageData: Data?
    public var existingImageUrl: String?

    // MARK: - Recipe State

    public var recipeItems: [RecipeItem] = []

    // MARK: - Category Picker State

    public var showCategoryPicker: Bool = false
    public var customCategory: String = ""

    // MARK: - Inventory Selection State

    public var showInventoryPicker: Bool = false
    public var selectedRecipeType: RecipeItemType = .ingredient
    public var inventoryItems: [InventoryItem] = []

    // MARK: - UI State

    public var isLoading: Bool = false
    public var isSaving: Bool = false
    public var errorMessage: String?
    public var hasChanges: Bool = false

    // MARK: - Mode

    public var isEditMode: Bool { productId != nil }
    public var productId: String?

    // MARK: - Dependencies

    private let apiClient: APIClient

    // MARK: - Computed

    public var existingCategories: [String] = []

    public var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && !category.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public var basePriceValue: Double {
        Double(basePrice.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    // MARK: - Recipe Helpers

    public func recipeItems(for type: RecipeItemType) -> [RecipeItem] {
        recipeItems.filter { $0.type == type }
    }

    // MARK: - Init

    public init(apiClient: APIClient, productId: String? = nil) {
        self.apiClient = apiClient
        self.productId = productId
    }

    // MARK: - Load Existing Product

    @MainActor
    public func loadProduct() async {
        guard let id = productId else { return }
        isLoading = true
        errorMessage = nil

        do {
            let product: Product = try await apiClient.get(Endpoint.product(id))
            name = product.name
            category = product.category
            basePrice = String(format: "%.2f", product.basePrice)
            isActive = product.isActive
            existingImageUrl = product.imageUrl

            // Load recipe/ingredients
            let ingredients: [ProductIngredient] = try await apiClient.get(Endpoint.productIngredients(id))
            recipeItems = ingredients.map { ingredient in
                RecipeItem(
                    inventoryItemId: ingredient.inventoryItemId,
                    inventoryItemName: ingredient.inventoryItemName ?? "",
                    quantity: ingredient.quantity,
                    unit: ingredient.unit ?? "",
                    type: RecipeItemType(rawValue: ingredient.type) ?? .ingredient
                )
            }
        } catch {
            errorMessage = mapError(error)
        }

        isLoading = false
    }

    // MARK: - Load Categories & Inventory

    @MainActor
    public func loadCategories() async {
        do {
            let products: [Product] = try await apiClient.get(Endpoint.products)
            existingCategories = Array(Set(products.map { $0.category })).sorted()
        } catch {
            // Non-critical, ignore
        }
    }

    @MainActor
    public func loadInventoryItems() async {
        do {
            inventoryItems = try await apiClient.get(Endpoint.inventoryItems)
        } catch {
            // Non-critical, ignore
        }
    }

    // MARK: - Recipe Management

    public func addRecipeItem(_ item: InventoryItem, type: RecipeItemType, quantity: Double) {
        let recipeItem = RecipeItem(
            inventoryItemId: item.id,
            inventoryItemName: item.name,
            quantity: quantity,
            unit: item.unit,
            type: type
        )
        recipeItems.append(recipeItem)
        hasChanges = true
    }

    public func removeRecipeItem(_ item: RecipeItem) {
        recipeItems.removeAll { $0.id == item.id }
        hasChanges = true
    }

    public func updateRecipeItemQuantity(_ item: RecipeItem, quantity: Double) {
        if let index = recipeItems.firstIndex(where: { $0.id == item.id }) {
            recipeItems[index].quantity = quantity
            hasChanges = true
        }
    }

    // MARK: - Save

    @MainActor
    public func save() async -> Bool {
        isSaving = true
        errorMessage = nil

        do {
            // 1. Prepare product payload
            var payload: [String: Any] = [
                "name": name.trimmingCharacters(in: .whitespaces),
                "category": category.trimmingCharacters(in: .whitespaces),
                "base_price": basePriceValue,
                "is_active": isActive
            ]

            // 2. Upload image if changed
            if let imageData = imageData {
                let imageUrl: String = try await apiClient.upload(
                    Endpoint.uploadImage,
                    data: imageData,
                    mimeType: "image/jpeg"
                )
                payload["image_url"] = imageUrl
            }

            // 3. Create or update product
            let product: Product
            if let id = productId {
                product = try await apiClient.put(Endpoint.product(id), body: payload)
            } else {
                product = try await apiClient.post(Endpoint.products, body: payload)
            }

            // 4. Update recipe/ingredients
            let recipePayload = recipeItems.map { item in
                [
                    "inventory_item_id": item.inventoryItemId,
                    "quantity": item.quantity,
                    "type": item.type.rawValue
                ] as [String: Any]
            }
            try await apiClient.put(Endpoint.productIngredients(product.id), body: ["ingredients": recipePayload])

            isSaving = false
            return true
        } catch {
            errorMessage = mapError(error)
            isSaving = false
            return false
        }
    }

    // MARK: - Image Handling

    @MainActor
    public func processImageSelection() async {
        guard let item = imageSelection else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                imageData = data
                hasChanges = true
            }
        } catch {
            // Ignore image loading errors
        }
    }

    // MARK: - Error Mapping

    private func mapError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.errorDescription ?? "Ocurrio un error inesperado."
        }
        return "Ocurrio un error inesperado. Intenta de nuevo."
    }
}
```

---

## 3. Component Breakdown

### ProductListView

**Structure:**
```swift
public struct ProductListView: View {
    @State private var viewModel: ProductListViewModel

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content           // List, skeleton, or empty state
            fabButton         // New product FAB
        }
        .navigationTitle("Productos")
        .searchable(text: $viewModel.searchText, prompt: "Buscar productos...")
        .refreshable { await viewModel.loadProducts() }
        .toolbar { sortMenu }
        .confirmationDialog(...)  // Delete confirmation
        .task { await viewModel.loadProducts() }
    }
}
```

**Subviews:**
- `categoryChips` - Horizontal `ScrollView` with category filter buttons
- `productList` - `List` with `NavigationLink` rows and `.swipeActions`
- `productRow(_ product: Product)` - Row with image, name, category badge, price
- `skeletonList` - Placeholder loading state
- `sortMenu` - `Menu` with `Picker` for sort options
- `fabButton` - `NavigationLink` to `ProductFormView`
- `planLimitBanner` - Warning when near/at 20 product limit

### ProductFormView

**Structure:**
```swift
public struct ProductFormView: View {
    @State private var viewModel: ProductFormViewModel
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        Form {
            imageSection        // PhotosPicker + preview
            basicInfoSection    // Name, Category (with sheet), Price, Active toggle
            recipeSection(.ingredient)
            recipeSection(.equipment)
            recipeSection(.supply)
        }
        .navigationTitle(viewModel.isEditMode ? "Editar Producto" : "Nuevo Producto")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { cancelButton }
            ToolbarItem(placement: .confirmationAction) { saveButton }
        }
        .sheet(isPresented: $viewModel.showCategoryPicker) { categoryPickerSheet }
        .sheet(isPresented: $viewModel.showInventoryPicker) { inventoryPickerSheet }
        .task { await loadData() }
    }
}
```

**Sections:**
- `imageSection` - `PhotosPicker` with image preview or placeholder
- `basicInfoSection` - `TextField` for name, category button (opens sheet), price field, `Toggle` for active
- `recipeSection(_ type: RecipeItemType)` - Collapsible section with recipe items and add button
- `categoryPickerSheet` - List of existing categories + custom input option
- `inventoryPickerSheet` - Searchable list of inventory items with quantity input

### ProductDetailView

**Structure:**
```swift
public struct ProductDetailView: View {
    @State private var viewModel: ProductDetailViewModel
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                productHeader       // Image, name, category, price, status
                demandForecastChart // Swift Charts visualization
                recipeSection       // Grouped recipe display
            }
            .padding()
        }
        .navigationTitle(viewModel.product?.name ?? "Producto")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu { editButton; deleteButton }
            }
        }
        .confirmationDialog(...)  // Delete confirmation
        .task { await viewModel.loadProduct() }
    }
}
```

### CategoryChips Component

```swift
public struct CategoryChips: View {
    let categories: [String]
    @Binding var selectedCategory: String?
    let onSelect: (String?) -> Void

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // "All" chip
                chipButton(title: "Todos", isSelected: selectedCategory == nil) {
                    onSelect(nil)
                }

                // Category chips
                ForEach(categories, id: \.self) { category in
                    chipButton(title: category, isSelected: selectedCategory == category) {
                        onSelect(category)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    private func chipButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : SolennixColors.text)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? SolennixColors.primary : SolennixColors.surfaceAlt)
                .clipShape(Capsule())
        }
    }
}
```

### RecipeSection Component

```swift
public struct RecipeSection: View {
    let title: String
    let icon: String
    let items: [RecipeItem]
    let onAdd: () -> Void
    let onRemove: (RecipeItem) -> Void
    let onUpdateQuantity: (RecipeItem, Double) -> Void

    @State private var isExpanded: Bool = true

    public var body: some View {
        Section {
            if isExpanded {
                ForEach(items) { item in
                    recipeItemRow(item)
                }

                Button {
                    onAdd()
                } label: {
                    Label("Agregar", systemImage: "plus.circle.fill")
                        .foregroundStyle(SolennixColors.primary)
                }
            }
        } header: {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack {
                    Label(title, systemImage: icon)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            .foregroundStyle(SolennixColors.text)
        }
    }

    private func recipeItemRow(_ item: RecipeItem) -> some View {
        HStack {
            Text(item.inventoryItemName)
                .font(.body)

            Spacer()

            HStack(spacing: Spacing.xs) {
                TextField("Cant.", value: Binding(
                    get: { item.quantity },
                    set: { onUpdateQuantity(item, $0) }
                ), format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)

                Text(item.unit)
                    .font(.caption)
                    .foregroundStyle(SolennixColors.textSecondary)
            }

            Button(role: .destructive) {
                onRemove(item)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(SolennixColors.error)
            }
        }
    }
}
```

### DemandForecastChart Component

```swift
import Charts
import SwiftUI

public struct DemandForecastChart: View {
    let demandData: [DemandPoint]  // Array of (date, quantity) pairs

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Demanda Proximos Eventos")
                .font(.headline)
                .foregroundStyle(SolennixColors.text)

            if demandData.isEmpty {
                Text("Sin eventos proximos con este producto")
                    .font(.subheadline)
                    .foregroundStyle(SolennixColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.lg)
            } else {
                Chart(demandData) { point in
                    BarMark(
                        x: .value("Fecha", point.date, unit: .day),
                        y: .value("Cantidad", point.quantity)
                    )
                    .foregroundStyle(SolennixGradient.premium)
                    .cornerRadius(CornerRadius.sm)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }
}

public struct DemandPoint: Identifiable {
    public let id = UUID()
    public let date: Date
    public let quantity: Int
}
```

---

## 4. Navigation Wiring Changes

### RouteDestination.swift

Add product view cases to the route switch:

```swift
enum RouteDestination {
    @ViewBuilder
    static func view(for route: Route, apiClient: APIClient) -> some View {
        switch route {
        // ... existing cases ...

        // Products
        case .productDetail(let id):
            ProductDetailView(apiClient: apiClient, productId: id)

        case .productForm(let id):
            ProductFormView(apiClient: apiClient, productId: id)

        // ... remaining cases ...
        }
    }
}
```

### SidebarSplitLayout.swift

Add ProductListView to the sidebar section content switch:

```swift
@ViewBuilder
private func sectionRootView(_ section: SidebarSection) -> some View {
    switch section {
    // ... existing cases ...

    case .products:
        ProductListView(apiClient: apiClient)

    // ... remaining cases ...
    }
}
```

### CompactTabLayout.swift (MoreMenuView)

Add Products navigation row to the "More" menu:

```swift
struct MoreMenuView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(value: SidebarSection.products) {
                    Label("Productos", systemImage: "shippingbox.fill")
                }

                NavigationLink(value: SidebarSection.inventory) {
                    Label("Inventario", systemImage: "archivebox.fill")
                }

                // ... other menu items ...
            }
        }
        .navigationTitle("Mas")
        .navigationDestination(for: SidebarSection.self) { section in
            sectionView(section)
        }
    }

    @ViewBuilder
    private func sectionView(_ section: SidebarSection) -> some View {
        switch section {
        case .products:
            ProductListView(apiClient: apiClient)
        // ... other sections ...
        }
    }
}
```

---

## 5. Key Code Patterns to Follow

### Pattern 1: ViewModel Initialization (from ClientListView)

```swift
public struct ProductListView: View {
    @State private var viewModel: ProductListViewModel
    @Environment(\.openURL) private var openURL

    public init(apiClient: APIClient) {
        _viewModel = State(initialValue: ProductListViewModel(apiClient: apiClient))
    }
}
```

### Pattern 2: List with Swipe Actions (from ClientListView)

```swift
List(viewModel.filteredProducts) { product in
    NavigationLink(value: Route.productDetail(id: product.id)) {
        productRow(product)
    }
    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
        Button(role: .destructive) {
            viewModel.deleteTarget = product
            viewModel.showDeleteConfirm = true
        } label: {
            Label("Eliminar", systemImage: "trash")
        }

        NavigationLink(value: Route.productForm(id: product.id)) {
            Label("Editar", systemImage: "pencil")
        }
        .tint(.blue)
    }
}
.listStyle(.plain)
```

### Pattern 3: Search and Refresh (from ClientListView)

```swift
.searchable(text: $viewModel.searchText, prompt: "Buscar productos...")
.refreshable { await viewModel.loadProducts() }
.task { await viewModel.loadProducts() }
```

### Pattern 4: Confirmation Dialog (from ClientListView)

```swift
.confirmationDialog(
    "Eliminar producto",
    isPresented: $viewModel.showDeleteConfirm,
    presenting: viewModel.deleteTarget
) { product in
    Button("Eliminar", role: .destructive) {
        Task { await viewModel.deleteProduct(product) }
    }
    Button("Cancelar", role: .cancel) {}
} message: { product in
    Text("Estas seguro de que quieres eliminar \(product.name)? Esta accion no se puede deshacer.")
}
```

### Pattern 5: FAB Button (from ClientListView)

```swift
private var fabButton: some View {
    NavigationLink(value: Route.productForm()) {
        Image(systemName: "plus")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)
            .background(SolennixGradient.premium)
            .clipShape(Circle())
            .shadowFab()
    }
    .padding(Spacing.lg)
}
```

### Pattern 6: Sort Menu (from ClientListView)

```swift
private var sortMenu: some View {
    Menu {
        Picker("Ordenar por", selection: $viewModel.sortKey) {
            ForEach(ProductSortKey.allCases, id: \.self) { key in
                Text(key.label).tag(key)
            }
        }

        Divider()

        Button {
            viewModel.sortAscending.toggle()
        } label: {
            Label(
                viewModel.sortAscending ? "Ascendente" : "Descendente",
                systemImage: viewModel.sortAscending ? "arrow.up" : "arrow.down"
            )
        }
    } label: {
        Image(systemName: "arrow.up.arrow.down")
            .font(.body)
            .foregroundStyle(SolennixColors.primary)
    }
}
```

### Pattern 7: Skeleton Loading (from ClientListView)

```swift
private var skeletonList: some View {
    List(0..<5, id: \.self) { _ in
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(SolennixColors.surfaceAlt)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(SolennixColors.surfaceAlt)
                    .frame(width: 140, height: 14)

                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(SolennixColors.surfaceAlt)
                    .frame(width: 80, height: 10)
            }

            Spacer()
        }
        .padding(.vertical, Spacing.xs)
    }
    .listStyle(.plain)
    .redacted(reason: .placeholder)
}
```

### Pattern 8: Empty State (from ClientListView)

```swift
if viewModel.filteredProducts.isEmpty && !viewModel.isLoading {
    if viewModel.searchText.isEmpty && viewModel.selectedCategory == nil {
        EmptyStateView(
            icon: "shippingbox",
            title: "Sin productos",
            message: "Agrega tu primer producto para empezar",
            actionTitle: "Agregar Producto"
        ) {
            // FAB handles navigation
        }
    } else {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "Sin resultados",
            message: "No se encontraron productos que coincidan con tu busqueda"
        )
    }
}
```

### Pattern 9: Plan Limit Warning

```swift
@ViewBuilder
private var planLimitBanner: some View {
    if viewModel.isNearLimit {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(SolennixColors.warning)
            Text(viewModel.isAtLimit
                ? "Has alcanzado el limite de 20 productos"
                : "Te quedan \(20 - viewModel.products.count) productos disponibles")
                .font(.subheadline)
                .foregroundStyle(SolennixColors.text)
            Spacer()
        }
        .padding()
        .background(SolennixColors.warning.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .padding(.horizontal)
    }
}
```

---

## 6. API Endpoints Reference

The following endpoints are already defined in `Endpoint.swift`:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `Endpoint.products` | GET | List all products |
| `Endpoint.products` | POST | Create new product |
| `Endpoint.product(id)` | GET | Get single product |
| `Endpoint.product(id)` | PUT | Update product |
| `Endpoint.product(id)` | DELETE | Delete product |
| `Endpoint.productIngredients(id)` | GET | Get product recipe |
| `Endpoint.productIngredients(id)` | PUT | Update product recipe |
| `Endpoint.inventoryItems` | GET | List inventory (for recipe editor) |
| `Endpoint.uploadImage` | POST | Upload product image |

---

## 7. Dependencies

All dependencies are already available:

- **SolennixCore**: `Product`, `ProductIngredient`, `InventoryItem` models
- **SolennixNetwork**: `APIClient`, `Endpoint`, `APIError`
- **SolennixDesign**: `SolennixColors`, `Spacing`, `CornerRadius`, `SolennixGradient`, `EmptyStateView`, `Avatar`
- **System Frameworks**: `Charts` (Swift Charts), `PhotosUI` (PhotosPicker)
