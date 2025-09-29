import SwiftUI

struct ProgressView: View {
    @StateObject private var progressData = ProgressData()

    var body: some View {
        NavigationView {
            VStack {
                if progressData.workoutHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No progress data yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Complete some workouts to see your progress!")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            statsOverviewSection
                            recentWorkoutsSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Progress")
        }
    }

    private var statsOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Month")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "Workouts",
                    value: "\(progressData.workoutsThisMonth)",
                    color: .blue
                )

                StatCard(
                    title: "Total Time",
                    value: progressData.totalTimeThisMonth,
                    color: .green
                )

                StatCard(
                    title: "Avg Duration",
                    value: progressData.averageDurationThisMonth,
                    color: .orange
                )

                StatCard(
                    title: "Total Sets",
                    value: "\(progressData.totalSetsThisMonth)",
                    color: .purple
                )
            }
        }
    }

    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Workouts")
                .font(.headline)

            LazyVStack {
                ForEach(progressData.workoutHistory.prefix(10)) { workout in
                    ProgressWorkoutRowView(workout: workout)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ProgressWorkoutRowView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                Spacer()
                Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("\(workout.exercises.count) exercises", systemImage: "dumbbell")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if workout.duration > 0 {
                    Label(formatDuration(workout.duration), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                ForEach(Array(Set(workout.exercises.flatMap { $0.muscleGroups })).prefix(3), id: \.self) { muscle in
                    Text(muscle)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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

class ProgressData: ObservableObject {
    @Published var workoutHistory: [Workout] = []

    init() {
        // Sample data for demonstration
        workoutHistory = [
            Workout(
                name: "Push Day",
                exercises: [
                    Exercise(name: "Bench Press", muscleGroups: ["Chest"], equipment: "Barbell"),
                    Exercise(name: "Overhead Press", muscleGroups: ["Shoulders"], equipment: "Barbell")
                ],
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                duration: 3600
            ),
            Workout(
                name: "Pull Day",
                exercises: [
                    Exercise(name: "Pull-ups", muscleGroups: ["Back"], equipment: "Bodyweight"),
                    Exercise(name: "Rows", muscleGroups: ["Back"], equipment: "Cable")
                ],
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                duration: 2700
            )
        ]
    }

    var workoutsThisMonth: Int {
        let thisMonth = Calendar.current.dateInterval(of: .month, for: Date())
        return workoutHistory.filter { workout in
            thisMonth?.contains(workout.date) ?? false
        }.count
    }

    var totalTimeThisMonth: String {
        let thisMonth = Calendar.current.dateInterval(of: .month, for: Date())
        let totalSeconds = workoutHistory
            .filter { thisMonth?.contains($0.date) ?? false }
            .reduce(0) { $0 + $1.duration }

        let hours = Int(totalSeconds) / 3600
        let minutes = Int(totalSeconds) % 3600 / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var averageDurationThisMonth: String {
        let thisMonthWorkouts = workoutHistory.filter { workout in
            let thisMonth = Calendar.current.dateInterval(of: .month, for: Date())
            return thisMonth?.contains(workout.date) ?? false
        }

        guard !thisMonthWorkouts.isEmpty else { return "0m" }

        let averageSeconds = thisMonthWorkouts.reduce(0) { $0 + $1.duration } / Double(thisMonthWorkouts.count)
        let minutes = Int(averageSeconds) / 60

        return "\(minutes)m"
    }

    var totalSetsThisMonth: Int {
        let thisMonth = Calendar.current.dateInterval(of: .month, for: Date())
        return workoutHistory
            .filter { thisMonth?.contains($0.date) ?? false }
            .flatMap { $0.exercises }
            .reduce(0) { $0 + $1.sets.count }
    }
}

#Preview {
    ProgressView()
}