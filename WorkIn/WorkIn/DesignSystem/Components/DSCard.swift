import SwiftUI

/// Design System Card Component
/// A reusable card component with consistent styling across the app
struct DSCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    let content: Content
    var padding: CGFloat = DesignSystem.Spacing.md
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.lg
    var showShadow: Bool = true

    init(
        padding: CGFloat = DesignSystem.Spacing.md,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.lg,
        showShadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.showShadow = showShadow
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DesignSystem.Colors.card(for: colorScheme))
                    .shadow(
                        color: showShadow ? (colorScheme == .dark ? Color.clear : Color.black.opacity(0.05)) : Color.clear,
                        radius: showShadow ? 8 : 0,
                        x: 0,
                        y: showShadow ? 2 : 0
                    )
            )
    }
}

// MARK: - Card Variants

/// Info card with icon and title
struct DSInfoCard: View {
    @Environment(\.colorScheme) var colorScheme

    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    var accentColor: Color = DesignSystem.Colors.primary

    init(icon: String, title: String, value: String, subtitle: String? = nil, accentColor: Color = DesignSystem.Colors.primary) {
        self.icon = icon
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.accentColor = accentColor
    }

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(accentColor)

                    Spacer()
                }

                Text(title)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))

                Text(value)
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }
            }
        }
    }
}

/// Stat card for displaying metrics
struct DSStatCard: View {
    @Environment(\.colorScheme) var colorScheme

    let value: String
    let label: String
    let trend: TrendDirection?
    var accentColor: Color = DesignSystem.Colors.primary

    enum TrendDirection {
        case up, down, neutral

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }

        var color: Color {
            switch self {
            case .up: return DesignSystem.Colors.success
            case .down: return DesignSystem.Colors.error
            case .neutral: return .gray
            }
        }
    }

    var body: some View {
        DSCard {
            VStack(spacing: DesignSystem.Spacing.xs) {
                HStack(alignment: .top) {
                    Text(value)
                        .font(DesignSystem.Typography.numberDisplay)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    if let trend = trend {
                        Image(systemName: trend.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(trend.color)
                    }
                }

                Text(label)
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        DSCard {
            Text("Basic Card")
                .font(DesignSystem.Typography.body)
        }

        DSInfoCard(
            icon: "flame.fill",
            title: "Calories Burned",
            value: "1,250",
            subtitle: "Today"
        )

        DSStatCard(
            value: "15",
            label: "Workouts This Week",
            trend: .up
        )
    }
    .padding()
}
