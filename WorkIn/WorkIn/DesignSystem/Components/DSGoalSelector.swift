import SwiftUI

/// Goal selection component (like in the onboarding screenshot)
struct DSGoalSelector: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedGoal: GoalType

    enum GoalType: String, CaseIterable {
        case loseWeight = "Lose Weight"
        case buildMuscle = "Build Muscle"
        case keepFit = "Keep Fit"

        var systemImage: String {
            switch self {
            case .loseWeight: return "figure.run"
            case .buildMuscle: return "figure.strengthtraining.traditional"
            case .keepFit: return "figure.flexibility"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Your Goal")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(GoalType.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: selectedGoal == goal,
                        action: { selectedGoal = goal }
                    )
                }
            }
        }
    }
}

/// Individual goal card
private struct GoalCard: View {
    @Environment(\.colorScheme) var colorScheme

    let goal: DSGoalSelector.GoalType
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                ZStack(alignment: .topTrailing) {
                    // Goal icon/image area
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.card(for: colorScheme))
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: goal.systemImage)
                                .font(.system(size: 50, weight: .medium))
                                .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary(for: colorScheme).opacity(0.6))
                        )

                    // Checkmark
                    if isSelected {
                        Circle()
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .padding(8)
                    }
                }

                // Title
                Text(goal.rawValue)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.95 : 1.0)
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

/// Level/Difficulty Selector with slider
struct DSLevelSelector: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var level: Int // 1-3 or 1-5

    let minLevel: Int
    let maxLevel: Int
    let title: String

    init(title: String = "LEVEL", level: Binding<Int>, minLevel: Int = 1, maxLevel: Int = 3) {
        self.title = title
        self._level = level
        self.minLevel = minLevel
        self.maxLevel = maxLevel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            HStack(spacing: DesignSystem.Spacing.md) {
                // Minus button
                Button(action: { if level > minLevel { level -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.card(for: colorScheme))
                        )
                }
                .disabled(level <= minLevel)
                .opacity(level <= minLevel ? 0.5 : 1.0)

                // Slider track
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.circle)
                            .fill(DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.2))
                            .frame(height: 12)

                        // Active track
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.circle)
                            .fill(DesignSystem.Colors.primary)
                            .frame(
                                width: geometry.size.width * CGFloat(level - minLevel) / CGFloat(maxLevel - minLevel),
                                height: 12
                            )

                        // Thumb
                        Circle()
                            .fill(.white)
                            .frame(width: 32, height: 32)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .offset(
                                x: (geometry.size.width - 32) * CGFloat(level - minLevel) / CGFloat(maxLevel - minLevel)
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let newValue = Int((value.location.x / geometry.size.width) * CGFloat(maxLevel - minLevel)) + minLevel
                                        level = min(max(newValue, minLevel), maxLevel)
                                    }
                            )
                    }
                }
                .frame(height: 32)

                // Plus button
                Button(action: { if level < maxLevel { level += 1 } }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.primary)
                        )
                }
                .disabled(level >= maxLevel)
                .opacity(level >= maxLevel ? 0.7 : 1.0)
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        DSGoalSelector(selectedGoal: .constant(.buildMuscle))

        DSLevelSelector(
            title: "LEVEL",
            level: .constant(2),
            minLevel: 1,
            maxLevel: 3
        )
    }
    .padding()
}
