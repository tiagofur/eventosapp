import SwiftUI

/// Event status pill badge with colored background and text.
public struct StatusBadge: View {
    let status: String

    public init(status: String) {
        self.status = status.lowercased()
    }

    public var body: some View {
        Text(displayLabel)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
    }

    private var displayLabel: String {
        switch status {
        case "quoted": return "Cotizado"
        case "confirmed": return "Confirmado"
        case "completed": return "Completado"
        case "cancelled": return "Cancelado"
        default: return status.capitalized
        }
    }

    private var foregroundColor: Color {
        switch status {
        case "quoted": return SolennixColors.statusQuoted
        case "confirmed": return SolennixColors.statusConfirmed
        case "completed": return SolennixColors.statusCompleted
        case "cancelled": return SolennixColors.statusCancelled
        default: return SolennixColors.textSecondary
        }
    }

    private var backgroundColor: Color {
        switch status {
        case "quoted": return SolennixColors.statusQuotedBg
        case "confirmed": return SolennixColors.statusConfirmedBg
        case "completed": return SolennixColors.statusCompletedBg
        case "cancelled": return SolennixColors.statusCancelledBg
        default: return SolennixColors.surfaceAlt
        }
    }
}

// MARK: - Preview

#Preview("Status Badges") {
    HStack(spacing: Spacing.sm) {
        StatusBadge(status: "quoted")
        StatusBadge(status: "confirmed")
        StatusBadge(status: "completed")
        StatusBadge(status: "cancelled")
    }
    .padding()
    .background(SolennixColors.background)
}
