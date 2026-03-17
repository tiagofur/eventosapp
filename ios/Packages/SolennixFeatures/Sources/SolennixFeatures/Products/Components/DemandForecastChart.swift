import SwiftUI
import Charts
import SolennixCore
import SolennixDesign

// MARK: - Demand Data Point

public struct DemandDataPoint: Identifiable {
    public let id: String
    public let eventDate: Date
    public let clientName: String
    public let quantity: Int
    public let numPeople: Int

    public init(id: String, eventDate: Date, clientName: String, quantity: Int, numPeople: Int) {
        self.id = id
        self.eventDate = eventDate
        self.clientName = clientName
        self.quantity = quantity
        self.numPeople = numPeople
    }
}

// MARK: - Demand Forecast Chart

/// Displays upcoming events that use this product with a bar chart
public struct DemandForecastChart: View {

    let dataPoints: [DemandDataPoint]
    let productName: String

    public init(dataPoints: [DemandDataPoint], productName: String) {
        self.dataPoints = dataPoints
        self.productName = productName
    }

    private var hasData: Bool {
        !dataPoints.isEmpty
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(SolennixColors.primary)

                Text("Demanda Proyectada")
                    .font(.headline)
                    .foregroundStyle(SolennixColors.text)
            }

            if hasData {
                // Chart
                Chart(dataPoints) { point in
                    BarMark(
                        x: .value("Fecha", point.eventDate, unit: .day),
                        y: .value("Cantidad", point.quantity)
                    )
                    .foregroundStyle(SolennixGradient.premium)
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)

                // Summary
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Proximos \(dataPoints.count) eventos")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(SolennixColors.text)

                    Text("Total: \(totalQuantity) unidades para \(totalPeople) personas")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textSecondary)
                }

                // Event list
                Divider()

                ForEach(dataPoints.prefix(5)) { point in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(point.clientName)
                                .font(.subheadline)
                                .foregroundStyle(SolennixColors.text)

                            Text(point.eventDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(SolennixColors.textTertiary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(point.quantity) uds")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(SolennixColors.primary)

                            Text("\(point.numPeople) personas")
                                .font(.caption)
                                .foregroundStyle(SolennixColors.textTertiary)
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                }
            } else {
                // Empty state
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 32))
                        .foregroundStyle(SolennixColors.textTertiary)

                    Text("Sin eventos proximos")
                        .font(.subheadline)
                        .foregroundStyle(SolennixColors.textSecondary)

                    Text("Este producto no esta incluido en ningun evento proximo")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
            }
        }
        .padding(Spacing.md)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var totalQuantity: Int {
        dataPoints.reduce(0) { $0 + $1.quantity }
    }

    private var totalPeople: Int {
        dataPoints.reduce(0) { $0 + $1.numPeople }
    }
}

// MARK: - Preview

#Preview("Demand Forecast Chart") {
    DemandForecastChart(
        dataPoints: [
            DemandDataPoint(id: "1", eventDate: Date().addingTimeInterval(86400 * 2), clientName: "Maria Garcia", quantity: 50, numPeople: 100),
            DemandDataPoint(id: "2", eventDate: Date().addingTimeInterval(86400 * 5), clientName: "Juan Lopez", quantity: 30, numPeople: 60),
            DemandDataPoint(id: "3", eventDate: Date().addingTimeInterval(86400 * 8), clientName: "Ana Martinez", quantity: 80, numPeople: 150)
        ],
        productName: "Paquete Premium"
    )
    .padding()
}

#Preview("Empty Demand Chart") {
    DemandForecastChart(
        dataPoints: [],
        productName: "Producto Sin Demanda"
    )
    .padding()
}
