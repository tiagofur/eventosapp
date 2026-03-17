import Foundation

// MARK: - Plan

public enum Plan: String, Codable, Sendable, CaseIterable, Hashable {
    case basic
    case premium
}

// MARK: - User

public struct User: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let email: String
    public let name: String
    public var businessName: String?
    public var logoUrl: String?
    public var brandColor: String?
    public var showBusinessNameInPdf: Bool?
    public var defaultDepositPercent: Double?
    public var defaultCancellationDays: Double?
    public var defaultRefundPercent: Double?
    public var contractTemplate: String?
    public let plan: Plan
    public var stripeCustomerId: String?
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case businessName = "business_name"
        case logoUrl = "logo_url"
        case brandColor = "brand_color"
        case showBusinessNameInPdf = "show_business_name_in_pdf"
        case defaultDepositPercent = "default_deposit_percent"
        case defaultCancellationDays = "default_cancellation_days"
        case defaultRefundPercent = "default_refund_percent"
        case contractTemplate = "contract_template"
        case plan
        case stripeCustomerId = "stripe_customer_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
