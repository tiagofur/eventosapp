import Foundation
import UIKit
import SolennixCore
import SolennixNetwork

private struct QuickQuotePDFClientPayload: Encodable {
    let name: String
    let phone: String
    let email: String?
}

private struct QuickQuotePDFProductPayload: Encodable {
    let productId: String?
    let name: String
    let quantity: Double
    let unitPrice: Double
    let discount: Double
}

private struct QuickQuotePDFExtraPayload: Encodable {
    let description: String
    let cost: Double
    let price: Double
    let excludeUtility: Bool
}

private struct QuickQuotePDFRequestPayload: Encodable {
    let client: QuickQuotePDFClientPayload?
    let products: [QuickQuotePDFProductPayload]
    let extras: [QuickQuotePDFExtraPayload]
    let numPeople: Int
    let discount: Double
    let discountType: String
    let requiresInvoice: Bool
    let taxRate: Double
}

@Observable
public final class QuickQuoteViewModel {
    let apiClient: APIClient

    // Form Data
    public var numPeople: Int = 100
    public var clientName: String = ""
    public var clientPhone: String = ""
    public var clientEmail: String = ""
    public var showClientInfo: Bool = false

    // Items
    public var selectedProducts: [EventProduct] = []
    public var extras: [EventExtra] = []

    // Financials
    public var discountType: DiscountType = .percent
    public var discountValue: Double = 0
    public var requiresInvoice: Bool = false
    public var taxRate: Double = 16

    // Source data
    public var availableProducts: [Product] = []
    public var productUnitCosts: [String: Double] = [:]

    public var isLoading: Bool = true

    // PDF
    public var pdfData: Data?
    public var showShareSheet: Bool = false

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    @MainActor
    public func loadData() async {
        isLoading = true
        do {
            let products: [Product] = try await apiClient.getAll(Endpoint.products)
            availableProducts = products.filter { $0.isActive }
        } catch {
            print("Error loading products for quick quote: \(error)")
        }
        isLoading = false
    }

    // Handlers
    public func addProduct() {
        if let first = availableProducts.first {
            selectedProducts.append(EventProduct(
                id: UUID().uuidString,
                eventId: "quick-quote",
                productId: first.id,
                quantity: 1,
                unitPrice: first.basePrice,
                discount: 0,
                createdAt: ""
            ))
            Task {
                await fetchIngredientCost(for: first.id)
            }
        }
    }

    public func removeProduct(at offsets: IndexSet) {
        selectedProducts.remove(atOffsets: offsets)
    }

    public func addExtra() {
        extras.append(EventExtra(
            id: UUID().uuidString,
            eventId: "quick-quote",
            description: "",
            cost: 0,
            price: 0,
            excludeUtility: false,
            createdAt: ""
        ))
    }

    public func removeExtra(at offsets: IndexSet) {
        extras.remove(atOffsets: offsets)
    }

    @MainActor
    private func fetchIngredientCost(for productId: String) async {
        if productUnitCosts[productId] != nil { return }
        do {
            let ingredients: [ProductIngredient] = try await apiClient.get(Endpoint.productIngredients(productId))
            let cost = ingredients
                .filter { $0.type == .ingredient }
                .reduce(0.0) { sum, ing in
                    sum + (ing.quantityRequired * (ing.unitCost ?? 0.0))
                }
            productUnitCosts[productId] = cost
        } catch {
            print("Error fetching ingredient costs: \(error)")
        }
    }

    public func updateCostsForCurrentProducts() {
        for product in selectedProducts {
            Task {
                await fetchIngredientCost(for: product.productId)
            }
        }
    }

    // Financial calculations
    public var financials: FinancialSummary {
        let productsSubtotal = selectedProducts.reduce(0.0) { sum, item in
            sum + ((item.unitPrice - item.discount) * Double(item.quantity))
        }

        let normalExtrasTotal = extras.filter { !$0.excludeUtility }.reduce(0.0) { $0 + $1.price }
        let passThroughExtrasTotal = extras.filter { $0.excludeUtility }.reduce(0.0) { $0 + $1.price }
        let extrasTotal = extras.reduce(0.0) { $0 + $1.price }

        let discountableBase = productsSubtotal + normalExtrasTotal

        let discountAmount: Double
        if discountType == .percent {
            discountAmount = discountableBase * (discountValue / 100)
        } else {
            discountAmount = min(discountValue, discountableBase)
        }

        let discountedBase = discountableBase - discountAmount
        let baseTotal = discountedBase + passThroughExtrasTotal

        let taxAmount = requiresInvoice ? baseTotal * (taxRate / 100) : 0
        let total = baseTotal + taxAmount

        // Costs
        let productCost = selectedProducts.reduce(0.0) { sum, p in
            sum + ((productUnitCosts[p.productId] ?? 0) * Double(p.quantity))
        }
        let extrasCost = extras.reduce(0.0) { $0 + $1.cost }
        let totalCost = productCost + extrasCost

        let revenue = total - (requiresInvoice ? taxAmount : 0)
        let profit = revenue - totalCost

        let passThroughRevenue = passThroughExtrasTotal
        let adjustedRevenue = revenue - passThroughRevenue
        let margin = adjustedRevenue > 0 ? (profit / adjustedRevenue) * 100 : 0

        return FinancialSummary(
            productsSubtotal: productsSubtotal,
            extrasTotal: extrasTotal,
            discountAmount: discountAmount,
            taxAmount: taxAmount,
            total: total,
            productCost: productCost,
            extrasCost: extrasCost,
            totalCost: totalCost,
            profit: profit,
            margin: margin
        )
    }

    // MARK: - PDF Generation

    /// Downloads a backend-generated quick quote PDF using current form data.
    @MainActor
    public func generatePDF() async {
        let validProducts = selectedProducts.filter { !$0.productId.isEmpty && $0.quantity > 0 }
        let validExtras = extras.filter { !$0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        guard !validProducts.isEmpty || !validExtras.isEmpty else {
            return
        }

        let payload = QuickQuotePDFRequestPayload(
            client: clientName.isEmpty ? nil : QuickQuotePDFClientPayload(
                name: clientName,
                phone: clientPhone,
                email: clientEmail.isEmpty ? nil : clientEmail
            ),
            products: validProducts.map { product in
                QuickQuotePDFProductPayload(
                    productId: product.productId,
                    name: availableProducts.first(where: { $0.id == product.productId })?.name ?? QuickQuoteStrings.product,
                    quantity: Double(product.quantity),
                    unitPrice: product.unitPrice,
                    discount: product.discount
                )
            },
            extras: validExtras.map { extra in
                QuickQuotePDFExtraPayload(
                    description: extra.description,
                    cost: extra.cost,
                    price: extra.price,
                    excludeUtility: extra.excludeUtility
                )
            },
            numPeople: numPeople,
            discount: discountValue,
            discountType: discountType == .percent ? "percent" : "fixed",
            requiresInvoice: requiresInvoice,
            taxRate: taxRate
        )

        do {
            pdfData = try await apiClient.postData(Endpoint.quickQuotePDF, body: payload)
            showShareSheet = true
        } catch {
            pdfData = nil
            showShareSheet = false
        }
    }
}

public struct FinancialSummary {
    public let productsSubtotal: Double
    public let extrasTotal: Double
    public let discountAmount: Double
    public let taxAmount: Double
    public let total: Double
    public let productCost: Double
    public let extrasCost: Double
    public let totalCost: Double
    public let profit: Double
    public let margin: Double
}
