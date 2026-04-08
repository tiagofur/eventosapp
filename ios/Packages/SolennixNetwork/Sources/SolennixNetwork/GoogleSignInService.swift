import Foundation
import GoogleSignIn

// MARK: - Google Sign In Result

/// The result of a successful Google Sign-In.
public struct GoogleSignInResult: Sendable {
    /// The Google ID token (JWT) to send to the backend.
    public let idToken: String

    /// The user's display name, if available.
    public let fullName: String?

    /// The user's email address.
    public let email: String?
}

// MARK: - Google Sign In Error

/// Errors that can occur during the Google Sign-In flow.
public enum GoogleSignInError: LocalizedError {
    case missingIDToken
    case cancelled
    case failed(Error)

    public var errorDescription: String? {
        switch self {
        case .missingIDToken:
            return "No se recibio el token de identidad de Google."
        case .cancelled:
            return "Inicio de sesion con Google cancelado."
        case .failed(let error):
            return "Error en Google Sign In: \(error.localizedDescription)"
        }
    }
}

// MARK: - Google Sign In Service Protocol

/// Abstraction for Google Sign-In, enabling dependency injection and testability.
@MainActor
public protocol GoogleSignInServiceProtocol: Sendable {
    /// Perform Google Sign-In by presenting the sign-in sheet.
    func signIn() async throws -> GoogleSignInResult
}

// MARK: - Google Sign In Service

/// Handles the Google Sign-In flow using the GoogleSignIn SDK.
///
/// Usage:
/// ```swift
/// let service = GoogleSignInService()
/// let result = try await service.signIn()
/// // Send result.idToken to your backend via AuthManager.signInWithGoogle
/// ```
@MainActor
public final class GoogleSignInService: GoogleSignInServiceProtocol {

    public init() {}

    /// Perform Google Sign-In by presenting the sign-in sheet.
    /// - Returns: A `GoogleSignInResult` containing the ID token and user info.
    public func signIn() async throws -> GoogleSignInResult {
        // Pick the foreground-active window scene's key window's root VC.
        // `connectedScenes.first` can return a background scene on iPad
        // multi-window, which causes the Google sheet to attach to the
        // wrong window or fail silently.
        let activeScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)

        let keyWindow = activeScene?.windows.first(where: { $0.isKeyWindow })
            ?? activeScene?.windows.first

        guard let rootViewController = keyWindow?.rootViewController else {
            throw GoogleSignInError.failed(
                NSError(domain: "GoogleSignIn", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
            )
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                throw GoogleSignInError.missingIDToken
            }

            return GoogleSignInResult(
                idToken: idToken,
                fullName: result.user.profile?.name,
                email: result.user.profile?.email
            )
        } catch let error as GIDSignInError where error.code == .canceled {
            throw GoogleSignInError.cancelled
        } catch let error as GIDSignInError where error.code == .hasNoAuthInKeychain {
            // No saved auth session — treat as needing fresh sign-in, not a failure
            throw GoogleSignInError.cancelled
        } catch {
            throw GoogleSignInError.failed(error)
        }
    }
}
