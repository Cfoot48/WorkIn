import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var workoutStore: WorkoutStore
    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory? = nil
    @State private var showingTemplates = false

    var filteredExercises: [ExerciseTemplate] {
        var exercises = ExerciseDatabase.exercises

        if let category = selectedCategory {
            exercises = exercises.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            exercises = exercises.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(searchText) ||
                exercise.muscleGroups.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return exercises
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)

                categoryPicker

                toggleButtons

                if showingTemplates {
                    WorkoutTemplateListView(workoutStore: workoutStore)
                } else {
                    ExerciseListView(
                        exercises: filteredExercises,
                        workoutStore: workoutStore
                    )
                }
            }
            .navigationTitle(showingTemplates ? "Workout Templates" : "Exercise Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )

                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    private var toggleButtons: some View {
        HStack(spacing: 0) {
            Button(action: { showingTemplates = false }) {
                Text("Individual Exercises")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(showingTemplates ? .secondary : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(showingTemplates ? Color.clear : Color.blue.opacity(0.1))
            }

            Button(action: { showingTemplates = true }) {
                Text("Workout Templates")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(showingTemplates ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(showingTemplates ? Color.blue.opacity(0.1) : Color.clear)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(16)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search exercises...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct ExerciseListView: View {
    let exercises: [ExerciseTemplate]
    @ObservedObject var workoutStore: WorkoutStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(exercises) { exercise in
            Button(action: {
                let newExercise = exercise.toExercise()
                workoutStore.addExerciseToCurrentWorkout(newExercise)
                dismiss()
            }) {
                ExerciseRowView(exercise: exercise)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct ExerciseRowView: View {
    let exercise: ExerciseTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(exercise.equipment.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }

            Text(exercise.muscleGroups.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(exercise.category.rawValue)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

struct WorkoutTemplateListView: View {
    @ObservedObject var workoutStore: WorkoutStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(WorkoutTemplateDatabase.templates) { template in
            Button(action: {
                workoutStore.startWorkoutFromTemplate(template)
                dismiss()
            }) {
                WorkoutTemplateRowView(template: template)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct WorkoutTemplateRowView: View {
    let template: WorkoutTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(template.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(categoryColor.opacity(0.2))
                    .foregroundColor(categoryColor)
                    .cornerRadius(4)
            }

            Text(template.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Text("\(template.exercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(formatDuration(template.estimatedDuration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var categoryColor: Color {
        switch template.category {
        case "Push": return .red
        case "Pull": return .blue
        case "Legs": return .green
        case "Core": return .orange
        case "Full Body": return .purple
        default: return .gray
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

#Preview {
    ExerciseSelectionView(workoutStore: WorkoutStore())
}