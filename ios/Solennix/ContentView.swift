import SwiftUI
import SolennixNetwork
import SolennixDesign

// MARK: - Content View

/// The root view of the app. Switches between auth, biometric gate,
/// splash, and the main layout based on `AuthManager.authState`.
struct ContentView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var deepLinkResetToken: String?

    var body: some View {
        Group {
            switch authManager.authState {
            case .unknown:
                SplashView()

            case .unauthenticated:
                AuthFlowView(deepLinkResetToken: $deepLinkResetToken)

            case .biometricLocked:
                BiometricGateView()

            case .authenticated:
                mainLayout
            }
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }

    // MARK: - Main Layout

    /// Adaptive layout: compact (iPhone) uses tabs, regular (iPad/Mac) uses sidebar.
    @ViewBuilder
    private var mainLayout: some View {
        if sizeClass == .compact {
            CompactTabLayout()
        } else {
            SidebarSplitLayout()
        }
    }

    // MARK: - Deep Link Handling

    private func handleDeepLink(_ url: URL) {
        guard let action = DeepLinkHandler.handle(url) else { return }

        switch action {
        case .resetPassword(let token):
            deepLinkResetToken = token
        }
    }
}

// MARK: - Splash View

/// A minimal splash screen shown while the auth state is being determined.
struct SplashView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)

            Text("SOLENNIX")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(SolennixColors.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SolennixColors.background)
    }
}

// MARK: - Biometric Gate View

/// Shown when the user has tokens but biometric unlock is required.
/// Prompts for Face ID / Touch ID, with a fallback to re-login.
struct BiometricGateView: View {

    @Environment(AuthManager.self) private var authManager
    @State private var showError = false
    @State private var failureCount = 0

    private let maxAttempts = 3

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "faceid")
                .font(.system(size: 64))
                .foregroundStyle(SolennixColors.primary)

            Text("SOLENNIX")
                .font(.title)
                .fontWeight(.bold)

            Text("Desbloquea para continuar")
                .font(.subheadline)
                .foregroundStyle(SolennixColors.textSecondary)

            if showError {
                Text("No se pudo verificar tu identidad")
                    .font(.footnote)
                    .foregroundStyle(SolennixColors.error)
            }

            Button("Desbloquear") {
                Task { await authenticate() }
            }
            .buttonStyle(.borderedProminent)
            .tint(SolennixColors.primary)

            Spacer()

            if failureCount >= maxAttempts {
                Button("Iniciar sesion de nuevo") {
                    authManager.clearTokens()
                }
                .font(.footnote)
                .foregroundStyle(SolennixColors.textSecondary)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SolennixColors.background)
        .task {
            await authenticate()
        }
    }

    private func authenticate() async {
        do {
            let success = try await authManager.authenticateWithBiometrics()
            if success {
                // The authManager should transition to .authenticated
                // after biometric unlock. We trigger checkAuth to do that.
                await authManager.checkAuth()
            } else {
                failureCount += 1
                showError = true
            }
        } catch {
            failureCount += 1
            showError = true
            if failureCount >= maxAttempts {
                authManager.clearTokens()
            }
        }
    }
}

// MARK: - Preview

#Preview("Authenticated - Compact") {
    let keychain = KeychainHelper.standard
    let auth = AuthManager(keychain: keychain)

    ContentView()
        .environment(auth)
}
