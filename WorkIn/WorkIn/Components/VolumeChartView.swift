import SwiftUI

struct VolumeChartView: View {
    let workouts: [Workout]

    var body: some View {
        let volumeData = getWeeklyVolumeData()
        let maxVolume = volumeData.map { $0.1 }.max() ?? 1

        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Total Volume (lbs)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(volumeData.last?.1 ?? 0)) lbs this week")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            // Line chart
            ZStack {
                // Background grid
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(.gray.opacity(0.3))
                        Spacer()
                    }
                }
                .frame(height: 120)

                // Line chart
                GeometryReader { geometry in
                    let chartWidth = geometry.size.width
                    let chartHeight: CGFloat = 120
                    let stepWidth = chartWidth / max(1, CGFloat(volumeData.count - 1))

                    // Draw line
                    Path { path in
                        for (index, data) in volumeData.enumerated() {
                            let x = CGFloat(index) * stepWidth
                            let y = chartHeight - (data.1 / maxVolume) * chartHeight

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.8), .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )

                    // Draw points
                    ForEach(Array(volumeData.enumerated()), id: \.offset) { index, data in
                        let x = CGFloat(index) * stepWidth
                        let y = chartHeight - (data.1 / maxVolume) * chartHeight

                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .frame(width: 8, height: 8)
                                    .position(x: x, y: y)
                            )
                    }
                }
                .frame(height: 120)
            }

            // Date labels
            HStack {
                ForEach(Array(volumeData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 2) {
                        if data.1 > 0 {
                            Text("\(Int(data.1 / 1000))k")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                        Text(data.0)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if index < volumeData.count - 1 {
                        Spacer()
                    }
                }
            }
        }
    }

    private func getWeeklyVolumeData() -> [(String, Double)] {
        let calendar = Calendar.current
        let now = Date()

        // Get last 7 weeks
        var weeklyData: [(String, Double)] = []

        for i in 0..<7 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: now),
                  let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else { continue }

            let weekWorkouts = workouts.filter { workout in
                workout.date >= weekStart && workout.date <= weekEnd
            }

            let weekVolume = weekWorkouts.reduce(0) { total, workout in
                total + getTotalVolumeForWorkout(workout)
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            let weekLabel = formatter.string(from: weekStart)

            weeklyData.append((weekLabel, weekVolume))
        }

        return weeklyData.reversed()
    }

    private func getTotalVolumeForWorkout(_ workout: Workout) -> Double {
        return workout.exercises.reduce(0) { workoutTotal, exercise in
            workoutTotal + exercise.sets.reduce(0) { setTotal, set in
                setTotal + (Double(set.reps) * set.weight)
            }
        }
    }
}

struct ExerciseProgressRowView: View {
    let exerciseName: String
    let workouts: [Workout]

    var body: some View {
        let progressData = getExerciseProgressData()
        let latestData = progressData.last
        let previousData = progressData.dropLast().last

        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exerciseName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 16) {
                    // Max weight
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Max: \(Int(latestData?.maxWeight ?? 0)) lbs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Volume
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("Vol: \(Int(latestData?.totalVolume ?? 0)) lbs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Progress indicator
            VStack(alignment: .trailing, spacing: 2) {
                if let latest = latestData, let previous = previousData {
                    let weightChange = latest.maxWeight - previous.maxWeight
                    let volumeChange = latest.totalVolume - previous.totalVolume

                    if weightChange > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.up.right")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text("+\(Int(weightChange)) lbs")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    } else if weightChange < 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.down.right")
                                .font(.caption2)
                                .foregroundColor(.red)
                            Text("\(Int(weightChange)) lbs")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    } else {
                        HStack(spacing: 2) {
                            Image(systemName: "minus")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text("Same")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }

                    Text("\(progressData.count) sessions")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }

    private func getExerciseProgressData() -> [ExerciseDataPoint] {
        let exerciseWorkouts = workouts
            .compactMap { workout -> (Date, Exercise)? in
                guard let exercise = workout.exercises.first(where: { $0.name == exerciseName }) else { return nil }
                return (workout.date, exercise)
            }
            .sorted { $0.0 < $1.0 }

        return exerciseWorkouts.compactMap { date, exercise in
            guard !exercise.sets.isEmpty else { return nil }

            let maxWeight = exercise.sets.map { $0.weight }.max() ?? 0
            let totalVolume = exercise.sets.reduce(0) { $0 + (Double($1.reps) * $1.weight) }

            return ExerciseDataPoint(
                date: date,
                maxWeight: maxWeight,
                totalVolume: totalVolume
            )
        }
    }
}

struct ExerciseDataPoint {
    let date: Date
    let maxWeight: Double
    let totalVolume: Double
}

struct CaloriesChartView: View {
    let nutritionData: [DailyNutrition]

    var body: some View {
        let caloriesData = getDailyCaloriesData()
        let maxCalories = caloriesData.map { $0.1 }.max() ?? 1

        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Calories")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(caloriesData.last?.1 ?? 0)) cal today")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }

            // Line chart
            ZStack {
                // Background grid
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(.gray.opacity(0.3))
                        Spacer()
                    }
                }
                .frame(height: 120)

                // Line chart
                GeometryReader { geometry in
                    let chartWidth = geometry.size.width
                    let chartHeight: CGFloat = 120
                    let stepWidth = chartWidth / max(1, CGFloat(caloriesData.count - 1))

                    // Draw line
                    Path { path in
                        for (index, data) in caloriesData.enumerated() {
                            let x = CGFloat(index) * stepWidth
                            let y = chartHeight - (data.1 / maxCalories) * chartHeight

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange.opacity(0.8), .orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )

                    // Draw points
                    ForEach(Array(caloriesData.enumerated()), id: \.offset) { index, data in
                        let x = CGFloat(index) * stepWidth
                        let y = chartHeight - (data.1 / maxCalories) * chartHeight

                        Circle()
                            .fill(.orange)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .frame(width: 8, height: 8)
                                    .position(x: x, y: y)
                            )
                    }
                }
                .frame(height: 120)
            }

            // Date labels
            HStack {
                ForEach(Array(caloriesData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 2) {
                        if data.1 > 0 {
                            Text("\(Int(data.1))")
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .fontWeight(.semibold)
                        }
                        Text(data.0)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if index < caloriesData.count - 1 {
                        Spacer()
                    }
                }
            }
        }
    }

    private func getDailyCaloriesData() -> [(String, Double)] {
        let calendar = Calendar.current
        let now = Date()

        // Get last 7 days
        var dailyData: [(String, Double)] = []

        for i in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: -i, to: now) else { continue }

            let dayCalories = nutritionData
                .filter { calendar.isDate($0.date, inSameDayAs: dayDate) }
                .reduce(0) { total, nutrition in
                    total + nutrition.totalCalories
                }

            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            let dayLabel = formatter.string(from: dayDate)

            dailyData.append((dayLabel, dayCalories))
        }

        return dailyData.reversed()
    }
}

#Preview {
    VStack {
        VolumeChartView(workouts: [])
            .frame(height: 200)
            .padding()

        ExerciseProgressRowView(exerciseName: "Bench Press", workouts: [])
            .padding()
    }
}