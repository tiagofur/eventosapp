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
    @Binding var deepLinkTeamInviteToken: String?

    @State private var showResetPasswordSheet = false
    @State private var showTeamInviteSheet = false

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
        .sheet(isPresented: $showTeamInviteSheet) {
            deepLinkTeamInviteToken = nil
        } content: {
            if let token = deepLinkTeamInviteToken {
                NavigationStack {
                    TeamInviteAcceptView(token: token)
                }
            }
        }
        .onChange(of: deepLinkResetToken) { _, newValue in
            if newValue != nil {
                showResetPasswordSheet = true
            }
        }
        .onChange(of: deepLinkTeamInviteToken) { _, newValue in
            if newValue != nil {
                showTeamInviteSheet = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let auth = AuthManager()
    AuthFlowView(
        deepLinkResetToken: .constant(nil),
        deepLinkTeamInviteToken: .constant(nil)
    )
        .environment(auth)
}
