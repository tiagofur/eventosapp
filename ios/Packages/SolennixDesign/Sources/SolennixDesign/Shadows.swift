import SwiftUI

// MARK: - Shadow View Modifiers

public extension View {

    /// Small shadow: radius 3, y-offset 1, 4% opacity black.
    func shadowSm() -> some View {
        self.shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }

    /// Medium shadow: radius 8, y-offset 2, 8% opacity black.
    func shadowMd() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    /// Large shadow: radius 16, y-offset 4, 12% opacity black.
    func shadowLg() -> some View {
        self.shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 4)
    }

    /// FAB shadow: radius 12, y-offset 4, 15% opacity gold tint.
    func shadowFab() -> some View {
        self.shadow(color: SolennixColors.primary.opacity(0.15), radius: 12, x: 0, y: 4)
    }
}
