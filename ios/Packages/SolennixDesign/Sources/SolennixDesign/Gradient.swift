import SwiftUI

// MARK: - Solennix Gradients

public enum SolennixGradient {

    /// Premium gold gradient: #C4A265 -> #B8965A, leading to trailing.
    public static var premium: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#C4A265"), Color(hex: "#B8965A")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Reversed premium gold gradient: #B8965A -> #C4A265, leading to trailing.
    public static var premiumReversed: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#B8965A"), Color(hex: "#C4A265")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
