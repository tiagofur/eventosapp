import Foundation

public struct EventEquipment: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let eventId: String
    public let inventoryId: String
    public let quantity: Int
    public var notes: String?
    public let createdAt: String
    // Denormalized joined fields
    public var equipmentName: String?
    public var unit: String?
    public var currentStock: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case inventoryId = "inventory_id"
        case quantity
        case notes
        case createdAt = "created_at"
        case equipmentName = "equipment_name"
        case unit
        case currentStock = "current_stock"
    }
}
