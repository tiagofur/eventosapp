import Foundation
import Observation
import SolennixCore
import SolennixNetwork

/// Single view model shared across all auth screens (Login, Register, ForgotPassword, ResetPassword).
///
/// Manages form state, validation (Spanish messages), and API calls via `AuthManager`.
@Observable
public final class AuthViewModel {

    // MARK: - Form Fields

    public var email: String = ""
    public var password: String = ""
    public var confirmPassword: String = ""
    public var name: String = ""

    // MARK: - UI State

    public var isLoading: Bool = false
    public var errorMessage: String?
    public var isPasswordVisible: Bool = false
    public var isConfirmPasswordVisible: Bool = false
    public var showSuccess: Bool = false

    // MARK: - Dependencies

    private let authManager: AuthManager

    // MARK: - Init

    public init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Validation Helpers

    public var isLoginValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !password.isEmpty
    }

    public var isRegisterValid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
        && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && password.count >= 6
        && password == confirmPassword
    }

    public var isForgotValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var isResetValid: Bool {
        password.count >= 6 && password == confirmPassword
    }

    // MARK: - Sign In

    @MainActor
    public func signIn() async {
        // Validate
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "El correo electronico es requerido"
            return
        }
        guard !password.isEmpty else {
            errorMessage = "La contrasena es requerida"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authManager.signIn(email: trimmedEmail, password: password)
        } catch {
            errorMessage = mapError(error)
        }

        isLoading = false
    }

    // MARK: - Sign Up

    @MainActor
    public func signUp() async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedName.count >= 2 else {
            errorMessage = "El nombre debe tener al menos 2 caracteres"
            return
        }
        guard !trimmedEmail.isEmpty else {
            errorMessage = "El correo electronico es requerido"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "La contrasena debe tener al menos 6 caracteres"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Las contrasenas no coinciden"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authManager.signUp(
                name: trimmedName,
                email: trimmedEmail,
                password: password
            )
        } catch {
            errorMessage = mapError(error)
        }

        isLoading = false
    }

    // MARK: - Sign In with Apple

    @MainActor
    public func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let service = AppleSignInService()
            let result = try await service.signIn()

            // Build full name from PersonNameComponents
            var fullName: String?
            if let nameComponents = result.fullName {
                let formatter = PersonNameComponentsFormatter()
                let name = formatter.string(from: nameComponents)
                if !name.isEmpty {
                    fullName = name
                }
            }

            _ = try await authManager.signInWithApple(
                identityToken: result.identityToken,
                authorizationCode: result.authorizationCode,
                fullName: fullName,
                email: result.email
            )
        } catch let error as AppleSignInError {
            if case .cancelled = error { return }
            errorMessage = mapError(error)
        } catch {
            errorMessage = mapError(error)
        }
    }

    // MARK: - Sign In with Google

    @MainActor
    public func signInWithGoogle(idToken: String, fullName: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await authManager.signInWithGoogle(idToken: idToken, fullName: fullName)
        } catch {
            errorMessage = mapError(error)
        }

        isLoading = false
    }

    // MARK: - Forgot Password

    @MainActor
    public func forgotPassword() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            errorMessage = "El correo electronico es requerido"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            guard let client = authManager.apiClient else {
                throw APIError.unknown
            }
            let body = ["email": trimmedEmail]
            let _: EmptyResponse = try await client.post(Endpoint.forgotPassword, body: body)
            showSuccess = true
        } catch {
            // Always show success for forgot password (backend returns 200 even for non-existent emails)
            showSuccess = true
        }

        isLoading = false
    }

    // MARK: - Reset Password

    @MainActor
    public func resetPassword(token: String) async {
        guard password.count >= 6 else {
            errorMessage = "La contrasena debe tener al menos 6 caracteres"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Las contrasenas no coinciden"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            guard let client = authManager.apiClient else {
                throw APIError.unknown
            }
            let body: [String: String] = ["token": token, "password": password]
            let _: EmptyResponse = try await client.post(Endpoint.resetPassword, body: body)
            showSuccess = true
        } catch {
            errorMessage = mapError(error)
        }

        isLoading = false
    }

    // MARK: - Helpers

    public func clearError() {
        errorMessage = nil
    }

    /// Reset all form fields (useful when navigating between auth screens).
    public func resetFields() {
        email = ""
        password = ""
        confirmPassword = ""
        name = ""
        errorMessage = nil
        showSuccess = false
        isPasswordVisible = false
        isConfirmPasswordVisible = false
    }

    // MARK: - Error Mapping

    private func mapError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .unauthorized:
                return "Credenciales invalidas. Verifica tu correo y contrasena."
            case .serverError(let statusCode, let message):
                if statusCode == 409 {
                    return "Ya existe una cuenta con este correo electronico."
                }
                return message
            case .networkError:
                return "Error de conexion. Verifica tu internet e intenta de nuevo."
            default:
                return apiError.errorDescription ?? "Ocurrio un error inesperado."
            }
        }
        return "Ocurrio un error inesperado. Intenta de nuevo."
    }
}
