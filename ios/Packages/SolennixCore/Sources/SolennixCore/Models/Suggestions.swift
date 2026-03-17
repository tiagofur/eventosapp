import Foundation

// MARK: - ConflictType

public enum ConflictType: String, Codable, Sendable, CaseIterable, Hashable {
    case overlap
    case insufficientGap = "insufficient_gap"
    case fullDay = "full_day"
}

// MARK: - SupplySuggestion

public struct SupplySuggestion: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let ingredientName: String
    public let currentStock: Double
    public let unit: String
    public let unitCost: Double
    public let suggestedQuantity: Double

    enum CodingKeys: String, CodingKey {
        case id
        case ingredientName = "ingredient_name"
        case currentStock = "current_stock"
        case unit
        case unitCost = "unit_cost"
        case suggestedQuantity = "suggested_quantity"
    }
}

// MARK: - EquipmentSuggestion

public struct EquipmentSuggestion: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let ingredientName: String
    public let currentStock: Double
    public let unit: String
    public let type: String
    public let suggestedQuantity: Double

    enum CodingKeys: String, CodingKey {
        case id
        case ingredientName = "ingredient_name"
        case currentStock = "current_stock"
        case unit
        case type
        case suggestedQuantity = "suggested_quantity"
    }
}

// MARK: - EquipmentConflict

public struct EquipmentConflict: Codable, Sendable, Hashable {
    public let inventoryId: String
    public let equipmentName: String
    public let conflictingEventId: String
    public let eventDate: String
    public var startTime: String?
    public var endTime: String?
    public let serviceType: String
    public var clientName: String?
    public let conflictType: ConflictType

    enum CodingKeys: String, CodingKey {
        case inventoryId = "inventory_id"
        case equipmentName = "equipment_name"
        case conflictingEventId = "conflicting_event_id"
        case eventDate = "event_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case serviceType = "service_type"
        case clientName = "client_name"
        case conflictType = "conflict_type"
    }
}
