import SwiftUI
import SolennixDesign
import SolennixNetwork

// MARK: - Team Invite Accept View

public struct TeamInviteAcceptView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var viewModel: AuthViewModel?

    let token: String

    public init(token: String) {
        self.token = token
    }

    private func tr(_ key: String, _ value: String) -> String {
        FeatureL10n.text(key, value)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                if viewModel?.showSuccess == true {
                    successState
                } else {
                    formState
                }
            }
            .padding(.horizontal, sizeClass == .regular ? Spacing.xxxl : Spacing.xl)
            .padding(.vertical, Spacing.xxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(SolennixColors.surfaceGrouped.ignoresSafeArea())
        .navigationTitle(tr("auth.team_invite.title", "Activar acceso"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(authManager: authManager)
            }
        }
    }

    // MARK: - Form

    private var formState: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: "person.badge.key.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(SolennixColors.primary)

                Text(tr("auth.team_invite.subtitle", "Crea tu contraseña para ingresar al portal del equipo."))
                    .font(.body)
                    .foregroundStyle(SolennixColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.lg)

            if let error = viewModel?.errorMessage {
                errorBanner(message: error)
            }

            SolennixTextField(
                label: tr("auth.team_invite.password_label", "Contraseña"),
                text: Binding(
                    get: { viewModel?.password ?? "" },
                    set: { viewModel?.password = $0 }
                ),
                placeholder: tr("auth.team_invite.password_placeholder", "Mínimo 8 caracteres"),
                leftIcon: "lock",
                isSecure: true,
                textContentType: .newPassword
            )

            SolennixTextField(
                label: tr("auth.team_invite.confirm_label", "Confirmar contraseña"),
                text: Binding(
                    get: { viewModel?.confirmPassword ?? "" },
                    set: { viewModel?.confirmPassword = $0 }
                ),
                placeholder: tr("auth.team_invite.confirm_placeholder", "Repite tu contraseña"),
                leftIcon: "lock",
                isSecure: true,
                textContentType: .newPassword
            )

            PremiumButton(
                title: tr("auth.team_invite.submit", "Aceptar invitación"),
                isLoading: viewModel?.isLoading ?? false,
                isDisabled: !(viewModel?.isResetValid ?? false)
            ) {
                Task { await viewModel?.acceptTeamInvite(token: token) }
            }

            Button {
                dismiss()
            } label: {
                Text(tr("auth.team_invite.back_to_login", "Volver al inicio de sesión"))
                    .font(.body)
                    .foregroundStyle(SolennixColors.primary)
            }
        }
    }

    // MARK: - Success

    private var successState: some View {
        VStack(spacing: Spacing.xl) {
            Spacer(minLength: Spacing.xxxl)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(SolennixColors.success)

            VStack(spacing: Spacing.sm) {
                Text(tr("auth.team_invite.success_title", "Invitación aceptada"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(SolennixColors.text)

                Text(tr("auth.team_invite.success_message", "Tu cuenta del equipo fue activada correctamente."))
                    .font(.body)
                    .foregroundStyle(SolennixColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                dismiss()
            } label: {
                Text(tr("auth.team_invite.go_to_app", "Continuar"))
                    .font(.headline)
                    .foregroundStyle(SolennixColors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(SolennixColors.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }

            Spacer(minLength: Spacing.xxxl)
        }
    }

    // MARK: - Error Banner

    private func errorBanner(message: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(SolennixColors.error)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.sm + 4)
        .background(SolennixColors.errorBg)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(SolennixColors.error)
                .frame(width: 4)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: CornerRadius.sm,
                        bottomLeadingRadius: CornerRadius.sm
                    )
                )
        }
        .onTapGesture {
            viewModel?.clearError()
        }
    }
}

#Preview {
    NavigationStack {
        TeamInviteAcceptView(token: "preview-token")
    }
    .environment(AuthManager())
}
