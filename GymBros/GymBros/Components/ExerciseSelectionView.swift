import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var exerciseDatabase = ExerciseDatabase.shared
    @StateObject private var workoutTemplates = WorkoutTemplates.shared

    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory? = nil
    @State private var selectedExercises: Set<ExerciseTemplate> = []
    @State private var showingTemplates = false
    @State private var selectedTemplateCategory = "All"

    let onSelection: ([ExerciseTemplate]) -> Void

    var body: some View {
        NavigationView {
            VStack {
                // Toggle between individual exercises and templates
                Picker("Selection Mode", selection: $showingTemplates) {
                    Text("Individual Exercises").tag(false)
                    Text("Workout Templates").tag(true)
                }
                .pickerStyle(.segmented)
                .padding()

                if showingTemplates {
                    templateSelectionView
                } else {
                    exerciseSelectionView
                }
            }
            .navigationTitle("Select Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start Workout") {
                        startWorkout()
                    }
                    .disabled(selectedExercises.isEmpty)
                }
            }
        }
    }

    private var exerciseSelectionView: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search exercises...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: { selectedCategory = nil }) {
                        Text("All")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedCategory == nil ? .white : .primary)
                            .cornerRadius(20)
                    }

                    ForEach(ExerciseCategory.allCases, id: \.self) { category in
                        Button(action: { selectedCategory = category }) {
                            Text(category.rawValue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Exercise list
            List(filteredExercises, id: \.name) { exercise in
                ExerciseRowView(
                    exercise: exercise,
                    isSelected: selectedExercises.contains(exercise)
                ) {
                    toggleExerciseSelection(exercise)
                }
            }

            // Selected count
            if !selectedExercises.isEmpty {
                Text("\(selectedExercises.count) exercise(s) selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }

    private var templateSelectionView: some View {
        VStack {
            // Template category picker
            Picker("Category", selection: $selectedTemplateCategory) {
                ForEach(workoutTemplates.getAllCategories(), id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)

            // Template list
            List(workoutTemplates.getTemplatesByCategory(selectedTemplateCategory), id: \.name) { template in
                TemplateRowView(template: template) {
                    selectTemplate(template)
                }
            }
        }
    }

    private var filteredExercises: [ExerciseTemplate] {
        exerciseDatabase.searchExercises(query: searchText, category: selectedCategory)
    }

    private func toggleExerciseSelection(_ exercise: ExerciseTemplate) {
        if selectedExercises.contains(exercise) {
            selectedExercises.remove(exercise)
        } else {
            selectedExercises.insert(exercise)
        }
    }

    private func selectTemplate(_ template: WorkoutTemplate) {
        selectedExercises = Set(template.exercises)
    }

    private func startWorkout() {
        onSelection(Array(selectedExercises))
        dismiss()
    }
}

struct ExerciseRowView: View {
    let exercise: ExerciseTemplate
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Text(exercise.equipment)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)

                        Text(exercise.category.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(categoryColor(exercise.category).opacity(0.2))
                            .foregroundColor(categoryColor(exercise.category))
                            .cornerRadius(6)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                    .font(.title2)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
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

struct TemplateRowView: View {
    let template: WorkoutTemplate
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(template.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor(template.category).opacity(0.2))
                        .foregroundColor(categoryColor(template.category))
                        .cornerRadius(8)
                }

                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Text("\(template.exercises.count) exercises")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    HStack(spacing: 4) {
                        ForEach(Array(Set(template.exercises.map { $0.category.rawValue })).prefix(3), id: \.self) { category in
                            Text(category)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "Push":
            return .orange
        case "Pull":
            return .blue
        case "Legs":
            return .green
        case "Core":
            return .purple
        case "Full Body":
            return .indigo
        default:
            return .gray
        }
    }
}

extension ExerciseTemplate: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ExerciseTemplate, rhs: ExerciseTemplate) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    ExerciseSelectionView { exercises in
        print("Selected \(exercises.count) exercises")
    }
}