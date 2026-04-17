import Foundation

// MARK: - Event Staff (asignacion de personal a evento)

/// Asignacion de un `Staff` a un evento. El costo (`feeAmount`) vive en la
/// asignacion — NO en el Staff — porque el mismo colaborador puede cobrar
/// distintas tarifas en distintos eventos.
public struct EventStaff: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let eventId: String
    public let staffId: String
    public var feeAmount: Double?
    public var roleOverride: String?
    public var notes: String?
    public var notificationSentAt: String?
    public var notificationLastResult: String?
    public let createdAt: String

    // MARK: - Joined (staff_*)

    public var staffName: String?
    public var staffRoleLabel: String?
    public var staffPhone: String?
    public var staffEmail: String?

    // MARK: - Init

    public init(
        id: String,
        eventId: String,
        staffId: String,
        feeAmount: Double? = nil,
        roleOverride: String? = nil,
        notes: String? = nil,
        notificationSentAt: String? = nil,
        notificationLastResult: String? = nil,
        createdAt: String,
        staffName: String? = nil,
        staffRoleLabel: String? = nil,
        staffPhone: String? = nil,
        staffEmail: String? = nil
    ) {
        self.id = id
        self.eventId = eventId
        self.staffId = staffId
        self.feeAmount = feeAmount
        self.roleOverride = roleOverride
        self.notes = notes
        self.notificationSentAt = notificationSentAt
        self.notificationLastResult = notificationLastResult
        self.createdAt = createdAt
        self.staffName = staffName
        self.staffRoleLabel = staffRoleLabel
        self.staffPhone = staffPhone
        self.staffEmail = staffEmail
    }
}
