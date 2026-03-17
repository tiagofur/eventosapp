import SwiftUI
import SolennixNetwork
import SolennixDesign

// MARK: - Auth Flow View

/// Wraps the authentication screens in a NavigationStack.
///
/// Root: LoginView (placeholder in Phase 1)
/// Push destinations: RegisterView, ForgotPasswordView
/// Deep link: ResetPasswordView triggered via binding from ContentView
struct AuthFlowView: View {

    /// Token received from a deep link, triggers navigation to ResetPasswordView.
    @Binding var deepLinkResetToken: String?

    @State private var path = NavigationPath()
    @State private var showResetPasswordSheet = false

    var body: some View {
        NavigationStack(path: $path) {
            LoginPlaceholderView(path: $path)
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .register:
                        RegisterPlaceholderView()
                    case .forgotPassword:
                        ForgotPasswordPlaceholderView()
                    }
                }
        }
        .sheet(isPresented: $showResetPasswordSheet) {
            deepLinkResetToken = nil
        } content: {
            if let token = deepLinkResetToken {
                NavigationStack {
                    ResetPasswordPlaceholderView(token: token)
                }
            }
        }
        .onChange(of: deepLinkResetToken) { _, newValue in
            if newValue != nil {
                showResetPasswordSheet = true
            }
        }
    }
}

// MARK: - Auth Route

/// Internal navigation routes for the auth flow.
enum AuthRoute: Hashable {
    case register
    case forgotPassword
}

// MARK: - Login Placeholder

/// Placeholder for LoginView. Will be replaced by SolennixFeatures.Auth.LoginView.
private struct LoginPlaceholderView: View {

    @Binding var path: NavigationPath
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo area
            VStack(spacing: 8) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(SolennixColors.primary)

                Text("SOLENNIX")
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundStyle(SolennixColors.text)

                Text("CADA DETALLE IMPORTA")
                    .font(.caption)
                    .tracking(5.5)
                    .foregroundStyle(SolennixColors.textSecondary)
            }

            Spacer()

            // Placeholder content
            VStack(spacing: 12) {
                Text("Pantalla de Login")
                    .font(.headline)
                Text("Disponible en Fase 1 (SolennixFeatures)")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Navigation links
            VStack(spacing: 12) {
                Button("Ir a Registro") {
                    path.append(AuthRoute.register)
                }
                .buttonStyle(.borderedProminent)
                .tint(SolennixColors.primary)

                Button("Olvidaste tu contrasena?") {
                    path.append(AuthRoute.forgotPassword)
                }
                .font(.footnote)
                .foregroundStyle(SolennixColors.primary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(SolennixColors.background)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

// MARK: - Register Placeholder

private struct RegisterPlaceholderView: View {
    var body: some View {
        PlaceholderView(title: "Crear Cuenta", phase: 1)
            .navigationTitle("Crear Cuenta")
    }
}

// MARK: - Forgot Password Placeholder

private struct ForgotPasswordPlaceholderView: View {
    var body: some View {
        PlaceholderView(title: "Recuperar Contrasena", phase: 1)
            .navigationTitle("Recuperar Contrasena")
    }
}

// MARK: - Reset Password Placeholder

private struct ResetPasswordPlaceholderView: View {

    let token: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 48))
                .foregroundStyle(SolennixColors.primary)

            Text("Nueva Contrasena")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Token: \(token)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospaced()

            Text("Disponible en Fase 1 (SolennixFeatures)")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Nueva Contrasena")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cerrar") {
                    // Dismiss handled by sheet
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let auth = AuthManager()
    AuthFlowView(deepLinkResetToken: .constant(nil))
        .environment(auth)
}
