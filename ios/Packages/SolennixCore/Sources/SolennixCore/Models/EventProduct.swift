import Foundation

public struct EventProduct: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let eventId: String
    public let productId: String
    public let quantity: Int
    public let unitPrice: Double
    public let discount: Double
    public var totalPrice: Double?
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case productId = "product_id"
        case quantity
        case unitPrice = "unit_price"
        case discount
        case totalPrice = "total_price"
        case createdAt = "created_at"
    }
}
