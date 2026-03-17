import SwiftUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

// MARK: - Pricing View

public struct PricingView: View {

    @State private var viewModel: SettingsViewModel
    @State private var selectedPlan: Plan = .basic

    public init(apiClient: APIClient) {
        _viewModel = State(initialValue: SettingsViewModel(apiClient: apiClient))
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                headerSection

                // Plan cards
                planCardsSection

                // Feature comparison
                featureComparisonSection

                // FAQ section
                faqSection
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Planes y Precios")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadUser()
            if let user = viewModel.user {
                selectedPlan = user.plan
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            if let user = viewModel.user {
                HStack {
                    Text("Tu plan actual:")
                    PlanBadge(plan: user.plan)
                }
                .font(.subheadline)
            }

            Text("Elige el plan que mejor se adapte a tu negocio")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Plan Cards Section

    private var planCardsSection: some View {
        VStack(spacing: Spacing.md) {
            // Basic plan
            planCard(
                plan: .basic,
                title: "Basico",
                price: "Gratis",
                features: [
                    "Hasta 20 productos",
                    "Hasta 50 clientes",
                    "Generacion de contratos",
                    "Calendario de eventos"
                ],
                isCurrentPlan: viewModel.user?.plan == .basic
            )

            // Premium plan
            planCard(
                plan: .premium,
                title: "Premium",
                price: "$199 MXN/mes",
                features: [
                    "Productos ilimitados",
                    "Clientes ilimitados",
                    "Widgets de iOS",
                    "Comandos de Siri",
                    "Soporte prioritario",
                    "Sin marca de agua en PDFs"
                ],
                isCurrentPlan: viewModel.user?.plan == .premium,
                isRecommended: true
            )
        }
    }

    // MARK: - Plan Card

    private func planCard(
        plan: Plan,
        title: String,
        price: String,
        features: [String],
        isCurrentPlan: Bool,
        isRecommended: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)

                        if isRecommended {
                            Text("Recomendado")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, 2)
                                .background(SolennixGradient.premium)
                                .clipShape(Capsule())
                        }
                    }

                    Text(price)
                        .font(.headline)
                        .foregroundStyle(SolennixColors.primary)
                }

                Spacer()

                if isCurrentPlan {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(SolennixColors.success)
                }
            }

            Divider()

            // Features
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundStyle(SolennixColors.success)

                        Text(feature)
                            .font(.subheadline)
                            .foregroundStyle(SolennixColors.textSecondary)
                    }
                }
            }

            // Action button
            if !isCurrentPlan && plan == .premium {
                Button {
                    // TODO: Implement Stripe subscription
                } label: {
                    Text("Actualizar a Premium")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(SolennixGradient.premium)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.md)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(
                    isCurrentPlan ? SolennixColors.primary : Color.clear,
                    lineWidth: 2
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Feature Comparison Section

    private var featureComparisonSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Comparacion de funciones")
                .font(.headline)

            VStack(spacing: 0) {
                comparisonRow(feature: "Productos", basic: "20", premium: "Ilimitados")
                comparisonRow(feature: "Clientes", basic: "50", premium: "Ilimitados")
                comparisonRow(feature: "Generacion de PDFs", basic: true, premium: true)
                comparisonRow(feature: "Widgets", basic: false, premium: true)
                comparisonRow(feature: "Comandos de Siri", basic: false, premium: true)
                comparisonRow(feature: "Soporte prioritario", basic: false, premium: true)
            }
            .background(SolennixColors.card)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        }
    }

    private func comparisonRow(feature: String, basic: String, premium: String) -> some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(basic)
                .font(.subheadline)
                .foregroundStyle(SolennixColors.textSecondary)
                .frame(width: 80)

            Text(premium)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(SolennixColors.primary)
                .frame(width: 80)
        }
        .padding(Spacing.md)
    }

    private func comparisonRow(feature: String, basic: Bool, premium: Bool) -> some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: basic ? "checkmark" : "xmark")
                .font(.subheadline)
                .foregroundStyle(basic ? SolennixColors.success : SolennixColors.textTertiary)
                .frame(width: 80)

            Image(systemName: premium ? "checkmark" : "xmark")
                .font(.subheadline)
                .foregroundStyle(premium ? SolennixColors.success : SolennixColors.textTertiary)
                .frame(width: 80)
        }
        .padding(Spacing.md)
    }

    // MARK: - FAQ Section

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Preguntas frecuentes")
                .font(.headline)

            faqItem(
                question: "Puedo cancelar en cualquier momento?",
                answer: "Si, puedes cancelar tu suscripcion en cualquier momento. Tu plan premium seguira activo hasta el final del periodo de facturacion."
            )

            faqItem(
                question: "Que pasa con mis datos si bajo de plan?",
                answer: "Tus datos se mantienen, pero no podras crear mas productos o clientes si excedes los limites del plan basico."
            )

            faqItem(
                question: "Hay periodo de prueba?",
                answer: "Puedes probar todas las funciones premium durante 14 dias gratis."
            )
        }
    }

    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(question)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(answer)
                .font(.caption)
                .foregroundStyle(SolennixColors.textSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }
}

// MARK: - Preview

#Preview("Pricing") {
    NavigationStack {
        PricingView(apiClient: APIClient())
    }
}
