import Foundation

// MARK: - SupplySource

public enum SupplySource: String, Codable, Sendable, CaseIterable, Hashable {
    case stock
    case purchase
}

// MARK: - EventSupply

public struct EventSupply: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let eventId: String
    public let inventoryId: String
    public let quantity: Double
    public let unitCost: Double
    public let source: SupplySource
    public let excludeCost: Bool
    public let createdAt: String
    // Denormalized joined fields
    public var supplyName: String?
    public var unit: String?
    public var currentStock: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case inventoryId = "inventory_id"
        case quantity
        case unitCost = "unit_cost"
        case source
        case excludeCost = "exclude_cost"
        case createdAt = "created_at"
        case supplyName = "supply_name"
        case unit
        case currentStock = "current_stock"
    }
}
