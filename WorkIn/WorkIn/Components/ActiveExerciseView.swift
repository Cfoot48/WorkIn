import SwiftUI

struct ActiveExerciseView: View {
    let exercise: Exercise
    let exerciseIndex: Int
    @State private var isExpanded = true
    @State private var newReps = ""
    @State private var newWeight = ""
    @State private var restTime: Double = 60
    @State private var sets: [ExerciseSet]

    let onUpdateSets: ([ExerciseSet]) -> Void

    init(exercise: Exercise, exerciseIndex: Int, onUpdateSets: @escaping ([ExerciseSet]) -> Void) {
        self.exercise = exercise
        self.exerciseIndex = exerciseIndex
        self.onUpdateSets = onUpdateSets
        self._sets = State(initialValue: exercise.sets)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            exerciseHeaderView

            if isExpanded {
                expandedContentView
            }
        }
        .padding(.vertical, 8)
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
    }

    private var exerciseHeaderView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(exercise.muscleGroups.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { isExpanded.toggle() }) {
                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
    }

    private var expandedContentView: some View {
        VStack(spacing: 16) {
            if !sets.isEmpty {
                existingSetsView
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
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("12", text: $newReps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight (lbs)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("135", text: $newWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }

                Spacer()

                Button("Add Set") {
                    addSet()
                }
                .buttonStyle(.bordered)
                .disabled(newReps.isEmpty || newWeight.isEmpty)
            }

            restTimerView
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }

    private var restTimerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Rest Time: \(Int(restTime))s")
                .font(.caption)
                .foregroundColor(.secondary)
            Slider(value: $restTime, in: 30...300, step: 15)
                .accentColor(.blue)
        }
    }

    private func addSet() {
        guard let reps = Int(newReps), let weight = Double(newWeight) else { return }

        let newSet = ExerciseSet(
            reps: reps,
            weight: weight,
            restTime: restTime,
            completed: false
        )

        sets.append(newSet)
        newReps = ""
        newWeight = ""
    }

    private func toggleSetCompletion(at index: Int) {
        guard index >= 0 && index < sets.count else { return }
        var updatedSets = sets
        updatedSets[index].completed.toggle()
        sets = updatedSets
    }

    private func deleteSet(at index: Int) {
        guard index >= 0 && index < sets.count else { return }
        sets.remove(at: index)
    }
}

struct ActiveSetRowView: View {
    let set: ExerciseSet
    let setNumber: Int
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
                Text("\(set.reps) reps × \(Int(set.weight)) lbs")
                    .font(.subheadline)
                    .strikethrough(set.completed)
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