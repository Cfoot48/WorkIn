import SwiftUI

/// Weight tracker component with chart (like in screenshot)
struct DSWeightTracker: View {
    @Environment(\.colorScheme) var colorScheme

    let currentWeight: Double
    let goalWeight: Double
    let weightDifference: Double
    let chartData: [WeightDataPoint]

    struct WeightDataPoint: Identifiable {
        let id = UUID()
        let date: String
        let weight: Double
    }

    var body: some View {
        DSCard(padding: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))

                        Text("\(currentWeight, specifier: "%.1f") kg")
                            .font(DesignSystem.Typography.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                    }

                    Spacer()

                    // Character/mascot area
                    Image(systemName: "figure.stand")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.primary)
                }

                // Weight difference badge
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 16, weight: .bold))

                    Text("\(abs(weightDifference), specifier: "%.1f") kg")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    Capsule()
                        .fill(DesignSystem.Colors.primary)
                )

                // Chart
                WeightChart(
                    data: chartData,
                    goalWeight: goalWeight,
                    colorScheme: colorScheme
                )
                .frame(height: 120)
            }
        }
    }
}

/// Simple line chart for weight tracking
private struct WeightChart: View {
    let data: [DSWeightTracker.WeightDataPoint]
    let goalWeight: Double
    let colorScheme: ColorScheme

    var body: some View {
        GeometryReader { geometry in
            let maxWeight = data.map { $0.weight }.max() ?? 80
            let minWeight = min(data.map { $0.weight }.min() ?? 60, goalWeight)
            let range = maxWeight - minWeight
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .bottomLeading) {
                // Goal line
                let goalY = height - ((goalWeight - minWeight) / range) * height
                Path { path in
                    path.move(to: CGPoint(x: 0, y: goalY))
                    path.addLine(to: CGPoint(x: width, y: goalY))
                }
                .stroke(
                    style: StrokeStyle(lineWidth: 2, dash: [5, 5])
                )
                .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.5))

                // Goal label
                Text("Goal")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                    .offset(x: width - 40, y: -goalY + 10)

                // Weight line
                Path { path in
                    for (index, point) in data.enumerated() {
                        let x = (width / CGFloat(data.count - 1)) * CGFloat(index)
                        let y = height - ((point.weight - minWeight) / range) * height

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(DesignSystem.Colors.primary, lineWidth: 3)

                // Data points
                ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                    let x = (width / CGFloat(data.count - 1)) * CGFloat(index)
                    let y = height - ((point.weight - minWeight) / range) * height

                    Circle()
                        .fill(DesignSystem.Colors.primary)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }

                // Date labels
                HStack {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                        if index % 2 == 0 || index == data.count - 1 {
                            Text(point.date)
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .offset(y: height + 8)
            }
        }
    }
}

/// Simple metric card with increment/decrement buttons
struct DSMetricCard: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    let value: Int
    let unit: String
    let icon: String
    let color: Color
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        DSCard {
            VStack(spacing: DesignSystem.Spacing.sm) {
                // Title with icon
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)

                    Text(title)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    Spacer()
                }

                // Value
                Text("\(value)")
                    .font(DesignSystem.Typography.numberDisplay)
                    .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                Text(unit)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))

                // Controls
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Button(action: onDecrement) {
                        Text("−")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                                    .fill(DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.1))
                            )
                    }

                    Button(action: onIncrement) {
                        Text("+")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                                    .fill(color)
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            DSWeightTracker(
                currentWeight: 65.5,
                goalWeight: 65.0,
                weightDifference: -12.5,
                chartData: [
                    .init(date: "21", weight: 78.0),
                    .init(date: "22", weight: 75.0),
                    .init(date: "23", weight: 72.0),
                    .init(date: "24", weight: 70.0),
                    .init(date: "25", weight: 68.0),
                    .init(date: "26", weight: 65.5),
                    .init(date: "27", weight: 65.0)
                ]
            )

            HStack(spacing: 12) {
                DSMetricCard(
                    title: "Steps",
                    value: 3020,
                    unit: "/ 4,000",
                    icon: "figure.walk",
                    color: DesignSystem.Colors.progressGreen,
                    onIncrement: {},
                    onDecrement: {}
                )

                DSMetricCard(
                    title: "Water",
                    value: 6,
                    unit: "/ 8 cups",
                    icon: "drop.fill",
                    color: DesignSystem.Colors.progressBlue,
                    onIncrement: {},
                    onDecrement: {}
                )
            }
        }
        .padding()
    }
}
