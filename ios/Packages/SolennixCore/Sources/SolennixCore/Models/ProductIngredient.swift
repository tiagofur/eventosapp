import Foundation

public struct ProductIngredient: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let productId: String
    public let inventoryId: String
    public let quantityRequired: Double
    public var capacity: Double?
    public var bringToEvent: Bool?
    public let createdAt: String
    // Flattened inventory joined fields
    public var ingredientName: String?
    public var unit: String?
    public var unitCost: Double?
    public var type: InventoryType?

    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case inventoryId = "inventory_id"
        case quantityRequired = "quantity_required"
        case capacity
        case bringToEvent = "bring_to_event"
        case createdAt = "created_at"
        case ingredientName = "ingredient_name"
        case unit
        case unitCost = "unit_cost"
        case type
    }
}
