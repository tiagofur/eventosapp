import Foundation

// MARK: - Deep Link Action

/// Actions that can be triggered by opening a deep link URL.
enum DeepLinkAction: Equatable {
    case resetPassword(token: String)
}

// MARK: - Deep Link Handler

/// Parses `solennix://` scheme URLs into `DeepLinkAction` values.
///
/// Supported deep links:
/// - `solennix://reset-password?token=<TOKEN>` — Navigate to the password reset flow.
enum DeepLinkHandler {

    /// Parse a URL into a deep link action.
    /// - Parameter url: The URL to parse (must use the `solennix` scheme).
    /// - Returns: A `DeepLinkAction` if the URL is recognized, or `nil`.
    static func handle(_ url: URL) -> DeepLinkAction? {
        guard url.scheme == "solennix" else { return nil }

        switch url.host {
        case "reset-password":
            guard let token = url.queryParameters["token"], !token.isEmpty else {
                return nil
            }
            return .resetPassword(token: token)

        default:
            return nil
        }
    }
}

// MARK: - URL Query Parameters Extension

extension URL {

    /// Parses the query string into a dictionary of key-value pairs.
    ///
    /// Example:
    /// ```
    /// let url = URL(string: "solennix://reset-password?token=abc123")!
    /// url.queryParameters["token"] // "abc123"
    /// ```
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return [:]
        }
        var params: [String: String] = [:]
        for item in queryItems {
            if let value = item.value {
                params[item.name] = value
            }
        }
        return params
    }
}
