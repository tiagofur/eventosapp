import SwiftUI
import SolennixDesign

// MARK: - Financial Comparison Chart

/// Horizontal bar chart comparing net sales, cash collected, and outstanding VAT.
public struct FinancialComparisonChart: View {

    let netSales: Double
    let cashCollected: Double
    let vatOutstanding: Double

    public init(netSales: Double, cashCollected: Double, vatOutstanding: Double) {
        self.netSales = netSales
        self.cashCollected = cashCollected
        self.vatOutstanding = vatOutstanding
    }

    private var maxValue: Double {
        max(netSales, cashCollected, vatOutstanding, 1)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                Text("Comparativa Financiera")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(SolennixColors.text)

                Spacer()

                Text("Este mes")
                    .font(.caption2)
                    .foregroundStyle(SolennixColors.primary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(SolennixColors.primaryLight)
                    .clipShape(Capsule())
            }

            // Bar rows
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    barRow(
                        label: "Ventas Netas",
                        value: netSales,
                        color: SolennixColors.kpiGreen,
                        maxWidth: geometry.size.width
                    )

                    barRow(
                        label: "Cobrado Real",
                        value: cashCollected,
                        color: SolennixColors.primary,
                        maxWidth: geometry.size.width
                    )

                    barRow(
                        label: "IVA por Cobrar",
                        value: vatOutstanding,
                        color: SolennixColors.error,
                        maxWidth: geometry.size.width
                    )
                }
            }
            .frame(height: 100)
        }
        .padding(Spacing.md)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))
        .shadowSm()
    }

    // MARK: - Bar Row

    private func barRow(label: String, value: Double, color: Color, maxWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(SolennixColors.textSecondary)

                Spacer()

                Text(value.asMXN)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(SolennixColors.text)
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(SolennixColors.surfaceAlt)
                    .frame(height: 10)

                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(color)
                    .frame(width: max(maxWidth * CGFloat(value / maxValue), 4), height: 10)
            }
        }
    }
}

// MARK: - Preview

#Preview("Financial Comparison Chart") {
    FinancialComparisonChart(
        netSales: 45_000,
        cashCollected: 32_000,
        vatOutstanding: 7_200
    )
    .padding()
    .background(SolennixColors.surfaceGrouped)
}
