import Foundation

// MARK: - Common Formatting

enum CommonFormatting {
    static func currencyMXN(_ amount: Double, fractionDigits: Int = 2, locale: Locale = Locale(identifier: "es_MX")) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        formatter.locale = locale
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }

    static func dateTimeFromISO(_ isoString: String, locale: Locale = Locale(identifier: "es_MX")) -> String {
        let isoFormatterFull = ISO8601DateFormatter()
        isoFormatterFull.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let isoFormatterBasic = ISO8601DateFormatter()
        isoFormatterBasic.formatOptions = [.withInternetDateTime]

        let date = isoFormatterFull.date(from: isoString) ?? isoFormatterBasic.date(from: isoString)
        guard let date else { return isoString }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = locale
        return formatter.string(from: date)
    }
}
