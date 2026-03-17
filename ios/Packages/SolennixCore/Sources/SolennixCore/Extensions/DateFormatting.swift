import Foundation

// MARK: - Date Formatting Extensions

extension Date {

    private static let mexicanLocale = Locale(identifier: "es_MX")
    private static let mexicanTimeZone = TimeZone(identifier: "America/Mexico_City")!

    // MARK: - ISO 8601 Parsing

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatterNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    /// Parse an ISO 8601 date string (with or without fractional seconds).
    public static func from(isoString: String) -> Date? {
        isoFormatter.date(from: isoString)
            ?? isoFormatterNoFraction.date(from: isoString)
    }

    // MARK: - Short Date (e.g., "17 mar 2026")

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = mexicanLocale
        formatter.timeZone = mexicanTimeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    /// Formats as short date: "17 mar 2026"
    public var shortDate: String {
        Self.shortDateFormatter.string(from: self)
    }

    // MARK: - Long Date (e.g., "martes, 17 de marzo de 2026")

    private static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = mexicanLocale
        formatter.timeZone = mexicanTimeZone
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()

    /// Formats as long date: "martes, 17 de marzo de 2026"
    public var longDate: String {
        Self.longDateFormatter.string(from: self)
    }

    // MARK: - Time Only (e.g., "14:30")

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = mexicanLocale
        formatter.timeZone = mexicanTimeZone
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    /// Formats as time only: "14:30"
    public var timeOnly: String {
        Self.timeFormatter.string(from: self)
    }

    // MARK: - Custom Format

    /// Formats the date using a custom format string with es_MX locale.
    public func formatted(style: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Self.mexicanLocale
        formatter.timeZone = Self.mexicanTimeZone
        formatter.dateFormat = style
        return formatter.string(from: self)
    }
}
