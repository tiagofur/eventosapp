import Foundation
import SwiftData

// MARK: - CachedPayment

/// SwiftData model mirroring the `Payment` struct for offline caching.
@Model
public final class CachedPayment {

    // MARK: - Properties

    @Attribute(.unique)
    public var id: String

    public var eventId: String
    public var userId: String
    public var amount: Double
    public var paymentDate: String
    public var paymentMethod: String
    public var notes: String?
    public var createdAt: String

    // MARK: - Init

    public init(
        id: String,
        eventId: String,
        userId: String,
        amount: Double,
        paymentDate: String,
        paymentMethod: String,
        notes: String? = nil,
        createdAt: String
    ) {
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.amount = amount
        self.paymentDate = paymentDate
        self.paymentMethod = paymentMethod
        self.notes = notes
        self.createdAt = createdAt
    }

    /// Creates a cached version from a `Payment` struct.
    public convenience init(from payment: Payment) {
        self.init(
            id: payment.id,
            eventId: payment.eventId,
            userId: payment.userId,
            amount: payment.amount,
            paymentDate: payment.paymentDate,
            paymentMethod: payment.paymentMethod,
            notes: payment.notes,
            createdAt: payment.createdAt
        )
    }

    // MARK: - Conversion

    /// Converts this cached model back to a `Payment` value type.
    public func toPayment() -> Payment {
        Payment(
            id: id,
            eventId: eventId,
            userId: userId,
            amount: amount,
            paymentDate: paymentDate,
            paymentMethod: paymentMethod,
            notes: notes,
            createdAt: createdAt
        )
    }
}
