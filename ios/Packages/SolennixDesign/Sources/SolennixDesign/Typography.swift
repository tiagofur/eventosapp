import SwiftUI

public extension Font {

    /// 28pt Black weight with tight tracking, for premium headings.
    static let h1Premium: Font = .system(size: 28, weight: .black)

    /// Custom Cinzel SemiBold 32pt, for the Solennix brand title.
    static let solennixTitle: Font = .custom("Cinzel-SemiBold", size: 32, relativeTo: .title)

    /// Custom Cinzel Regular 24pt, for brand subtitles.
    static let solennixSubtitle: Font = .custom("Cinzel-Regular", size: 24, relativeTo: .title2)
}

// MARK: - Tracking Modifier

public extension View {
    /// Applies letter-spacing (tracking) to text views.
    func tracking(_ value: CGFloat) -> some View {
        self.modifier(TrackingModifier(tracking: value))
    }
}

private struct TrackingModifier: ViewModifier {
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content.kerning(tracking)
    }
}
