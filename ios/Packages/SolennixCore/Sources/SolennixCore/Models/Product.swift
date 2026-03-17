import Foundation

public struct Product: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let userId: String
    public let name: String
    public let category: String
    public let basePrice: Double
    public var recipe: AnyCodable?
    public var imageUrl: String?
    public let isActive: Bool
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case category
        case basePrice = "base_price"
        case recipe
        case imageUrl = "image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
