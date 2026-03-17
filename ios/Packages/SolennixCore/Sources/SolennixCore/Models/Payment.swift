import Foundation

public struct Payment: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let eventId: String
    public let userId: String
    public let amount: Double
    public let paymentDate: String
    public let paymentMethod: String
    public var notes: String?
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case amount
        case paymentDate = "payment_date"
        case paymentMethod = "payment_method"
        case notes
        case createdAt = "created_at"
    }
}
