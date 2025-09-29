import SwiftUI

struct SetLoggingView: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: ExerciseTemplate
    @State private var sets: [ExerciseSet] = []
    @State private var newReps = ""
    @State private var newWeight = ""
    @State private var restTime: Double = 60

    let onComplete: ([ExerciseSet]) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Exercise info
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Text(exercise.equipment)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)

                        Text(exercise.category.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(categoryColor(exercise.category).opacity(0.2))
                            .foregroundColor(categoryColor(exercise.category))
                            .cornerRadius(6)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // Add new set section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Set")
                        .font(.headline)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Reps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("12", text: $newReps)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading) {
                            Text("Weight (lbs)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("135", text: $newWeight)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Rest Time: \(Int(restTime)) seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Slider(value: $restTime, in: 30...300, step: 15)
                    }

                    Button("Add Set") {
                        addSet()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newReps.isEmpty || newWeight.isEmpty)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // Current sets
                if !sets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sets (\(sets.count))")
                            .font(.headline)

                        ForEach(Array(sets.enumerated()), id: \.offset) { index, set in
                            SetRowView(
                                setNumber: index + 1,
                                set: set,
                                onToggleComplete: {
                                    toggleSetCompletion(at: index)
                                },
                                onDelete: {
                                    deleteSet(at: index)
                                }
                            )
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Log Sets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onComplete(sets)
                        dismiss()
                    }
                    .disabled(sets.isEmpty)
                }
            }
        }
    }

    private func addSet() {
        guard let reps = Int(newReps), let weight = Double(newWeight) else { return }

        let newSet = ExerciseSet(
            reps: reps,
            weight: weight,
            restTime: restTime
        )

        sets.append(newSet)
        newReps = ""
        newWeight = ""
    }

    private func toggleSetCompletion(at index: Int) {
        sets[index].completed.toggle()
    }

    private func deleteSet(at index: Int) {
        sets.remove(at: index)
    }

    private func categoryColor(_ category: ExerciseCategory) -> Color {
        switch category {
        case .push:
            return .orange
        case .pull:
            return .blue
        case .legs:
            return .green
        case .core:
            return .purple
        case .cardio:
            return .red
        }
    }
}

struct SetRowView: View {
    let setNumber: Int
    let set: ExerciseSet
    let onToggleComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text("Set \(setNumber)")
                .font(.headline)
                .frame(width: 60, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(set.reps) reps")
                    .font(.subheadline)
                Text("\(Int(set.weight)) lbs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Rest: \(Int(set.restTime))s")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: onToggleComplete) {
                    Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(set.completed ? .green : .gray)
                        .font(.title3)
                }
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .background(set.completed ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    SetLoggingView(
        exercise: ExerciseTemplate(
            name: "Bench Press",
            muscleGroups: ["Chest", "Triceps"],
            equipment: "Barbell",
            category: .push
        )
    ) { sets in
        print("Completed with \(sets.count) sets")
    }
}