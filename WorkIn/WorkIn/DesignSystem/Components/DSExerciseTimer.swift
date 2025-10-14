import SwiftUI

/// Exercise timer component (like in screenshot with Diamond Push-ups)
struct DSExerciseTimer: View {
    @Environment(\.colorScheme) var colorScheme

    let exerciseName: String
    let exerciseNumber: Int
    let totalExercises: Int
    let timeRemaining: String
    let isPlaying: Bool
    let canGoBack: Bool
    let canGoForward: Bool
    let onClose: () -> Void
    let onPrevious: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let onInfo: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Exercises \(exerciseNumber) / \(totalExercises)")
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    Text(timeRemaining)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }

                Spacer()

                Button(action: onInfo) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)

            // Exercise visualization area
            ZStack {
                // Background
                Rectangle()
                    .fill(DesignSystem.Colors.background(for: colorScheme))

                // Placeholder for exercise image/animation
                VStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 100))
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.3))

                    // Joint markers (orange dots from screenshot)
                    // This would be replaced with actual exercise visualization
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)

            Spacer()

            // Exercise name and timer
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(exerciseName.uppercased())
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                Text(timeRemaining)
                    .font(DesignSystem.Typography.timerLarge)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
            }
            .padding(.vertical, DesignSystem.Spacing.lg)

            // Controls
            HStack(spacing: DesignSystem.Spacing.xxxl) {
                Button(action: onPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 28))
                        .foregroundColor(canGoBack ? DesignSystem.Colors.textPrimary(for: colorScheme) : DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.3))
                }
                .disabled(!canGoBack)

                Button(action: onPlayPause) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.primary)
                            .frame(width: 80, height: 80)

                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }

                Button(action: onNext) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 28))
                        .foregroundColor(canGoForward ? DesignSystem.Colors.textPrimary(for: colorScheme) : DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.3))
                }
                .disabled(!canGoForward)
            }
            .padding(.bottom, DesignSystem.Spacing.xxxl)
        }
        .background(DesignSystem.Colors.background(for: colorScheme))
    }
}

/// Rest timer component
struct DSRestTimer: View {
    @Environment(\.colorScheme) var colorScheme

    let timeRemaining: Int // in seconds
    let totalTime: Int
    let onSkip: () -> Void

    var progress: Double {
        1.0 - (Double(timeRemaining) / Double(totalTime))
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            Text("REST")
                .font(DesignSystem.Typography.title1)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            // Circular timer
            ZStack {
                DSProgressRing(
                    progress: progress,
                    color: DesignSystem.Colors.primary,
                    lineWidth: 16,
                    size: 200
                )

                Text("\(timeRemaining)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
            }

            Spacer()

            DSButton("Skip Rest", style: .outline, size: .large, action: onSkip)
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background(for: colorScheme))
    }
}

/// Exercise preview card
struct DSExercisePreviewCard: View {
    @Environment(\.colorScheme) var colorScheme

    let exerciseName: String
    let duration: String
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Exercise thumbnail
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(isActive ? DesignSystem.Colors.primary.opacity(0.2) : DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 24))
                            .foregroundColor(isActive ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary(for: colorScheme))
                    )

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(exerciseName)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(isActive ? .semibold : .regular)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    Text(duration)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }

                Spacer()

                if isActive {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .padding(DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(isActive ? DesignSystem.Colors.primary.opacity(0.1) : DesignSystem.Colors.card(for: colorScheme))
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DSExerciseTimer(
            exerciseName: "Diamond Push-ups",
            exerciseNumber: 10,
            totalExercises: 16,
            timeRemaining: "00:12",
            isPlaying: false,
            canGoBack: true,
            canGoForward: true,
            onClose: {},
            onPrevious: {},
            onPlayPause: {},
            onNext: {},
            onInfo: {}
        )

        DSRestTimer(
            timeRemaining: 30,
            totalTime: 60,
            onSkip: {}
        )

        VStack(spacing: 8) {
            DSExercisePreviewCard(
                exerciseName: "Diamond Push-ups",
                duration: "00:30",
                isActive: true,
                onTap: {}
            )

            DSExercisePreviewCard(
                exerciseName: "Regular Push-ups",
                duration: "00:30",
                isActive: false,
                onTap: {}
            )
        }
        .padding()
    }
}
