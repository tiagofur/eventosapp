import Foundation
import SwiftData

// MARK: - CachedInventoryItem

/// SwiftData model mirroring the `InventoryItem` struct for offline caching.
@Model
public final class CachedInventoryItem {

    // MARK: - Properties

    @Attribute(.unique)
    public var id: String

    public var userId: String
    public var ingredientName: String
    public var currentStock: Double
    public var minimumStock: Double
    public var unit: String
    public var unitCost: Double?
    public var lastUpdated: String
    public var typeRawValue: String

    // MARK: - Init

    public init(
        id: String,
        userId: String,
        ingredientName: String,
        currentStock: Double,
        minimumStock: Double,
        unit: String,
        unitCost: Double? = nil,
        lastUpdated: String,
        typeRawValue: String
    ) {
        self.id = id
        self.userId = userId
        self.ingredientName = ingredientName
        self.currentStock = currentStock
        self.minimumStock = minimumStock
        self.unit = unit
        self.unitCost = unitCost
        self.lastUpdated = lastUpdated
        self.typeRawValue = typeRawValue
    }

    /// Creates a cached version from an `InventoryItem` struct.
    public convenience init(from item: InventoryItem) {
        self.init(
            id: item.id,
            userId: item.userId,
            ingredientName: item.ingredientName,
            currentStock: item.currentStock,
            minimumStock: item.minimumStock,
            unit: item.unit,
            unitCost: item.unitCost,
            lastUpdated: item.lastUpdated,
            typeRawValue: item.type.rawValue
        )
    }

    // MARK: - Conversion

    /// Converts this cached model back to an `InventoryItem` value type.
    public func toInventoryItem() -> InventoryItem {
        InventoryItem(
            id: id,
            userId: userId,
            ingredientName: ingredientName,
            currentStock: currentStock,
            minimumStock: minimumStock,
            unit: unit,
            unitCost: unitCost,
            lastUpdated: lastUpdated,
            type: InventoryType(rawValue: typeRawValue) ?? .ingredient
        )
    }
}
