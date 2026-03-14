import SwiftUI

// MARK: - Design System

enum DS {

    // MARK: Colors
    enum Colors {
        static let background       = Color(hex: "#0A0A0C")
        static let surface          = Color(hex: "#111116")
        static let surfaceElevated  = Color(hex: "#18181F")
        static let border           = Color(hex: "#2A2A35")
        static let borderSubtle     = Color(hex: "#1E1E28")

        static let gold             = Color(hex: "#C9A84C")
        static let goldLight        = Color(hex: "#E8C96A")
        static let goldDark         = Color(hex: "#8A6830")

        static let textPrimary      = Color(hex: "#F0EDE8")
        static let textSecondary    = Color(hex: "#8A8790")
        static let textTertiary     = Color(hex: "#555260")

        static let accent           = Color(hex: "#C9A84C")
        static let danger           = Color(hex: "#D05060")
        static let success          = Color(hex: "#50A870")

        static let pieceLight       = Color(hex: "#F0D9B5")
        static let pieceDark        = Color(hex: "#B58863")

        static let gradientTop      = Color(hex: "#0A0A0C")
        static let gradientBottom   = Color(hex: "#12121A")
    }

    // MARK: Typography
    enum Typography {
        // Use SF Pro Display for headers, SF Pro Text for body
        static func displayLarge(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 42, weight: .bold, design: .serif))
                .foregroundColor(DS.Colors.textPrimary)
        }

        static func displayMedium(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(DS.Colors.textPrimary)
        }

        static func titleLarge(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(DS.Colors.textPrimary)
        }

        static func titleMedium(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundColor(DS.Colors.textPrimary)
        }

        static func body(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(DS.Colors.textSecondary)
        }

        static func caption(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(DS.Colors.textTertiary)
        }
    }

    // MARK: Spacing
    enum Spacing {
        static let xs:   CGFloat = 4
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 16
        static let lg:   CGFloat = 24
        static let xl:   CGFloat = 32
        static let xxl:  CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: Radius
    enum Radius {
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let lg:   CGFloat = 16
        static let xl:   CGFloat = 24
        static let full: CGFloat = 100
    }

    // MARK: Shadows
    enum Shadow {
        static let gold = SwiftUI.Color(hex: "#C9A84C").opacity(0.25)
        static let dark = SwiftUI.Color.black.opacity(0.5)
    }
}

// MARK: - View Modifiers

struct GoldBorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .strokeBorder(
                        LinearGradient(
                            colors: [DS.Colors.goldLight.opacity(0.6), DS.Colors.goldDark.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

struct SurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat = DS.Radius.lg
    func body(content: Content) -> some View {
        content
            .background(DS.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .modifier(GoldBorderModifier())
    }
}

extension View {
    func goldBorder() -> some View { modifier(GoldBorderModifier()) }
    func surfaceStyle(cornerRadius: CGFloat = DS.Radius.lg) -> some View { modifier(SurfaceModifier(cornerRadius: cornerRadius)) }
}
