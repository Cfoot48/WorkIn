import SwiftUI

struct SetLoggingView: View {
    @Binding var exercise: Exercise
    @State private var newSetReps = ""
    @State private var newSetWeight = ""
    @State private var showingSetInput = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            exerciseHeader

            setsSection

            addSetButton
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .sheet(isPresented: $showingSetInput) {
            SetInputView(
                exercise: $exercise,
                reps: $newSetReps,
                weight: $newSetWeight
            )
        }
    }

    private var exerciseHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.headline)
                .fontWeight(.bold)

            Text(exercise.muscleGroups.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var setsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if exercise.sets.isEmpty {
                Text("No sets logged yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                Text("Sets")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                ForEach(Array(exercise.sets.enumerated()), id: \.offset) { index, set in
                    SetRowView(
                        setNumber: index + 1,
                        set: set,
                        onDelete: { deleteSet(at: index) }
                    )
                }
            }
        }
    }

    private var addSetButton: some View {
        Button(action: { showingSetInput = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Set")
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue)
        }
    }

    private func deleteSet(at index: Int) {
        exercise.sets.remove(at: index)
    }
}

struct SetRowView: View {
    let setNumber: Int
    let set: ExerciseSet
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text("Set \(setNumber)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)

            Text("\(set.reps) reps")
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)

            Text("\(Int(set.weight)) lbs")
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct SetInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var exercise: Exercise
    @Binding var reps: String
    @Binding var weight: String
    @State private var restTime = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Add Set to \(exercise.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    InputField(
                        title: "Reps",
                        text: $reps,
                        placeholder: "Enter number of reps",
                        keyboardType: .numberPad
                    )

                    InputField(
                        title: "Weight (lbs)",
                        text: $weight,
                        placeholder: "Enter weight",
                        keyboardType: .decimalPad
                    )

                    InputField(
                        title: "Rest Time (optional)",
                        text: $restTime,
                        placeholder: "Rest time in seconds",
                        keyboardType: .numberPad
                    )
                }

                Button(action: addSet) {
                    Text("Add Set")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canAddSet ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!canAddSet)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var canAddSet: Bool {
        !reps.isEmpty && !weight.isEmpty &&
        Int(reps) != nil && Double(weight) != nil
    }

    private func addSet() {
        guard let repsInt = Int(reps),
              let weightDouble = Double(weight) else { return }

        let restTimeValue = Double(Int(restTime) ?? 60)
        let newSet = ExerciseSet(
            reps: repsInt,
            weight: weightDouble,
            restTime: restTimeValue
        )

        exercise.sets.append(newSet)
        reps = ""
        weight = ""
        restTime = ""
        dismiss()
    }
}

struct InputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .fontWeight(.medium)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
        }
    }
}

#Preview {
    SetLoggingView(exercise: .constant(Exercise(
        name: "Bench Press",
        sets: [
            ExerciseSet(reps: 10, weight: 135),
            ExerciseSet(reps: 8, weight: 155)
        ],
        muscleGroups: ["Chest", "Triceps"]
    )))
}