import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ActiveExerciseView: View {
    let exercise: Exercise
    let exerciseIndex: Int
    @State private var isExpanded = true
    @State private var newReps = ""
    @State private var newWeight = ""
    @State private var newDuration = "" // For time-based exercises
    @State private var restTime: Double = 60
    @State private var sets: [ExerciseSet]
    @StateObject private var profileStore = UserProfileStore()
    @State private var showingDeleteConfirmation = false
    @State private var restTimerActive = false
    @State private var restTimeRemaining: Double = 0
    @State private var restTimer: Timer?
    @State private var showTrackingHelp = false

    let onUpdateSets: ([ExerciseSet]) -> Void
    let onDeleteExercise: (() -> Void)?
    let bodyWeight: Double

    init(exercise: Exercise, exerciseIndex: Int, bodyWeight: Double = 0, onUpdateSets: @escaping ([ExerciseSet]) -> Void, onDeleteExercise: (() -> Void)? = nil) {
        self.exercise = exercise
        self.exerciseIndex = exerciseIndex
        self.bodyWeight = bodyWeight
        self.onUpdateSets = onUpdateSets
        self.onDeleteExercise = onDeleteExercise
        self._sets = State(initialValue: exercise.sets)
    }

    // Calculate current rank for this exercise
    private func getCurrentRank() -> StrengthRank? {
        // Use all valid sets with weight and reps (same as workout rank calculation)
        let validSets = sets.filter { $0.reps > 0 && $0.weight > 0 }
        guard !validSets.isEmpty, bodyWeight > 0 else { return nil }

        // Calculate one-rep max for each valid set and find the highest (same logic as workout rank calculation)
        let oneRepMaxes = validSets.compactMap { set -> Double? in
            // Brzycki formula: 1RM = weight * (36 / (37 - reps))
            if set.reps == 1 {
                return set.weight
            } else if set.reps >= 36 {
                // For very high reps, use a multiplier approach
                let baseRatio = 18.0
                let extraReps = Double(set.reps) - 35.0
                return set.weight * (baseRatio + extraReps * 0.3)
            } else {
                return set.weight * (36.0 / (37.0 - Double(set.reps)))
            }
        }

        guard let maxOneRepMax = oneRepMaxes.max(), maxOneRepMax > 0 else { return nil }
        return StrengthStandards.getRank(exerciseName: exercise.name, weight: maxOneRepMax, bodyWeight: bodyWeight, equipment: exercise.equipment)
    }

    // Determine if this is a time-based exercise
    private func isTimeBasedExercise() -> Bool {
        let exerciseName = exercise.name.lowercased()
        let timeBasedExercises = [
            "plank", "wall sit", "dead bug",
            "farmer", "farmers carry", "farmers carries",
            "hold", "static"
        ]
        return timeBasedExercises.contains { exerciseName.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            exerciseHeaderView

            if isExpanded {
                expandedContentView
            }
        }
        .padding(.vertical, 8)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            // Ensure local state syncs with current exercise data
            if sets != exercise.sets {
                sets = exercise.sets
            }
        }
        .onChange(of: sets) { newValue in
            onUpdateSets(newValue)
        }
        .onChange(of: exercise.sets) { newSets in
            // Always sync when parent changes, but don't trigger infinite loops
            DispatchQueue.main.async {
                if sets != newSets {
                    sets = newSets
                }
            }
        }
        .onChange(of: isExpanded) { _ in
            // When expanding/collapsing, ensure we have the latest data
            if sets != exercise.sets {
                sets = exercise.sets
            }
        }
        .alert("How to Track", isPresented: $showTrackingHelp) {
            Button("Got it!") { }
        } message: {
            Text(getTrackingInstructions())
        }
    }

    private func getTrackingInstructions() -> String {
        let exerciseName = exercise.name.lowercased()
        let equipmentType = exercise.equipment.lowercased()

        if isTimeBasedExercise() {
            return "This is a time-based exercise. Track the duration you hold the position in seconds, along with any additional weight used."
        }

        // Use equipment type as primary source, fall back to exercise name
        if equipmentType == "dumbbell" || exerciseName.contains("dumbbell") {
            return "For dumbbell exercises, enter the weight of ONE dumbbell (not both combined). For example, if using 50 lb dumbbells, enter 50 lbs.\n\nThe system automatically doubles this weight for ranking since you're lifting two dumbbells. Your rank is calculated based on the total weight relative to your body weight."
        }

        if equipmentType == "barbell" || exerciseName.contains("barbell") || exerciseName.contains("bench press") || exerciseName.contains("squat") || exerciseName.contains("deadlift") {
            return "For barbell exercises, enter the total weight including the bar. For example, a 45 lb bar with two 45 lb plates = 135 lbs total.\n\nYour rank is calculated based on the heaviest weight lifted relative to your body weight."
        }

        if equipmentType == "cable" || exerciseName.contains("cable") {
            return "For cable exercises, enter the weight shown on the machine stack. This is the actual resistance you're pulling.\n\nYour rank is calculated based on the heaviest weight lifted relative to your body weight."
        }

        if equipmentType == "machine" || exerciseName.contains("machine") || exerciseName.contains("press machine") || exerciseName.contains("leg press") ||
           exerciseName.contains("leg extension") || exerciseName.contains("leg curl") || exerciseName.contains("hack squat") {
            return "For machine exercises, enter the total weight on the machine. Some machines have pre-loaded weights - enter the full amount you're lifting.\n\nYour rank is calculated based on the heaviest weight lifted relative to your body weight."
        }

        if equipmentType == "bodyweight" || isBodyweightExercise() {
            return "For bodyweight exercises, enter any additional weight you're using. If doing the exercise with just your bodyweight, enter 0 or use the BW button to enter your current weight.\n\nYour rank is calculated including your bodyweight plus any added weight."
        }

        // Default for other exercises
        return "Track the number of reps you complete and the weight used. The rank is calculated based on the heaviest weight you lift relative to your body weight."
    }

    private var exerciseHeaderView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Button(action: {
                        showTrackingHelp = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                Text(exercise.muscleGroups.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if onDeleteExercise != nil {
                Button(action: { showingDeleteConfirmation = true }) {
                    Image(systemName: "trash.circle")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }

            Button(action: { isExpanded.toggle() }) {
                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .alert("Delete Exercise", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDeleteExercise?()
            }
        } message: {
            Text("Are you sure you want to remove \(exercise.name) from this workout?")
        }
    }

    private var expandedContentView: some View {
        VStack(spacing: 16) {
            if !sets.isEmpty {
                existingSetsView
            }

            // Rest timer appears between existing sets and add new set section
            if restTimerActive {
                restTimerView
            }

            addNewSetView
        }
    }

    private var existingSetsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sets (\(sets.count))")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(Array(sets.enumerated()), id: \.element.id) { setIndex, set in
                ActiveSetRowView(
                    set: set,
                    setNumber: setIndex + 1,
                    isTimeBased: isTimeBasedExercise(),
                    onToggleComplete: {
                        toggleSetCompletion(at: setIndex)
                    },
                    onDelete: {
                        deleteSet(at: setIndex)
                    }
                )
            }
        }
    }

    private var addNewSetView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Add Set \(sets.count + 1)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }

            HStack(spacing: 12) {
                if isTimeBasedExercise() {
                    // Time-based input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration (sec)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("60", text: $newDuration)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                } else {
                    // Rep-based input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("12", text: $newReps)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight (lbs)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        TextField("135", text: $newWeight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: isBodyweightExercise() ? 70 : 80)

                        if isBodyweightExercise() {
                            Button {
                                newWeight = String(Int(profileStore.profile.currentWeight))
                            } label: {
                                Text("BW")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .frame(width: 45, height: 30)
                        }
                    }
                }

                Spacer()

                Button("Add Set") {
                    addSet()
                }
                .buttonStyle(.bordered)
                .disabled(isTimeBasedExercise() ? (newDuration.isEmpty || newWeight.isEmpty) : (newReps.isEmpty || newWeight.isEmpty))
            }

            // Show rest time selector only when timer is not active
            if !restTimerActive {
                HStack {
                    Text("Rest Time: \(Int(restTime))s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Slider(value: $restTime, in: 30...300, step: 15)
                    .accentColor(.cyan)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .onAppear {
            // Auto-fill with previous set's values
            if let lastSet = sets.last {
                if isTimeBasedExercise() {
                    newDuration = String(lastSet.reps) // Duration stored in reps for time-based
                } else {
                    newReps = String(lastSet.reps)
                }
                newWeight = String(format: "%.0f", lastSet.weight)
                restTime = lastSet.restTime
            }
        }
    }

    private var restTimerView: some View {
        // Active countdown timer
        VStack(spacing: 8) {
            HStack {
                Text("Rest Timer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Skip") {
                    stopRestTimer()
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }

            HStack {
                Text("\(Int(restTimeRemaining))s")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(restTimeRemaining <= 10 ? .red : .blue)
                    .frame(maxWidth: .infinity)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(restTimeRemaining <= 10 ? Color.red : Color.blue)
                        .frame(width: geometry.size.width * CGFloat(restTimeRemaining / restTime), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(restTimeRemaining <= 10 ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
        .cornerRadius(8)
    }

    private func addSet() {
        let weight = Double(newWeight) ?? 0

        let newSet: ExerciseSet
        if isTimeBasedExercise() {
            // For time-based exercises, store duration in reps field
            guard let duration = Int(newDuration) else { return }
            newSet = ExerciseSet(
                reps: duration,
                weight: weight,
                restTime: restTime,
                completed: false
            )
            // Auto-fill for next set
            newDuration = String(duration)
        } else {
            // For rep-based exercises
            guard let reps = Int(newReps) else { return }
            newSet = ExerciseSet(
                reps: reps,
                weight: weight,
                restTime: restTime,
                completed: false
            )
            // Auto-fill for next set
            newReps = String(reps)
        }

        sets.append(newSet)
        newWeight = String(format: "%.0f", weight)

        // Dismiss keyboard after adding set
        hideKeyboard()
    }

    private func startRestTimer() {
        restTimeRemaining = restTime
        restTimerActive = true

        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if restTimeRemaining > 0 {
                restTimeRemaining -= 1
            } else {
                stopRestTimer()
            }
        }
    }

    private func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        restTimerActive = false
        restTimeRemaining = 0
    }

    private func toggleSetCompletion(at index: Int) {
        guard index >= 0 && index < sets.count else { return }
        var updatedSets = sets
        updatedSets[index].completed.toggle()

        // Start rest timer when completing a set
        if updatedSets[index].completed {
            startRestTimer()
        }

        sets = updatedSets
    }

    private func deleteSet(at index: Int) {
        guard index >= 0 && index < sets.count else { return }
        sets.remove(at: index)
    }

    private func isBodyweightExercise() -> Bool {
        let exerciseName = exercise.name.lowercased()
        let bodyweightExercises = [
            "pull up", "pull-up", "pullup",
            "chin up", "chin-up", "chinup",
            "push up", "push-up", "pushup",
            "dip", "dips",
            "muscle up", "muscle-up", "muscleup",
            "pistol squat",
            "handstand push up", "handstand push-up",
            "planche", "front lever", "back lever"
        ]

        return bodyweightExercises.contains { exerciseName.contains($0) }
    }
}

struct ActiveSetRowView: View {
    let set: ExerciseSet
    let setNumber: Int
    let isTimeBased: Bool
    let onToggleComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Set number
            Text("\(setNumber)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(set.completed ? .green : .blue)
                .frame(width: 30)

            // Set details
            VStack(alignment: .leading, spacing: 2) {
                if isTimeBased {
                    Text("\(set.reps)s × \(Int(set.weight)) lbs")
                        .font(.subheadline)
                        .strikethrough(set.completed)
                } else {
                    Text("\(set.reps) reps × \(Int(set.weight)) lbs")
                        .font(.subheadline)
                        .strikethrough(set.completed)
                }
                Text("Rest: \(Int(set.restTime))s")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Volume calculation
            Text("\(Int(Double(set.reps) * set.weight)) lbs")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(4)

            // Complete button
            Button(action: onToggleComplete) {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(set.completed ? .green : .gray)
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash.circle")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(set.completed ? Color.green.opacity(0.1) : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(set.completed ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

#Preview {
    ActiveExerciseView(
        exercise: Exercise(
            name: "Bench Press",
            sets: [
                ExerciseSet(reps: 10, weight: 135, completed: true),
                ExerciseSet(reps: 8, weight: 145, completed: false)
            ],
            muscleGroups: ["Chest", "Triceps"],
            equipment: "Barbell"
        ),
        exerciseIndex: 0
    ) { _ in }
}