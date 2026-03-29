import SwiftUI
import SolennixDesign

// MARK: - Inline Filter Bar

/// A reusable local filter/search bar for list screens.
///
/// Visually distinct from the global `.searchable()` bar in the navigation
/// bar: this bar lives inside the view body and filters the current list
/// in-place without navigating away.
public struct InlineFilterBar: View {

    let placeholder: String
    @Binding var text: String

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(SolennixColors.textTertiary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.body)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(SolennixColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.sm)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.sm)
    }
}
