import SwiftUI

/// Design System Progress Ring Component
/// Circular progress indicator like in the screenshots (Steps, Water, etc.)
struct DSProgressRing: View {
    @Environment(\.colorScheme) var colorScheme

    let progress: Double // 0.0 to 1.0
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat

    init(
        progress: Double,
        color: Color = DesignSystem.Colors.primary,
        lineWidth: CGFloat = 12,
        size: CGFloat = 120
    ) {
        self.progress = min(max(progress, 0), 1) // Clamp between 0 and 1
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(DesignSystem.Animation.spring, value: progress)
        }
        .frame(width: size, height: size)
    }
}

/// Progress Ring with content inside
struct DSProgressRingWithContent<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    let content: Content

    init(
        progress: Double,
        color: Color = DesignSystem.Colors.primary,
        lineWidth: CGFloat = 12,
        size: CGFloat = 120,
        @ViewBuilder content: () -> Content
    ) {
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
        self.content = content()
    }

    var body: some View {
        ZStack {
            DSProgressRing(
                progress: progress,
                color: color,
                lineWidth: lineWidth,
                size: size
            )

            content
        }
    }
}

/// Progress card like in the screenshots (Steps/Water)
struct DSProgressCard: View {
    @Environment(\.colorScheme) var colorScheme

    let icon: String
    let title: String
    let current: String
    let goal: String
    let progress: Double
    let color: Color
    let showDetail: Bool
    let detailAction: (() -> Void)?

    init(
        icon: String,
        title: String,
        current: String,
        goal: String,
        progress: Double,
        color: Color = DesignSystem.Colors.primary,
        showDetail: Bool = false,
        detailAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.current = current
        self.goal = goal
        self.progress = progress
        self.color = color
        self.showDetail = showDetail
        self.detailAction = detailAction
    }

    var body: some View {
        DSCard {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Title
                HStack {
                    Text(title)
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }

                // Progress Ring
                DSProgressRingWithContent(
                    progress: progress,
                    color: color,
                    lineWidth: 10,
                    size: 100
                ) {
                    VStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(color)

                        Text(current)
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                        Text("/ \(goal)")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                    }
                }

                // Detail button
                if showDetail {
                    Button(action: { detailAction?() }) {
                        Text("DETAIL")
                            .font(DesignSystem.Typography.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                                    .fill(DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.1))
                            )
                    }
                }
            }
        }
    }
}

/// Week tracker with stars (like in screenshot)
struct DSWeekTracker: View {
    @Environment(\.colorScheme) var colorScheme

    let completedDays: [Bool] // Array of 7 booleans for each day
    let accentColor: Color

    init(completedDays: [Bool], accentColor: Color = DesignSystem.Colors.primary) {
        // Ensure we have exactly 7 days
        if completedDays.count < 7 {
            self.completedDays = completedDays + Array(repeating: false, count: 7 - completedDays.count)
        } else {
            self.completedDays = Array(completedDays.prefix(7))
        }
        self.accentColor = accentColor
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(0..<7) { index in
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(completedDays[index] ? accentColor : DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.2))
                            .frame(width: 40, height: 40)

                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(completedDays[index] ? .white : DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.5))
                    }

                    Text("\(index + 1)")
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // Basic progress ring
            DSProgressRing(progress: 0.75, color: DesignSystem.Colors.progressGreen)

            // Progress ring with content
            DSProgressRingWithContent(progress: 0.6, color: DesignSystem.Colors.progressBlue) {
                VStack {
                    Text("3,020")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                    Text("steps")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(.gray)
                }
            }

            // Progress card
            HStack(spacing: 12) {
                DSProgressCard(
                    icon: "figure.walk",
                    title: "Steps",
                    current: "3,020",
                    goal: "4,000",
                    progress: 0.755,
                    color: DesignSystem.Colors.progressGreen,
                    showDetail: true
                )

                DSProgressCard(
                    icon: "drop.fill",
                    title: "Water",
                    current: "6",
                    goal: "8 cups",
                    progress: 0.75,
                    color: DesignSystem.Colors.progressBlue,
                    showDetail: false
                )
            }

            // Week tracker
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Week 1")
                        .font(DesignSystem.Typography.title3)
                    Spacer()
                    Text("6/7")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primary)
                }

                DSWeekTracker(
                    completedDays: [true, true, true, true, true, true, false],
                    accentColor: DesignSystem.Colors.primary
                )
            }
            .padding()
        }
        .padding()
    }
}
