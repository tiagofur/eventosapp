import Foundation
import Observation
import SolennixCore
import SolennixNetwork

// MARK: - Sort Key

public enum ProductSortKey: String, CaseIterable {
    case name
    case basePrice
    case category

    public var label: String {
        switch self {
        case .name:      return "Nombre"
        case .basePrice: return "Precio"
        case .category:  return "Categoria"
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
    public var sortKey: ProductSortKey = .name {
        didSet { applyFilters() }
    }
    public var sortAscending: Bool = true {
        didSet { applyFilters() }
    }
    public var deleteTarget: Product?
    public var showDeleteConfirm: Bool = false
    public var errorMessage: String?

    // MARK: - Computed

    /// Unique categories from all products
    public var categories: [String] {
        let cats = Set(products.map { $0.category }.filter { !$0.isEmpty })
        return Array(cats).sorted()
    }

    /// Check if basic plan limit reached (20 products)
    public var isAtLimit: Bool {
        products.count >= 20
    }

    /// Check if approaching limit (15+ products)
    public var isApproachingLimit: Bool {
        products.count >= 15 && products.count < 20
    }

    public var remainingProducts: Int {
        max(0, 20 - products.count)
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
            case .name:
                ascending = a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            case .basePrice:
                ascending = a.basePrice < b.basePrice
            case .category:
                ascending = a.category.localizedCaseInsensitiveCompare(b.category) == .orderedAscending
            }
            return sortAscending ? ascending : !ascending
        }

        filteredProducts = result
    }

    // MARK: - Category Toggle

    public func toggleCategory(_ category: String) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
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
