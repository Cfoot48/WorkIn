import SwiftUI

// MARK: - Design System
/// Central design system for the WorkIn app
/// Contains colors, typography, spacing, and other design tokens

struct DesignSystem {

    // MARK: - Colors
    struct Colors {
        // Primary brand color - orange/coral from logo
        static let primary = Color(red: 1.0, green: 0.42, blue: 0.24) // #FF6B3D
        static let primaryLight = Color(red: 1.0, green: 0.50, blue: 0.35)
        static let primaryDark = Color(red: 0.90, green: 0.35, blue: 0.15)

        // Background colors
        static let backgroundLight = Color.white
        static let backgroundDark = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E

        // Card colors
        static let cardLight = Color.white
        static let cardDark = Color(red: 0.17, green: 0.17, blue: 0.18) // #2C2C2E

        // Text colors
        static let textPrimaryLight = Color.black
        static let textPrimaryDark = Color.white
        static let textSecondaryLight = Color.gray
        static let textSecondaryDark = Color(red: 0.56, green: 0.56, blue: 0.58) // #8E8E93

        // System colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue

        // Progress/tracking colors
        static let progressGreen = Color(red: 0.52, green: 0.87, blue: 0.39) // #85DE63
        static let progressBlue = Color(red: 0.25, green: 0.64, blue: 1.0) // #40A3FF

        // Adaptive colors
        static func background(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? backgroundDark : backgroundLight
        }

        static func card(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? cardDark : cardLight
        }

        static func textPrimary(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? textPrimaryDark : textPrimaryLight
        }

        static func textSecondary(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? textSecondaryDark : textSecondaryLight
        }
    }

    // MARK: - Typography
    struct Typography {
        // Headings
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)

        // Body text
        static let body = Font.system(size: 17, weight: .regular)
        static let bodyBold = Font.system(size: 17, weight: .semibold)
        static let callout = Font.system(size: 16, weight: .regular)

        // Small text
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption1 = Font.system(size: 12, weight: .regular)
        static let caption2 = Font.system(size: 11, weight: .regular)

        // Special
        static let timerLarge = Font.system(size: 48, weight: .bold, design: .rounded)
        static let numberDisplay = Font.system(size: 40, weight: .bold, design: .rounded)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let circle: CGFloat = 999
    }

    // MARK: - Shadows
    struct Shadows {
        static let light = Shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 4)
        static let heavy = Shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
    }

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
}

// MARK: - Environment Key for Color Scheme Aware Colors
struct ThemeColorKey: EnvironmentKey {
    static let defaultValue: ColorScheme = .light
}

extension EnvironmentValues {
    var themeColorScheme: ColorScheme {
        get { self[ThemeColorKey.self] }
        set { self[ThemeColorKey.self] = newValue }
    }
}
