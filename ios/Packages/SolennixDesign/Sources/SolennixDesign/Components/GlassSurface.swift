import SwiftUI

/// A reusable glass/frosted surface effect for chrome, overlays, and modal backgrounds.
/// Provides a semi-transparent, blurred appearance with controlled opacity.
public struct GlassSurface: ViewModifier {
    var opacity: Double = 0.8
    var blur: Double = 10

    public init(opacity: Double = 0.8, blur: Double = 10) {
        self.opacity = opacity
        self.blur = blur
    }
    
    public func body(content: Content) -> some View {
        content
            .background(
                Color.black.opacity(0.1)
                    .blur(radius: blur)
            )
            .background(
                Color.white.opacity(opacity)
            )
    }
}

public extension View {
    /// Apply a glass/frosted surface effect with customizable opacity and blur.
    ///
    /// Usage:
    /// ```swift
    /// VStack { ... }
    ///     .glassSurface(opacity: 0.85, blur: 12)
    /// ```
    func glassSurface(opacity: Double = 0.8, blur: Double = 10) -> some View {
        modifier(GlassSurface(opacity: opacity, blur: blur))
    }
}
