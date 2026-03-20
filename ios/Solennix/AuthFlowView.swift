import SwiftUI
import SolennixNetwork
import SolennixDesign
import SolennixFeatures

// MARK: - Auth Flow View

/// Wraps the authentication screens in a NavigationStack.
///
/// Root: LoginView (SolennixFeatures)
/// Navigation: RegisterView, ForgotPasswordView handled internally by LoginView
/// Deep link: ResetPasswordView triggered via binding from ContentView
struct AuthFlowView: View {

    /// Token received from a deep link, triggers navigation to ResetPasswordView.
    @Binding var deepLinkResetToken: String?

    @State private var showResetPasswordSheet = false

    var body: some View {
        NavigationStack {
            LoginView()
        }
        .sheet(isPresented: $showResetPasswordSheet) {
            deepLinkResetToken = nil
        } content: {
            if let token = deepLinkResetToken {
                NavigationStack {
                    ResetPasswordView(token: token)
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

// MARK: - Preview

#Preview {
    let auth = AuthManager()
    AuthFlowView(deepLinkResetToken: .constant(nil))
        .environment(auth)
}
