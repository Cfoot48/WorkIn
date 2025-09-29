import SwiftUI
import Charts

struct ProgressView: View {
    @State private var selectedTimeframe: Timeframe = .week

    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    timeframePicker

                    WeightProgressView()

                    WorkoutStatsView()

                    NutritionStatsView()
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }

    private var timeframePicker: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct WeightProgressView: View {
    @State private var weightEntries = WeightEntry.sampleData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight Progress")
                .font(.headline)

            if #available(iOS 16.0, *) {
                Chart(weightEntries) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 200)
            } else {
                VStack {
                    HStack {
                        Text("Current: \(String(format: "%.1f", weightEntries.last?.weight ?? 0)) lbs")
                        Spacer()
                        Text("Goal: 180 lbs")
                    }
                    .font(.subheadline)

                    Rectangle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(height: 100)
                        .overlay(
                            Text("Weight Chart\n(iOS 16+ required)")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct WorkoutStatsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Stats")
                .font(.headline)

            HStack(spacing: 16) {
                StatCard(title: "This Week", value: "4", subtitle: "workouts")
                StatCard(title: "Total Time", value: "6.5", subtitle: "hours")
                StatCard(title: "Avg Duration", value: "97", subtitle: "minutes")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct NutritionStatsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition Stats")
                .font(.headline)

            HStack(spacing: 16) {
                StatCard(title: "Avg Calories", value: "2,150", subtitle: "per day")
                StatCard(title: "Protein", value: "145g", subtitle: "average")
                StatCard(title: "Streak", value: "7", subtitle: "days")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct WeightEntry: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double

    static var sampleData: [WeightEntry] {
        let calendar = Calendar.current
        return [
            WeightEntry(date: calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date(), weight: 185.2),
            WeightEntry(date: calendar.date(byAdding: .day, value: -25, to: Date()) ?? Date(), weight: 184.8),
            WeightEntry(date: calendar.date(byAdding: .day, value: -20, to: Date()) ?? Date(), weight: 183.5),
            WeightEntry(date: calendar.date(byAdding: .day, value: -15, to: Date()) ?? Date(), weight: 182.9),
            WeightEntry(date: calendar.date(byAdding: .day, value: -10, to: Date()) ?? Date(), weight: 182.1),
            WeightEntry(date: calendar.date(byAdding: .day, value: -5, to: Date()) ?? Date(), weight: 181.6),
            WeightEntry(date: Date(), weight: 181.2)
        ]
    }
}

#Preview {
    ProgressView()
}