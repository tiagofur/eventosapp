import Foundation

public struct EventExtra: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let eventId: String
    public let description: String
    public let cost: Double
    public let price: Double
    public let excludeUtility: Bool
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case description
        case cost
        case price
        case excludeUtility = "exclude_utility"
        case createdAt = "created_at"
    }
}
