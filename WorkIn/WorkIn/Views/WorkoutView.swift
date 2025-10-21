import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var templateStore: TemplateStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showingExerciseSelection = false
    @State private var showingAIWorkoutGenerator = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom header bar
                if workoutStore.currentWorkout == nil {
                    HStack {
                        Text("Workouts")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                        Spacer()

                        Button(action: { showingAIWorkoutGenerator = true }) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.purple)
                                .cornerRadius(8)
                                .shadow(color: Color.purple.opacity(0.4), radius: 6, x: 0, y: 3)
                        }

                        Button(action: { startQuickWorkout() }) {
                            Text("Log Workout")
                                .font(DesignSystem.Typography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(DesignSystem.Colors.primary)
                                .cornerRadius(8)
                                .shadow(color: DesignSystem.Colors.primary.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }

                if let currentWorkout = workoutStore.currentWorkout {
                    ActiveWorkoutView(
                        workout: currentWorkout,
                        workoutStore: workoutStore,
                        showingExerciseSelection: $showingExerciseSelection,
                        bodyWeight: profileStore.profile.currentWeight
                    )
                } else {
                    WorkoutHistoryView(workouts: workoutStore.workouts, workoutStore: workoutStore, bodyWeight: profileStore.profile.currentWeight)
                }
            }
            .background(DesignSystem.Colors.background(for: colorScheme))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingExerciseSelection) {
                ExerciseSelectionView(
                    workoutStore: workoutStore,
                    isPresented: $showingExerciseSelection
                )
            }
            .sheet(isPresented: $showingAIWorkoutGenerator) {
                WorkoutGeneratorView()
                    .environmentObject(templateStore)
                    .environmentObject(profileStore)
                    .environmentObject(workoutStore)
                    .environmentObject(themeManager)
            }
        }
    }

    private func startQuickWorkout() {
        let workoutName = "Workout \(DateFormatter.shortDateFormatter.string(from: Date()))"
        workoutStore.startWorkout(name: workoutName)
        showingExerciseSelection = true
    }
}

extension DateFormatter {
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}

struct WorkoutHistoryView: View {
    let workouts: [Workout]
    @ObservedObject var workoutStore: WorkoutStore
    let bodyWeight: Double
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedWorkout: Workout?
    @State private var currentPage: Int = 0

    var body: some View {
        if workouts.isEmpty {
            // Empty state
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer()

                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 80))
                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.3))

                Text("No Workouts Yet")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                Text("Start your first workout to see it here!")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Colors.background(for: colorScheme))
        } else {
            // Vertical scrolling with snap paging effect
            GeometryReader { geometry in
                VerticalPagingScrollView(
                    pageHeight: geometry.size.height,
                    workouts: workouts,
                    bodyWeight: bodyWeight,
                    onWorkoutTap: { workout in
                        selectedWorkout = workout
                    }
                )
            }
            .ignoresSafeArea(.all, edges: .top)
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
            .background(DesignSystem.Colors.background(for: colorScheme))
        }
    }
}

// Proper vertical paging scroll view with correct frame sizing
struct VerticalPagingScrollView: UIViewControllerRepresentable {
    let pageHeight: CGFloat
    let workouts: [Workout]
    let bodyWeight: Double
    let onWorkoutTap: (Workout) -> Void

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageVC = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: nil
        )

        pageVC.dataSource = context.coordinator
        pageVC.delegate = context.coordinator

        // Set initial page to first workout (most recent)
        if !workouts.isEmpty {
            let firstVC = context.coordinator.viewController(for: 0)
            pageVC.setViewControllers([firstVC], direction: .forward, animated: false)
        }

        return pageVC
    }

    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        // Update if workouts change
        context.coordinator.workouts = workouts
        context.coordinator.bodyWeight = bodyWeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            workouts: workouts,
            bodyWeight: bodyWeight,
            pageHeight: pageHeight,
            onWorkoutTap: onWorkoutTap
        )
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var workouts: [Workout]
        var bodyWeight: Double
        let pageHeight: CGFloat
        let onWorkoutTap: (Workout) -> Void

        init(workouts: [Workout], bodyWeight: Double, pageHeight: CGFloat, onWorkoutTap: @escaping (Workout) -> Void) {
            self.workouts = workouts
            self.bodyWeight = bodyWeight
            self.pageHeight = pageHeight
            self.onWorkoutTap = onWorkoutTap
        }

        func viewController(for index: Int) -> UIHostingController<FullPageWorkoutCard> {
            let workout = workouts[index]
            let card = FullPageWorkoutCard(
                workout: workout,
                bodyWeight: bodyWeight,
                onTap: { [weak self] in
                    self?.onWorkoutTap(workout)
                }
            )
            let vc = UIHostingController(rootView: card)
            vc.view.tag = index
            return vc
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = viewController.view.tag as Int?, index > 0 else {
                return nil
            }
            return self.viewController(for: index - 1)
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = viewController.view.tag as Int?, index < workouts.count - 1 else {
                return nil
            }
            return self.viewController(for: index + 1)
        }
    }
}

struct FullPageWorkoutCard: View {
    let workout: Workout
    let bodyWeight: Double
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme

    private var workoutRank: StrengthRank? {
        workout.getHighestRank(bodyWeight: bodyWeight)
    }

    private var muscleGroupRanks: [String: StrengthRank] {
        var ranks: [String: StrengthRank] = [:]

        // ALWAYS use stored bodyweight from the workout, not current bodyweight
        let effectiveBodyWeight = workout.bodyWeight ?? 181.0

        // For each exercise, calculate its rank and assign to its muscle groups
        for exercise in workout.exercises {
            // Calculate the rank for this exercise
            let oneRepMaxes = exercise.sets.compactMap { set -> Double? in
                guard set.reps > 0 && set.weight > 0 else { return nil }
                if set.reps == 1 {
                    return set.weight
                } else if set.reps >= 36 {
                    let baseRatio = 18.0
                    let extraReps = Double(set.reps) - 35.0
                    return set.weight * (baseRatio + extraReps * 0.3)
                } else {
                    return set.weight * (36.0 / (37.0 - Double(set.reps)))
                }
            }

            guard let maxOneRepMax = oneRepMaxes.max(), maxOneRepMax > 0 else { continue }

            let exerciseRank = StrengthStandards.getRank(
                exerciseName: exercise.name,
                weight: maxOneRepMax,
                bodyWeight: effectiveBodyWeight,
                equipment: exercise.equipment
            )

            // Assign this rank to all muscle groups worked by this exercise
            // If a muscle group already has a rank, keep the higher one
            for muscleGroup in exercise.muscleGroups {
                if let existingRank = ranks[muscleGroup] {
                    let currentIndex = StrengthRank.allCases.firstIndex(of: exerciseRank) ?? 0
                    let existingIndex = StrengthRank.allCases.firstIndex(of: existingRank) ?? 0
                    if currentIndex > existingIndex {
                        ranks[muscleGroup] = exerciseRank
                    }
                } else {
                    ranks[muscleGroup] = exerciseRank
                }
            }
        }

        return ranks
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top section with workout name and date
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(workout.name)
                        .font(DesignSystem.Typography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                        .multilineTextAlignment(.center)

                    Text(workout.date, style: .date)
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }
                .padding(.top, DesignSystem.Spacing.xxl)
                .padding(.horizontal, DesignSystem.Spacing.lg)

                Spacer()

                // Main content: Muscle diagram and rank badge
                ZStack {
                    // Muscle group diagram with rank-based colors
                    MuscleGroupDiagram(muscleGroupRanks: muscleGroupRanks)
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.5)
                        .padding(DesignSystem.Spacing.xl)

                    // Rank badge overlay (center-right)
                    if let rank = workoutRank {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack(spacing: DesignSystem.Spacing.sm) {
                                    Image(rank.badgeImageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 120, height: 120)
                                        .shadow(color: rank.glowColor.opacity(0.9 * rank.glowIntensity), radius: 25 * rank.glowIntensity, x: 0, y: 0)
                                        .shadow(color: rank.glowColor.opacity(0.7 * rank.glowIntensity), radius: 15 * rank.glowIntensity, x: 0, y: 0)
                                        .shadow(color: rank.glowColor.opacity(0.5 * rank.glowIntensity), radius: 8 * rank.glowIntensity, x: 0, y: 0)

                                    Text(rank.rawValue)
                                        .font(DesignSystem.Typography.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                                        .shadow(color: rank.glowColor.opacity(0.3), radius: 4)
                                }
                                .padding(DesignSystem.Spacing.xl)
                                .background(
                                    Circle()
                                        .fill(rank.glowColor.opacity(0.1))
                                        .blur(radius: 30)
                                )
                            }
                            Spacer()
                        }
                    }
                }

                Spacer()

                // Bottom section with stats
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Duration and exercise count
                    HStack(spacing: DesignSystem.Spacing.xxl) {
                        VStack(spacing: DesignSystem.Spacing.xxs) {
                            Text("\(formatDuration(workout.duration))")
                                .font(DesignSystem.Typography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Duration")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.white.opacity(0.9))
                        }

                        Divider()
                            .frame(height: 40)
                            .background(.white.opacity(0.5))

                        VStack(spacing: DesignSystem.Spacing.xxs) {
                            Text("\(workout.exercises.count)")
                                .font(DesignSystem.Typography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Exercises")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.white.opacity(0.9))
                        }

                        Divider()
                            .frame(height: 40)
                            .background(.white.opacity(0.5))

                        VStack(spacing: DesignSystem.Spacing.xxs) {
                            let totalSets = workout.exercises.reduce(0) { $0 + $1.sets.count }
                            Text("\(totalSets)")
                                .font(DesignSystem.Typography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Sets")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .fill(DesignSystem.Colors.primary)
                    )
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.6), radius: 8, x: 0, y: 0)
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.4), radius: 15, x: 0, y: 0)
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.25), radius: 22, x: 0, y: 0)

                    // Tap to view details hint
                    Text("Tap to view details")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                        .padding(.bottom, DesignSystem.Spacing.xs)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Colors.background(for: colorScheme))
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    let bodyWeight: Double
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme

    private var workoutRank: StrengthRank? {
        workout.getHighestRank(bodyWeight: bodyWeight)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                Text(workout.name)
                    .font(DesignSystem.Typography.bodyBold)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primary)

                Spacer()

                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }

            HStack(alignment: .center) {
                // Duration on the left
                if workout.duration > 0 {
                    Text(formatDuration(workout.duration))
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Large rank badge in the center
                if let rank = workoutRank {
                    Image(rank.badgeImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .shadow(color: rank.glowColor.opacity(0.8 * rank.glowIntensity), radius: 15 * rank.glowIntensity, x: 0, y: 0)
                        .shadow(color: rank.glowColor.opacity(0.6 * rank.glowIntensity), radius: 8 * rank.glowIntensity, x: 0, y: 0)
                        .shadow(color: rank.glowColor.opacity(0.4 * rank.glowIntensity), radius: 4 * rank.glowIntensity, x: 0, y: 0)
                        .padding(.horizontal, 8)
                        .onAppear {
                            print("🏋️ WorkoutRowView: Displaying rank \(rank.badgeImageName) for workout '\(workout.name)' (bodyweight: \(bodyWeight) lbs)")
                        }
                }

                // Exercise count on the right
                Text("\(workout.exercises.count) exercises")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .onAppear {
                if workoutRank == nil {
                    print("🏋️ WorkoutRowView: No rank found for workout '\(workout.name)' (bodyweight: \(bodyWeight) lbs)")
                }
            }

            if !workout.exercises.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(workout.exercises.prefix(3)) { exercise in
                            ExerciseBadge(exerciseName: exercise.name)
                        }
                        if workout.exercises.count > 3 {
                            Text("+\(workout.exercises.count - 3) more")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(themeManager.cardBackgroundColor)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .background(
                ZStack {
                    DesignSystem.Colors.card(for: colorScheme)
                    if let rank = workoutRank {
                        rank.glowColor.opacity(0.05)
                    } else {
                        DesignSystem.Colors.primary.opacity(0.03)
                    }
                }
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke((workoutRank?.glowColor ?? DesignSystem.Colors.primary).opacity(0.3), lineWidth: 1)
            )
            .shadow(color: (workoutRank?.glowColor ?? DesignSystem.Colors.primary).opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 4)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

struct ExerciseBadge: View {
    let exerciseName: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text(exerciseName)
            .font(DesignSystem.Typography.caption1)
            .lineLimit(1)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(DesignSystem.Colors.primary.opacity(0.1))
            .foregroundColor(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.xs)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                    .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 0.5)
            )
    }
}

struct WorkoutCompletion: Identifiable {
    let id = UUID()
    let workout: Workout
    let rank: StrengthRank?
    let personalRecords: [PersonalRecord]
}

struct ActiveWorkoutView: View {
    @State var workout: Workout
    @ObservedObject var workoutStore: WorkoutStore
    @Binding var showingExerciseSelection: Bool
    let bodyWeight: Double
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State private var startTime = Date()
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var workoutCompletion: WorkoutCompletion?
    @State private var showingEmptyWorkoutAlert = false
    @State private var showingCancelConfirmation = false

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top header with Add Exercise button
            HStack {
                Spacer()

                Button(action: { showingExerciseSelection = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Add Exercise")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DesignSystem.Colors.primary.opacity(0.8), lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(DesignSystem.Colors.background(for: colorScheme))

            ScrollView {
                VStack(spacing: 20) {
                    workoutHeader

                    if workout.exercises.isEmpty {
                        emptyExercisesView
                    } else {
                        exercisesSection
                    }

                    actionButtons
                }
                .padding()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: workoutStore.currentWorkout) { newWorkout in
            // Only sync if exercises were added/removed, not if sets were updated
            // This prevents overwriting local set changes
            if let newWorkout = newWorkout {
                if newWorkout.exercises.count != workout.exercises.count {
                    print("📝 onChange: Syncing workout due to exercise count change (\(workout.exercises.count) -> \(newWorkout.exercises.count))")
                    workout = newWorkout
                } else {
                    print("📝 onChange: Skipping sync - exercise count is same (\(workout.exercises.count))")
                }
            } else {
                print("📝 onChange: workoutStore.currentWorkout is nil")
            }
        }
        .sheet(item: $workoutCompletion) { completion in
            WorkoutCompletionSummaryView(
                completedWorkout: completion.workout,
                achievedRank: completion.rank,
                personalRecords: completion.personalRecords,
                isPresented: Binding(
                    get: { workoutCompletion != nil },
                    set: { if !$0 { workoutCompletion = nil } }
                )
            )
            .onAppear {
                print("🎉 SUCCESS: Sheet presenting completion summary for workout: \(completion.workout.name)")
                print("🎉 SUCCESS: Rank in sheet: \(completion.rank?.rawValue ?? "None")")
            }
            .onDisappear {
                // Save workout when sheet is dismissed
                workoutStore.currentWorkout = completion.workout
                workoutStore.finishCurrentWorkout()
                NotificationCenter.default.post(name: NSNotification.Name("WorkoutCompleted"), object: completion.workout)
                print("🎉 Workout saved to store after sheet dismissed")
                workoutCompletion = nil
            }
        }
        .alert("No Sets Logged", isPresented: $showingEmptyWorkoutAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please add at least one set to an exercise before finishing your workout.")
        }
    }

    private var workoutHeader: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(workout.name)
                .font(DesignSystem.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            Text("Duration: \(formatDuration(elapsedTime))")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                .fontWeight(.medium)

            Text("\(workout.exercises.count) exercises")
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.card(for: colorScheme))
        .cornerRadius(DesignSystem.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(DesignSystem.Colors.primary.opacity(0.8), lineWidth: 2)
        )
    }

    private var emptyExercisesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No exercises added yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Tap 'Add Exercise' to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
    }

    private var exercisesSection: some View {
        VStack(spacing: 16) {
            ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                ActiveExerciseView(
                    exercise: exercise,
                    exerciseIndex: index,
                    bodyWeight: bodyWeight,
                    onUpdateSets: { updatedSets in
                        updateExerciseSets(exerciseIndex: index, sets: updatedSets)
                    },
                    onDeleteExercise: {
                        deleteExercise(at: index)
                    }
                )
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: { showingCancelConfirmation = true }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Cancel")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red.opacity(0.8), lineWidth: 2)
                    )
                }

                Button(action: finishWorkout) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Finish")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green.opacity(0.8), lineWidth: 2)
                    )
                }
            }
        }
        .alert("Cancel Workout", isPresented: $showingCancelConfirmation) {
            Button("Keep Working Out", role: .cancel) { }
            Button("Cancel Workout", role: .destructive) {
                cancelWorkout()
            }
        } message: {
            Text("Are you sure you want to cancel this workout? All progress will be lost.")
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateExerciseInStore(_ updatedExercise: Exercise) {
        workoutStore.currentWorkout?.exercises = workout.exercises
    }

    private func updateExerciseSets(exerciseIndex: Int, sets: [ExerciseSet]) {
        guard exerciseIndex >= 0 && exerciseIndex < workout.exercises.count else {
            print("⚠️ updateExerciseSets: Invalid index \(exerciseIndex)")
            return
        }

        print("📝 updateExerciseSets: Updating exercise \(exerciseIndex) (\(workout.exercises[exerciseIndex].name)) with \(sets.count) sets")

        // Create a new workout to trigger SwiftUI update (structs need replacement, not mutation)
        var updatedWorkout = workout
        updatedWorkout.exercises[exerciseIndex].sets = sets
        workout = updatedWorkout
        print("📝 updateExerciseSets: Local workout now has \(workout.exercises[exerciseIndex].sets.count) sets")

        // Update workout store - need to replace the whole workout to trigger @Published
        if var currentWorkout = workoutStore.currentWorkout {
            currentWorkout.exercises[exerciseIndex].sets = sets
            workoutStore.currentWorkout = currentWorkout
            print("📝 updateExerciseSets: Store workout now has \(workoutStore.currentWorkout?.exercises[exerciseIndex].sets.count ?? 0) sets")
        }
    }

    private func deleteExercise(at index: Int) {
        guard index >= 0 && index < workout.exercises.count else { return }

        print("🗑️ Deleting exercise at index \(index): \(workout.exercises[index].name)")

        var updatedWorkout = workout
        updatedWorkout.exercises.remove(at: index)
        workout = updatedWorkout

        // Update store
        if var currentWorkout = workoutStore.currentWorkout {
            currentWorkout.exercises.remove(at: index)
            workoutStore.currentWorkout = currentWorkout
        }
    }

    private func cancelWorkout() {
        stopTimer()
        workoutStore.currentWorkout = nil
    }

    private func finishWorkout() {
        print("🎉 finishWorkout() called - starting workout completion")

        // Check if any sets have been logged
        let totalSets = workout.exercises.reduce(0) { $0 + $1.sets.count }
        if totalSets == 0 {
            print("⚠️ No sets logged - showing alert")
            showingEmptyWorkoutAlert = true
            return
        }

        stopTimer()

        // Use the LOCAL workout variable which has the most up-to-date sets
        var finalWorkout = workout
        finalWorkout.date = Date()
        finalWorkout.duration = elapsedTime
        finalWorkout.bodyWeight = bodyWeight // Store bodyweight at time of workout

        print("🎉 Current workout found: \(finalWorkout.name)")
        print("🎉 DEBUG: Final workout has \(finalWorkout.exercises.count) exercises")
        for (i, ex) in finalWorkout.exercises.enumerated() {
            print("🎉 DEBUG: Exercise \(i): \(ex.name) - \(ex.sets.count) sets")
            for (j, set) in ex.sets.enumerated() {
                print("🎉 DEBUG:   Set \(j): \(set.reps) reps × \(set.weight) lbs")
            }
        }

        // Detect personal records and rank
        let previousWorkouts = workoutStore.workouts
        let detectedPRs = finalWorkout.detectPersonalRecords(comparedTo: previousWorkouts)
        let detectedRank = finalWorkout.getHighestRank(bodyWeight: bodyWeight)

        print("🎉 Workout completed with \(detectedPRs.count) PRs and rank: \(detectedRank?.rawValue ?? "None") (bodyweight: \(bodyWeight) lbs [STORED])")

        // Create completion object with all data bundled together
        let completion = WorkoutCompletion(
            workout: finalWorkout,
            rank: detectedRank,
            personalRecords: detectedPRs
        )

        print("🎉 About to show completion summary - Rank: \(completion.rank?.rawValue ?? "None")")
        workoutCompletion = completion
        print("🎉 workoutCompletion set - sheet should now appear")
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct NewWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutName = ""
    @State private var showingTemplates = false
    @ObservedObject var workoutStore: WorkoutStore

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Start New Workout")
                        .font(.title)
                        .fontWeight(.bold)

                    TextField("Workout Name", text: $workoutName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }

                VStack(spacing: 12) {
                    Button(action: startCustomWorkout) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Start Custom Workout")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(workoutName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(workoutName.isEmpty)

                    Button(action: { showingTemplates = true }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Choose from Templates")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingTemplates) {
                TemplateSelectionView(workoutStore: workoutStore)
            }
        }
    }

    private func startCustomWorkout() {
        workoutStore.startWorkout(name: workoutName)
        dismiss()
    }
}

struct TemplateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var workoutStore: WorkoutStore

    var body: some View {
        NavigationView {
            List {
                ForEach(WorkoutTemplateDatabase.templates) { template in
                    Button(action: {
                        workoutStore.startWorkoutFromTemplate(template)
                        dismiss()
                    }) {
                        WorkoutTemplateRowView(template: template)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Workout Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Workout Completion Summary

struct WorkoutCompletionSummaryView: View {
    let completedWorkout: Workout
    let achievedRank: StrengthRank?
    let personalRecords: [PersonalRecord]
    @Binding var isPresented: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Celebration Header
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Text("🎉")
                                .font(.title)
                            Text("Workout Complete!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.accentColor)
                            Text("🎉")
                                .font(.title)
                        }
                        .frame(maxWidth: .infinity)

                        Text(completedWorkout.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.primaryTextColor)
                            .multilineTextAlignment(.center)

                        Text(formatDuration(completedWorkout.duration))
                            .font(.headline)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .padding()
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(16)

                    // Rank Achievement
                    if let rank = achievedRank {
                        VStack(spacing: 12) {
                            Text("Strength Achievement")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor)

                            HStack(spacing: 16) {
                                Image(rank.badgeImageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: rank.glowColor.opacity(0.9 * rank.glowIntensity), radius: 20 * rank.glowIntensity, x: 0, y: 0)
                                    .shadow(color: rank.glowColor.opacity(0.7 * rank.glowIntensity), radius: 12 * rank.glowIntensity, x: 0, y: 0)
                                    .shadow(color: rank.glowColor.opacity(0.5 * rank.glowIntensity), radius: 6 * rank.glowIntensity, x: 0, y: 0)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(rank.rawValue)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(themeManager.accentColor)

                                    Text(getRankMessage(for: rank))
                                        .font(.subheadline)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        .padding()
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 2)
                        )
                        .onAppear {
                            print("🏆 SUMMARY: Displaying rank: \(rank.rawValue) \(rank.symbol)")
                        }
                    } else {
                        Text("🏆 No rank achieved (add weight exercises to earn a rank!)")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .padding()
                            .onAppear {
                                print("🏆 SUMMARY: No rank to display - achievedRank is nil")
                            }
                    }

                    // Personal Records
                    if !personalRecords.isEmpty {
                        VStack(spacing: 12) {
                            HStack {
                                Text("🚀 New Personal Records!")
                                    .font(.headline)
                                    .foregroundColor(themeManager.accentColor)
                                Spacer()
                            }

                            ForEach(personalRecords.indices, id: \.self) { index in
                                let pr = personalRecords[index]
                                PersonalRecordRowView(personalRecord: pr)
                            }
                        }
                        .padding()
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.4), lineWidth: 2)
                        )
                    }

                    // Workout Stats
                    VStack(spacing: 12) {
                        Text("Workout Stats")
                            .font(.headline)
                            .foregroundColor(themeManager.primaryTextColor)

                        HStack(spacing: 20) {
                            StatItemView(
                                icon: "dumbbell.fill",
                                label: "Exercises",
                                value: "\(completedWorkout.exercises.count)"
                            )

                            StatItemView(
                                icon: "clock.fill",
                                label: "Duration",
                                value: formatDurationShort(completedWorkout.duration)
                            )

                            StatItemView(
                                icon: "flame.fill",
                                label: "Sets",
                                value: "\(completedWorkout.exercises.map { $0.sets.count }.reduce(0, +))"
                            )
                        }
                    }
                    .padding()
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(12)

                    // Workout Details
                    VStack(spacing: 12) {
                        HStack {
                            Text("Workout Details")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor)
                            Spacer()
                        }

                        ForEach(completedWorkout.exercises) { exercise in
                            ExerciseSummaryCard(exercise: exercise, bodyWeight: completedWorkout.bodyWeight ?? 181)
                        }
                    }
                    .padding()
                    .background(themeManager.cardBackgroundColor)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }

    private func getRankMessage(for rank: StrengthRank) -> String {
        switch rank {
        case .bronze:
            return "Great start on your strength journey!"
        case .silver:
            return "You're building solid foundations!"
        case .gold:
            return "Impressive strength development!"
        case .platinum:
            return "You're among the strong ones!"
        case .diamond:
            return "Outstanding strength achievement!"
        case .arnold:
            return "Arnold-level strength! Legendary!"
        case .hulk:
            return "Hulk smash! Incredible power!"
        case .superman:
            return "Superman strength! You're unstoppable!"
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }

    private func formatDurationShort(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
}

struct ExerciseSummaryCard: View {
    let exercise: Exercise
    let bodyWeight: Double
    @EnvironmentObject var themeManager: ThemeManager

    private var exerciseRank: StrengthRank? {
        guard bodyWeight > 0 else { return nil }

        // Calculate one-rep max for each valid set and find the highest (same logic as workout ranking)
        let oneRepMaxes = exercise.sets.compactMap { set -> Double? in
            guard set.reps > 0 && set.weight > 0 else { return nil }
            // Brzycki formula: 1RM = weight * (36 / (37 - reps))
            if set.reps == 1 {
                return set.weight
            } else if set.reps >= 36 {
                // For very high reps, use a multiplier approach to avoid infinite values
                let baseRatio = 18.0  // Approximate ratio at 35 reps
                let extraReps = Double(set.reps) - 35.0
                return set.weight * (baseRatio + extraReps * 0.3)  // Add 0.3x per rep beyond 35
            } else {
                return set.weight * (36.0 / (37.0 - Double(set.reps)))
            }
        }

        guard let maxOneRepMax = oneRepMaxes.max(), maxOneRepMax > 0 else { return nil }

        return StrengthStandards.getRank(exerciseName: exercise.name, weight: maxOneRepMax, bodyWeight: bodyWeight, equipment: exercise.equipment)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryTextColor)

                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }

                Spacer()

                if let rank = exerciseRank {
                    Image(rank.badgeImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .shadow(color: rank.glowColor.opacity(0.8 * rank.glowIntensity), radius: 10 * rank.glowIntensity, x: 0, y: 0)
                        .shadow(color: rank.glowColor.opacity(0.6 * rank.glowIntensity), radius: 6 * rank.glowIntensity, x: 0, y: 0)
                        .shadow(color: rank.glowColor.opacity(0.4 * rank.glowIntensity), radius: 3 * rank.glowIntensity, x: 0, y: 0)
                }

                Text("\(exercise.sets.count) sets")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }

            // Sets list
            VStack(spacing: 4) {
                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                    HStack(spacing: 8) {
                        Text("Set \(index + 1)")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .frame(width: 50, alignment: .leading)

                        Text("\(set.reps) reps × \(Int(set.weight)) lbs")
                            .font(.caption)
                            .foregroundColor(themeManager.primaryTextColor)

                        Spacer()

                        Text("\(Int(Double(set.reps) * set.weight)) lbs")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.secondaryBackgroundColor.opacity(0.5))
                    .cornerRadius(6)
                }
            }

            // Total volume for this exercise
            HStack {
                Spacer()
                Text("Total Volume: \(calculateTotalVolume()) lbs")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.accentColor)
            }
        }
        .padding(12)
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(8)
    }

    private func calculateTotalVolume() -> Int {
        exercise.sets.reduce(0) { total, set in
            total + Int(Double(set.reps) * set.weight)
        }
    }
}

struct PersonalRecordRowView: View {
    let personalRecord: PersonalRecord
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(personalRecord.exerciseName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryTextColor)

                HStack(spacing: 8) {
                    Text("\(Int(personalRecord.previousMax)) lbs")
                        .foregroundColor(themeManager.secondaryTextColor)

                    Image(systemName: "arrow.right")
                        .foregroundColor(Color.green)

                    Text("\(Int(personalRecord.newMax)) lbs")
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                }
                .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(Int(personalRecord.improvement)) lbs")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.green)

                Text("+\(String(format: "%.1f", personalRecord.improvementPercentage))%")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatItemView: View {
    let icon: String
    let label: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.accentColor)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)

            Text(label)
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WorkoutView()
        .environmentObject(WorkoutStore())
}