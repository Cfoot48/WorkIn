import SwiftUI

/// Design System Button Component
/// Consistent button styling across the app
struct DSButton: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void

    @State private var isPressed = false

    enum ButtonStyle {
        case primary
        case secondary
        case outline
        case ghost
        case danger

        func backgroundColor(for colorScheme: ColorScheme) -> Color {
            switch self {
            case .primary:
                return DesignSystem.Colors.primary
            case .secondary:
                return DesignSystem.Colors.card(for: colorScheme)
            case .outline, .ghost:
                return Color.clear
            case .danger:
                return DesignSystem.Colors.error
            }
        }

        func foregroundColor(for colorScheme: ColorScheme) -> Color {
            switch self {
            case .primary, .danger:
                return .white
            case .secondary, .outline, .ghost:
                return DesignSystem.Colors.textPrimary(for: colorScheme)
            }
        }

        func borderColor(for colorScheme: ColorScheme) -> Color {
            switch self {
            case .outline:
                return DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.3)
            case .primary, .secondary, .ghost, .danger:
                return Color.clear
            }
        }
    }

    enum ButtonSize {
        case small
        case medium
        case large

        var height: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 48
            case .large: return 56
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return DesignSystem.Spacing.sm
            case .medium: return DesignSystem.Spacing.lg
            case .large: return DesignSystem.Spacing.xl
            }
        }

        var font: Font {
            switch self {
            case .small: return DesignSystem.Typography.footnote
            case .medium: return DesignSystem.Typography.callout
            case .large: return DesignSystem.Typography.body
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 20
            }
        }
    }

    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .semibold))
                }

                Text(title)
                    .font(size.font)
                    .fontWeight(.semibold)
            }
            .foregroundColor(style.foregroundColor(for: colorScheme))
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(style.backgroundColor(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(style.borderColor(for: colorScheme), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(DesignSystem.Animation.quick, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

/// Icon-only button
struct DSIconButton: View {
    @Environment(\.colorScheme) var colorScheme

    let icon: String
    let style: DSButton.ButtonStyle
    let size: IconButtonSize
    let action: () -> Void

    @State private var isPressed = false

    enum IconButtonSize {
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 44
            case .large: return 56
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
    }

    init(
        icon: String,
        style: DSButton.ButtonStyle = .primary,
        size: IconButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundColor(style.foregroundColor(for: colorScheme))
                .frame(width: size.dimension, height: size.dimension)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(style.backgroundColor(for: colorScheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .stroke(style.borderColor(for: colorScheme), lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .animation(DesignSystem.Animation.quick, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        DSButton("Primary Button", icon: "plus", style: .primary) {}
        DSButton("Secondary Button", style: .secondary) {}
        DSButton("Outline Button", style: .outline) {}
        DSButton("Ghost Button", style: .ghost) {}
        DSButton("Danger Button", style: .danger) {}

        HStack(spacing: 12) {
            DSButton("Small", style: .primary, size: .small) {}
            DSButton("Medium", style: .primary, size: .medium) {}
            DSButton("Large", style: .primary, size: .large) {}
        }

        HStack(spacing: 12) {
            DSIconButton(icon: "heart.fill", style: .primary) {}
            DSIconButton(icon: "star.fill", style: .secondary) {}
            DSIconButton(icon: "plus", style: .outline) {}
        }
    }
    .padding()
}
