import SwiftUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

// MARK: - Step 5: Finances

struct Step5FinancesView: View {

    @Bindable var viewModel: EventFormViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Discount section
                discountSection

                // IVA section
                taxSection

                // Deposit section
                depositSection

                // Cancellation section
                cancellationSection

                // Notes
                notesSection

                // Totals card
                totalsCard
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Discount Section

    private var discountSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Descuento")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(SolennixColors.text)

            HStack(spacing: Spacing.sm) {
                // Discount type toggle
                HStack(spacing: 0) {
                    Button {
                        viewModel.discountType = .percent
                    } label: {
                        Text("%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(viewModel.discountType == .percent ? .white : SolennixColors.textSecondary)
                            .frame(width: 44, height: 36)
                            .background(viewModel.discountType == .percent ? SolennixColors.primary : SolennixColors.surfaceAlt)
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.discountType = .fixed
                    } label: {
                        Text("$")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(viewModel.discountType == .fixed ? .white : SolennixColors.textSecondary)
                            .frame(width: 44, height: 36)
                            .background(viewModel.discountType == .fixed ? SolennixColors.primary : SolennixColors.surfaceAlt)
                    }
                    .buttonStyle(.plain)
                }
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))

                // Discount value
                HStack(spacing: Spacing.xs) {
                    TextField("0", value: $viewModel.discount, format: .number.precision(.fractionLength(2)))
                        .keyboardType(.decimalPad)
                        .font(.body)
                        .foregroundStyle(SolennixColors.text)
                        .multilineTextAlignment(.trailing)

                    Text(viewModel.discountType == .percent ? "%" : "$")
                        .font(.body)
                        .foregroundStyle(SolennixColors.textTertiary)
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
        }
    }

    // MARK: - Tax Section

    private var taxSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Toggle(isOn: $viewModel.requiresInvoice) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "doc.text")
                        .foregroundStyle(SolennixColors.textSecondary)

                    Text("Requiere Factura (IVA)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(SolennixColors.text)
                }
            }
            .tint(SolennixColors.primary)

            if viewModel.requiresInvoice {
                HStack(spacing: Spacing.sm) {
                    Text("Tasa IVA:")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textSecondary)

                    HStack(spacing: Spacing.xs) {
                        TextField("16", value: $viewModel.taxRate, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                            .font(.body)
                            .foregroundStyle(SolennixColors.text)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 50)

                        Text("%")
                            .font(.body)
                            .foregroundStyle(SolennixColors.textTertiary)
                    }
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 6)
                    .background(SolennixColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(SolennixColors.border, lineWidth: 1)
                    )

                    Spacer()
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

    // MARK: - Deposit Section

    private var depositSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Anticipo")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(SolennixColors.text)

            HStack(spacing: Spacing.sm) {
                HStack(spacing: Spacing.xs) {
                    TextField("50", value: $viewModel.depositPercent, format: .number.precision(.fractionLength(0)))
                        .keyboardType(.decimalPad)
                        .font(.body)
                        .foregroundStyle(SolennixColors.text)
                        .multilineTextAlignment(.trailing)

                    Text("%")
                        .font(.body)
                        .foregroundStyle(SolennixColors.textTertiary)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 10)
                .background(SolennixColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(SolennixColors.border, lineWidth: 1)
                )

                Spacer()

                Text(formatCurrency(viewModel.depositAmount))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(SolennixColors.primary)
            }
        }
    }

    // MARK: - Cancellation Section

    private var cancellationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Politica de Cancelacion")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(SolennixColors.text)

            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Dias anticipacion")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textSecondary)

                    HStack(spacing: Spacing.xs) {
                        TextField("3", value: $viewModel.cancellationDays, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .font(.body)
                            .foregroundStyle(SolennixColors.text)
                            .multilineTextAlignment(.trailing)

                        Text("dias")
                            .font(.caption)
                            .foregroundStyle(SolennixColors.textTertiary)
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

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Reembolso")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textSecondary)

                    HStack(spacing: Spacing.xs) {
                        TextField("50", value: $viewModel.refundPercent, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                            .font(.body)
                            .foregroundStyle(SolennixColors.text)
                            .multilineTextAlignment(.trailing)

                        Text("%")
                            .font(.body)
                            .foregroundStyle(SolennixColors.textTertiary)
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
            }
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Notas")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(SolennixColors.text)

            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 80)
                .font(.body)
                .foregroundStyle(SolennixColors.text)
                .scrollContentBackground(.hidden)
                .padding(Spacing.sm)
                .background(SolennixColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(SolennixColors.border, lineWidth: 1)
                )
        }
    }

    // MARK: - Totals Card

    private var totalsCard: some View {
        VStack(spacing: Spacing.sm) {
            Text("Resumen")
                .font(.headline)
                .foregroundStyle(SolennixColors.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .foregroundStyle(SolennixColors.border)

            // Subtotal
            totalRow(label: "Subtotal", value: viewModel.subtotal)

            // Discount
            if viewModel.discountAmount > 0 {
                totalRow(label: "Descuento", value: -viewModel.discountAmount, color: SolennixColors.error)
            }

            // Tax
            if viewModel.requiresInvoice {
                totalRow(label: "IVA (\(String(format: "%.0f", viewModel.taxRate))%)", value: viewModel.taxAmount)
            }

            Divider()
                .foregroundStyle(SolennixColors.border)

            // Total
            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundStyle(SolennixColors.text)

                Spacer()

                Text(formatCurrency(viewModel.total))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(SolennixColors.primary)
            }

            // Deposit
            HStack {
                Text("Anticipo (\(String(format: "%.0f", viewModel.depositPercent))%)")
                    .font(.subheadline)
                    .foregroundStyle(SolennixColors.textSecondary)

                Spacer()

                Text(formatCurrency(viewModel.depositAmount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(SolennixColors.primary)
            }
        }
        .padding(Spacing.lg)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(SolennixColors.primary.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Total Row

    private func totalRow(label: String, value: Double, color: Color = SolennixColors.text) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(SolennixColors.textSecondary)

            Spacer()

            Text(formatCurrency(value))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        let prefix = value < 0 ? "-$" : "$"
        return "\(prefix)\(String(format: "%.2f", abs(value)))"
    }
}

// MARK: - Preview

#Preview("Step 5 - Finances") {
    Step5FinancesView(viewModel: EventFormViewModel(apiClient: APIClient()))
}
