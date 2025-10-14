# WorkIn Design System

A comprehensive design system for the WorkIn fitness tracking app, built with SwiftUI and inspired by modern fitness app designs.

## 📋 Table of Contents

- [Overview](#overview)
- [Color System](#color-system)
- [Typography](#typography)
- [Components](#components)
- [Usage Examples](#usage-examples)

## 🎨 Overview

The WorkIn Design System provides a consistent visual language and reusable components across the entire app. The design is based on the orange/coral brand color with support for both light and dark modes.

### Core Principles

- **Consistency**: Unified visual language across all screens
- **Accessibility**: Proper contrast ratios and readable typography
- **Flexibility**: Adaptive components that work in light and dark modes
- **Performance**: Lightweight components with minimal overhead

## 🎨 Color System

### Primary Brand Color
- **Primary Orange**: `#FF6B3D` - Main brand color used for CTAs, highlights, and key UI elements
- **Primary Light**: Lighter shade for hover states
- **Primary Dark**: Darker shade for active states

### Background Colors
- **Light Mode**: White (`#FFFFFF`)
- **Dark Mode**: Near Black (`#1C1C1E`)

### Card Colors
- **Light Mode**: White with subtle shadows
- **Dark Mode**: Dark Gray (`#2C2C2E`)

### Text Colors
- **Primary Text Light**: Black
- **Primary Text Dark**: White
- **Secondary Text Light**: Gray
- **Secondary Text Dark**: Light Gray (`#8E8E93`)

### Progress/Tracking Colors
- **Progress Green**: `#85DE63` - For step/activity tracking
- **Progress Blue**: `#40A3FF` - For water/hydration tracking

### Usage

```swift
import SwiftUI

struct MyView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text("Hello")
            .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
            .background(DesignSystem.Colors.card(for: colorScheme))
    }
}
```

## 📝 Typography

### Font Scales

- **Large Title**: 34pt, Bold - Page titles
- **Title 1**: 28pt, Bold - Section headers
- **Title 2**: 22pt, Bold - Card headers
- **Title 3**: 20pt, Semibold - Subsection headers
- **Body**: 17pt, Regular - Main content
- **Callout**: 16pt, Regular - Secondary content
- **Footnote**: 13pt, Regular - Tertiary content
- **Caption**: 12pt, Regular - Metadata

### Special Typography

- **Timer Large**: 48pt, Bold, Rounded - Large timer displays
- **Number Display**: 40pt, Bold, Rounded - Metrics and statistics

### Usage

```swift
Text("Workouts")
    .font(DesignSystem.Typography.title2)
    .fontWeight(.bold)
```

## 🧩 Components

### DSCard

Basic card component with consistent styling.

```swift
DSCard {
    VStack {
        Text("Card Title")
        Text("Card content")
    }
}
```

#### Variants

- **DSInfoCard**: Card with icon, title, value, and subtitle
- **DSStatCard**: Metric card with trend indicator

### DSButton

Primary button component with multiple styles and sizes.

```swift
DSButton("Sign Up", icon: "person.fill", style: .primary, size: .large) {
    // Action
}
```

#### Styles
- `.primary` - Orange background, white text
- `.secondary` - Card background, primary text
- `.outline` - Transparent with border
- `.ghost` - Transparent, no border
- `.danger` - Red background, white text

#### Sizes
- `.small` - 36pt height
- `.medium` - 48pt height (default)
- `.large` - 56pt height

### DSIconButton

Icon-only button variant.

```swift
DSIconButton(icon: "heart.fill", style: .primary, size: .medium) {
    // Action
}
```

### DSProgressRing

Circular progress indicator.

```swift
DSProgressRing(
    progress: 0.75,
    color: DesignSystem.Colors.primary,
    lineWidth: 12,
    size: 120
)
```

#### With Content

```swift
DSProgressRingWithContent(progress: 0.6, color: .green) {
    VStack {
        Text("3,020")
        Text("steps")
    }
}
```

### DSProgressCard

Complete progress tracking card with ring, icon, and controls.

```swift
DSProgressCard(
    icon: "figure.walk",
    title: "Steps",
    current: "3,020",
    goal: "4,000",
    progress: 0.755,
    color: DesignSystem.Colors.progressGreen,
    showDetail: true
) {
    // Detail action
}
```

### DSWeekTracker

Week progress tracker with star icons.

```swift
DSWeekTracker(
    completedDays: [true, true, true, true, true, true, false],
    accentColor: DesignSystem.Colors.primary
)
```

### DSGoalSelector

Goal selection component (Build Muscle, Lose Weight, Keep Fit).

```swift
@State var selectedGoal: DSGoalSelector.GoalType = .buildMuscle

DSGoalSelector(selectedGoal: $selectedGoal)
```

### DSLevelSelector

Level/difficulty slider component.

```swift
@State var level: Int = 2

DSLevelSelector(
    title: "LEVEL",
    level: $level,
    minLevel: 1,
    maxLevel: 3
)
```

### DSWeightTracker

Weight tracking card with chart visualization.

```swift
DSWeightTracker(
    currentWeight: 65.5,
    goalWeight: 65.0,
    weightDifference: -12.5,
    chartData: [
        .init(date: "21", weight: 78.0),
        .init(date: "22", weight: 75.0),
        // ...
    ]
)
```

### DSMetricCard

Simple metric card with increment/decrement controls.

```swift
DSMetricCard(
    title: "Water",
    value: 6,
    unit: "/ 8 cups",
    icon: "drop.fill",
    color: DesignSystem.Colors.progressBlue,
    onIncrement: { /* ... */ },
    onDecrement: { /* ... */ }
)
```

### DSExerciseTimer

Exercise timer interface with controls.

```swift
DSExerciseTimer(
    exerciseName: "Diamond Push-ups",
    exerciseNumber: 10,
    totalExercises: 16,
    timeRemaining: "00:12",
    isPlaying: false,
    canGoBack: true,
    canGoForward: true,
    onClose: { /* ... */ },
    onPrevious: { /* ... */ },
    onPlayPause: { /* ... */ },
    onNext: { /* ... */ },
    onInfo: { /* ... */ }
)
```

### DSRestTimer

Rest timer with circular countdown.

```swift
DSRestTimer(
    timeRemaining: 30,
    totalTime: 60,
    onSkip: { /* ... */ }
)
```

## 📐 Spacing & Layout

### Spacing Scale

```swift
DesignSystem.Spacing.xxs   // 4pt
DesignSystem.Spacing.xs    // 8pt
DesignSystem.Spacing.sm    // 12pt
DesignSystem.Spacing.md    // 16pt (default)
DesignSystem.Spacing.lg    // 20pt
DesignSystem.Spacing.xl    // 24pt
DesignSystem.Spacing.xxl   // 32pt
DesignSystem.Spacing.xxxl  // 40pt
```

### Corner Radius

```swift
DesignSystem.CornerRadius.xs      // 8pt
DesignSystem.CornerRadius.sm      // 12pt (buttons)
DesignSystem.CornerRadius.md      // 16pt
DesignSystem.CornerRadius.lg      // 20pt (cards)
DesignSystem.CornerRadius.xl      // 24pt
DesignSystem.CornerRadius.circle  // 999pt (fully rounded)
```

## 🎬 Animations

### Animation Presets

```swift
DesignSystem.Animation.quick     // 0.2s ease-in-out
DesignSystem.Animation.standard  // 0.3s ease-in-out
DesignSystem.Animation.slow      // 0.5s ease-in-out
DesignSystem.Animation.spring    // Spring animation
```

### Usage

```swift
withAnimation(DesignSystem.Animation.spring) {
    isExpanded.toggle()
}
```

## 💡 Usage Examples

### Complete Workout Card

```swift
DSCard(cornerRadius: DesignSystem.CornerRadius.lg) {
    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
        HStack {
            Image(systemName: "dumbbell.fill")
                .foregroundColor(DesignSystem.Colors.primary)

            Text("Push Day")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            Spacer()

            Text("45 min")
                .font(DesignSystem.Typography.footnote)
                .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
        }

        Text("8 exercises • 24 sets")
            .font(DesignSystem.Typography.caption1)
            .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
    }
}
```

### Progress Dashboard

```swift
VStack(spacing: DesignSystem.Spacing.lg) {
    HStack(spacing: DesignSystem.Spacing.md) {
        DSProgressCard(
            icon: "figure.walk",
            title: "Steps",
            current: "3,020",
            goal: "4,000",
            progress: 0.755,
            color: DesignSystem.Colors.progressGreen
        )

        DSProgressCard(
            icon: "drop.fill",
            title: "Water",
            current: "6",
            goal: "8 cups",
            progress: 0.75,
            color: DesignSystem.Colors.progressBlue
        )
    }

    DSWeekTracker(
        completedDays: [true, true, true, true, true, true, false],
        accentColor: DesignSystem.Colors.primary
    )
}
```

## 🔄 Migration from Old Theme

If you're migrating from the old theme system:

1. Replace `themeManager.backgroundColor` with `DesignSystem.Colors.background(for: colorScheme)`
2. Replace `themeManager.accentColor` with `DesignSystem.Colors.primary`
3. Replace `themeManager.primaryTextColor` with `DesignSystem.Colors.textPrimary(for: colorScheme)`
4. Replace custom colors like `Color.cyan` for brand elements with `DesignSystem.Colors.primary`

## 📝 Best Practices

1. **Always use design system colors** instead of hardcoded values
2. **Use typography scale** for consistent text sizing
3. **Leverage pre-built components** instead of recreating UI patterns
4. **Test in both light and dark modes** to ensure proper contrast
5. **Use spacing constants** for consistent layouts
6. **Apply animations** using the preset values for consistency

## 🤝 Contributing

When adding new components:

1. Follow the existing naming convention: `DS[ComponentName]`
2. Support both light and dark modes
3. Include preview code for Xcode previews
4. Document all parameters and use cases
5. Keep components focused and reusable

---

**Version**: 1.0
**Last Updated**: October 2025
**Maintained by**: WorkIn Team
