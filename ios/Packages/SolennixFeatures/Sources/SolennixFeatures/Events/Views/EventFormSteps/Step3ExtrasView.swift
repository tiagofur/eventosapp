import SwiftUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

// MARK: - Step 3: Extras

struct Step3ExtrasView: View {

    @Bindable var viewModel: EventFormViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Add extra button
                Button {
                    viewModel.addExtra()
                } label: {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(SolennixColors.primary)

                        Text("Agregar Extra")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(SolennixColors.primary)

                        Spacer()
                    }
                    .padding(Spacing.md)
                    .background(SolennixColors.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .stroke(SolennixColors.primary.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // Extras list
                if viewModel.extras.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "star")
                            .font(.largeTitle)
                            .foregroundStyle(SolennixColors.textTertiary)

                        Text("Sin extras")
                            .font(.subheadline)
                            .foregroundStyle(SolennixColors.textSecondary)

                        Text("Agrega servicios o items adicionales")
                            .font(.caption)
                            .foregroundStyle(SolennixColors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.xxxl)
                } else {
                    ForEach(Array(viewModel.extras.enumerated()), id: \.element.id) { index, _ in
                        extraRow(index: index)
                    }
                }

                // Subtotal
                if !viewModel.extras.isEmpty {
                    HStack {
                        Text("Subtotal Extras")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(SolennixColors.textSecondary)

                        Spacer()

                        Text(formatCurrency(viewModel.extrasSubtotal))
                            .font(.headline)
                            .foregroundStyle(SolennixColors.primary)
                    }
                    .padding(Spacing.md)
                    .background(SolennixColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Extra Row

    private func extraRow(index: Int) -> some View {
        VStack(spacing: Spacing.sm) {
            // Header with delete
            HStack {
                Text("Extra \(index + 1)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(SolennixColors.textSecondary)

                Spacer()

                Button {
                    viewModel.removeExtra(at: index)
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundStyle(SolennixColors.error)
                }
                .buttonStyle(.plain)
            }

            // Description
            SolennixTextField(
                label: "Descripcion",
                text: $viewModel.extras[index].description,
                placeholder: "Descripcion del extra",
                leftIcon: "text.alignleft"
            )

            // Cost and Price
            HStack(spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Costo")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textSecondary)

                    currencyField(value: $viewModel.extras[index].cost)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Precio")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textSecondary)

                    currencyField(value: $viewModel.extras[index].price)
                        .disabled(viewModel.extras[index].excludeUtility)
                        .opacity(viewModel.extras[index].excludeUtility ? 0.5 : 1.0)
                }
            }

            // Exclude utility toggle
            Toggle(isOn: $viewModel.extras[index].excludeUtility) {
                Text("Solo cobrar costo (sin utilidad)")
                    .font(.caption)
                    .foregroundStyle(SolennixColors.textSecondary)
            }
            .tint(SolennixColors.primary)
            .onChange(of: viewModel.extras[index].excludeUtility) { _, newValue in
                if newValue {
                    viewModel.extras[index].price = viewModel.extras[index].cost
                }
            }
        }
        .padding(Spacing.md)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(SolennixColors.border, lineWidth: 1)
        )
    }

    // MARK: - Currency Field

    private func currencyField(value: Binding<Double>) -> some View {
        HStack(spacing: Spacing.xs) {
            Text("$")
                .font(.body)
                .foregroundStyle(SolennixColors.textTertiary)

            TextField("0.00", value: value, format: .number.precision(.fractionLength(2)))
                .keyboardType(.decimalPad)
                .font(.body)
                .foregroundStyle(SolennixColors.text)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
        .background(SolennixColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(SolennixColors.border, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        "$\(String(format: "%.2f", value))"
    }
}

// MARK: - Preview

#Preview("Step 3 - Extras") {
    Step3ExtrasView(viewModel: EventFormViewModel(apiClient: APIClient()))
}
