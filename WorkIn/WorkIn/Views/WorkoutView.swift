import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @State private var showingExerciseSelection = false

    var body: some View {
        NavigationView {
            VStack {
                if let currentWorkout = workoutStore.currentWorkout {
                    ActiveWorkoutView(
                        workout: currentWorkout,
                        workoutStore: workoutStore,
                        showingExerciseSelection: $showingExerciseSelection
                    )
                } else {
                    WorkoutHistoryView(workouts: workoutStore.workouts, workoutStore: workoutStore)
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Workout") {
                        startQuickWorkout()
                    }
                }
            }
            .sheet(isPresented: $showingExerciseSelection) {
                ExerciseSelectionView(
                    workoutStore: workoutStore,
                    isPresented: $showingExerciseSelection
                )
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

    var body: some View {
        List {
            ForEach(workouts) { workout in
                WorkoutRowView(workout: workout)
            }
            .onDelete(perform: workoutStore.deleteWorkouts)
        }
        .listStyle(PlainListStyle())
    }
}

struct WorkoutRowView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("\(workout.exercises.count) exercises")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                if workout.duration > 0 {
                    Text(formatDuration(workout.duration))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
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

    var body: some View {
        Text(exerciseName)
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
    }
}

struct ActiveWorkoutView: View {
    @State var workout: Workout
    @ObservedObject var workoutStore: WorkoutStore
    @Binding var showingExerciseSelection: Bool
    @State private var startTime = Date()
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0

    var body: some View {
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
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: workoutStore.currentWorkout) { newWorkout in
            if let newWorkout = newWorkout {
                workout = newWorkout
            }
        }
    }

    private var workoutHeader: some View {
        VStack(spacing: 8) {
            Text(workout.name)
                .font(.title)
                .fontWeight(.bold)

            Text("Duration: \(formatDuration(elapsedTime))")
                .font(.title3)
                .foregroundColor(.blue)
                .fontWeight(.medium)

            Text("\(workout.exercises.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
                    onUpdateSets: { updatedSets in
                        updateExerciseSets(exerciseIndex: index, sets: updatedSets)
                    }
                )
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { showingExerciseSelection = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Exercise")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }

            Button(action: finishWorkout) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Finish Workout")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
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
        guard exerciseIndex >= 0 && exerciseIndex < workout.exercises.count else { return }

        // Update local workout
        workout.exercises[exerciseIndex].sets = sets

        // Update workout store
        workoutStore.currentWorkout?.exercises[exerciseIndex].sets = sets
    }

    private func finishWorkout() {
        stopTimer()
        workoutStore.currentWorkout?.duration = elapsedTime

        // Get the completed workout before finishing it
        if let completedWorkout = workoutStore.currentWorkout {
            var finalWorkout = completedWorkout
            finalWorkout.date = Date()
            finalWorkout.duration = elapsedTime

            // Add to workout store
            workoutStore.finishCurrentWorkout()

            // Also update any ProgressData instances (this will update charts in real-time)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("WorkoutCompleted"), object: finalWorkout)
            }
        }
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
            List(WorkoutTemplateDatabase.templates) { template in
                Button(action: {
                    workoutStore.startWorkoutFromTemplate(template)
                    dismiss()
                }) {
                    WorkoutTemplateRowView(template: template)
                }
                .buttonStyle(PlainButtonStyle())
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

#Preview {
    WorkoutView()
        .environmentObject(WorkoutStore())
}