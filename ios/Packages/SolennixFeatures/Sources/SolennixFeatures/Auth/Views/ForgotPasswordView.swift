import SwiftUI
import SolennixDesign
import SolennixNetwork

// MARK: - Forgot Password View

public struct ForgotPasswordView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: AuthViewModel?

    public init() {}

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
        .navigationTitle("Recuperar Contrasena")
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
                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(SolennixColors.primary)

                Text("Ingresa tu correo electronico y te enviaremos un enlace para restablecer tu contrasena.")
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
                label: "Correo electronico",
                text: Binding(
                    get: { viewModel?.email ?? "" },
                    set: { viewModel?.email = $0 }
                ),
                placeholder: "tu@email.com",
                leftIcon: "envelope",
                textContentType: .emailAddress,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            PremiumButton(
                title: "Enviar Enlace",
                isLoading: viewModel?.isLoading ?? false,
                isDisabled: !(viewModel?.isForgotValid ?? false)
            ) {
                Task { await viewModel?.forgotPassword() }
            }

            Button {
                dismiss()
            } label: {
                Text("Volver al login")
                    .font(.body)
                    .foregroundStyle(SolennixColors.primary)
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
                Text("Revisa tu email")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(SolennixColors.text)

                Text("Si existe una cuenta con ese correo, recibiras un enlace para restablecer tu contrasena.")
                    .font(.body)
                    .foregroundStyle(SolennixColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                dismiss()
            } label: {
                Text("Volver al login")
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
        ForgotPasswordView()
    }
    .environment(AuthManager())
}
