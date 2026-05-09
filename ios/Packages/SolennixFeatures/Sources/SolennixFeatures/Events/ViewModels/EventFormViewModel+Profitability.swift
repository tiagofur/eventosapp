import Foundation
import SolennixCore
import SolennixNetwork

extension EventFormViewModel {
    // MARK: - Profitability (parity con Android)

    public var hasPendingProductCosts: Bool {
        let ids = Set(selectedProducts.map { $0.productId })
        return ids.contains { productUnitCosts[$0] == nil }
    }

    public var costProducts: Double {
        selectedProducts.reduce(0) { sum, p in
            sum + (productUnitCosts[p.productId] ?? 0) * p.quantity
        }
    }

    public var costExtras: Double {
        extras.reduce(0) { $0 + $1.cost }
    }

    public var costSupplies: Double { suppliesCost }

    public var totalCosts: Double {
        costProducts + costExtras + costSupplies
    }

    public var netProfit: Double {
        let revenue = total - (requiresInvoice ? taxAmount : 0)
        return revenue - totalCosts
    }

    public var profitMargin: Double {
        let revenue = total - (requiresInvoice ? taxAmount : 0)
        let adjustedRevenue = revenue - passThroughExtrasSubtotal
        guard adjustedRevenue > 0 else { return 0 }
        return (netProfit / adjustedRevenue) * 100
    }

    /// Busca ingredients de cada producto seleccionado y calcula el costo
    /// unitario sumando `quantityRequired × unitCost` de cada ingrediente
    /// de tipo ingredient/supply. Cachea en `productUnitCosts`. Skip productos
    /// ya cacheados.
    @MainActor
    public func fetchProductCosts() async {
        let missing = selectedProducts
            .map { $0.productId }
            .filter { !$0.isEmpty && productUnitCosts[$0] == nil }
            .reduce(into: Set<String>()) { $0.insert($1) }

        guard !missing.isEmpty else { return }

        for productId in missing {
            do {
                let ingredients: [ProductIngredient] = try await apiClient.getAll(
                    Endpoint.productIngredients(productId)
                )
                let cost = ingredients
                    .filter { ing in
                        guard let type = ing.type else { return true }
                        return type == .ingredient || type == .supply
                    }
                    .reduce(0) { sum, ing in
                        sum + (ing.unitCost ?? 0) * ing.quantityRequired
                    }
                productUnitCosts[productId] = cost
            } catch {
                productUnitCosts[productId] = 0
            }
        }
    }
}
