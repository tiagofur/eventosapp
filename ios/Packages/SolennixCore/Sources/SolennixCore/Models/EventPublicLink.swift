import Foundation

/// Status of an `EventPublicLink` as returned by the backend.
/// Matches `events.event_public_links.status` in the API contract
/// (PRD/12 feature A — Portal del cliente).
public enum EventPublicLinkStatus: String, Codable, Sendable {
    case active
    case revoked
    case expired
}

/// Private share link that an organizer generates so their client can
/// consult the event details (schedule, payment status, notes) via a
/// token-based public page. Only one link per event is active at a time;
/// creating a new one revokes the previous one server-side.
public struct EventPublicLink: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let eventId: String
    public let userId: String
    public let token: String
    public let status: EventPublicLinkStatus
    /// ISO 8601 UTC. `nil` when the link never expires — the organizer can
    /// still revoke it manually.
    public let expiresAt: String?
    /// ISO 8601 UTC. Set once the link is revoked; `nil` while active.
    public let revokedAt: String?
    public let createdAt: String
    public let updatedAt: String
    /// Absolute URL the organizer shares with the client — server-computed.
    public let url: String

    // MARK: - Init

    public init(
        id: String,
        eventId: String,
        userId: String,
        token: String,
        status: EventPublicLinkStatus,
        expiresAt: String? = nil,
        revokedAt: String? = nil,
        createdAt: String,
        updatedAt: String,
        url: String
    ) {
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.token = token
        self.status = status
        self.expiresAt = expiresAt
        self.revokedAt = revokedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.url = url
    }
}
