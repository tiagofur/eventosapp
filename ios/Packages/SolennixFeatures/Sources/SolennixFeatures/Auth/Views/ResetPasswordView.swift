import SwiftUI
import SolennixDesign
import SolennixNetwork

// MARK: - Reset Password View

public struct ResetPasswordView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: AuthViewModel?

    let token: String

    public init(token: String) {
        self.token = token
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
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.xxl)
        }
        .background(SolennixColors.background.ignoresSafeArea())
        .navigationTitle("Nueva Contrasena")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(authManager: authManager)
            }
        }
    }

    // MARK: - Form State

    private var formState: some View {
        VStack(spacing: Spacing.xl) {
            // Instruction
            VStack(spacing: Spacing.sm) {
                Image(systemName: "key.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(SolennixColors.primary)

                Text("Ingresa tu nueva contrasena. Debe tener al menos 6 caracteres.")
                    .font(.body)
                    .foregroundStyle(SolennixColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.lg)

            // Error banner
            if let error = viewModel?.errorMessage {
                errorBanner(message: error)
            }

            SolennixTextField(
                label: "Nueva contrasena",
                text: Binding(
                    get: { viewModel?.password ?? "" },
                    set: { viewModel?.password = $0 }
                ),
                placeholder: "Minimo 6 caracteres",
                leftIcon: "lock",
                isSecure: true,
                textContentType: .newPassword
            )

            SolennixTextField(
                label: "Confirmar contrasena",
                text: Binding(
                    get: { viewModel?.confirmPassword ?? "" },
                    set: { viewModel?.confirmPassword = $0 }
                ),
                placeholder: "Repite tu contrasena",
                leftIcon: "lock",
                isSecure: true,
                textContentType: .newPassword
            )

            PremiumButton(
                title: "Restablecer Contrasena",
                isLoading: viewModel?.isLoading ?? false,
                isDisabled: !(viewModel?.isResetValid ?? false)
            ) {
                Task { await viewModel?.resetPassword(token: token) }
            }
        }
    }

    // MARK: - Success State

    private var successState: some View {
        VStack(spacing: Spacing.xl) {
            Spacer(minLength: Spacing.xxxl)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(SolennixColors.success)

            VStack(spacing: Spacing.sm) {
                Text("Contrasena actualizada")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(SolennixColors.text)

                Text("Tu contrasena ha sido restablecida exitosamente. Ya puedes iniciar sesion con tu nueva contrasena.")
                    .font(.body)
                    .foregroundStyle(SolennixColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                dismiss()
            } label: {
                Text("Ir al login")
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

// MARK: - Preview

#Preview("Form State") {
    NavigationStack {
        ResetPasswordView(token: "preview-token-123")
    }
    .environment(AuthManager())
}
