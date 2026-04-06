import SwiftUI

/// Small inline banner indicating data is from cache, not fresh from API.
public struct CachedDataBanner: View {

    public init() {}

    public var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption2)
            Text("Mostrando datos guardados")
                .font(.caption2)
        }
        .foregroundStyle(SolennixColors.warning)
        .padding(.vertical, Spacing.xs)
        .frame(maxWidth: .infinity)
        .background(SolennixColors.warningBg)
    }
}
