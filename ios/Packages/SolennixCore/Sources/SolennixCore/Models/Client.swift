import Foundation

public struct Client: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let userId: String
    public let name: String
    public let phone: String
    public var email: String?
    public var address: String?
    public var city: String?
    public var notes: String?
    public var photoUrl: String?
    public var totalEvents: Int?
    public var totalSpent: Double?
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case phone
        case email
        case address
        case city
        case notes
        case photoUrl = "photo_url"
        case totalEvents = "total_events"
        case totalSpent = "total_spent"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
