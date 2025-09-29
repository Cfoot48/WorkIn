import SwiftUI

struct NutritionView: View {
    @StateObject private var nutritionData = NutritionData()
    @State private var showingAddFood = false

    var body: some View {
        NavigationView {
            VStack {
                if let todayNutrition = nutritionData.getTodayNutrition() {
                    nutritionSummaryView(todayNutrition)

                    List {
                        ForEach(todayNutrition.entries) { entry in
                            FoodEntryRowView(entry: entry)
                        }
                        .onDelete(perform: deleteFoodEntries)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No nutrition data for today")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Tap '+' to add your first meal!")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nutrition")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddFood = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView { entry in
                    nutritionData.addFoodEntry(entry)
                }
            }
        }
    }

    private func nutritionSummaryView(_ nutrition: DailyNutrition) -> some View {
        VStack(spacing: 16) {
            HStack {
                NutritionCircle(
                    title: "Calories",
                    value: Int(nutrition.totalCalories),
                    color: .orange
                )

                NutritionCircle(
                    title: "Protein",
                    value: Int(nutrition.totalProtein),
                    unit: "g",
                    color: .red
                )

                NutritionCircle(
                    title: "Carbs",
                    value: Int(nutrition.totalCarbs),
                    unit: "g",
                    color: .blue
                )

                NutritionCircle(
                    title: "Fat",
                    value: Int(nutrition.totalFat),
                    unit: "g",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private func deleteFoodEntries(offsets: IndexSet) {
        guard let todayNutrition = nutritionData.getTodayNutrition() else { return }

        for index in offsets {
            if let entryIndex = nutritionData.dailyNutrition.firstIndex(where: { $0.id == todayNutrition.id }) {
                nutritionData.dailyNutrition[entryIndex].entries.remove(at: index)
            }
        }
    }
}

struct NutritionCircle: View {
    let title: String
    let value: Int
    let unit: String
    let color: Color

    init(title: String, value: Int, unit: String = "", color: Color) {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            if !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct FoodEntryRowView: View {
    let entry: FoodEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.name)
                .font(.headline)

            HStack {
                Text("\(Int(entry.calories)) cal")
                    .foregroundColor(.orange)
                Text("P: \(Int(entry.protein))g")
                    .foregroundColor(.red)
                Text("C: \(Int(entry.carbs))g")
                    .foregroundColor(.blue)
                Text("F: \(Int(entry.fat))g")
                    .foregroundColor(.yellow)
            }
            .font(.caption)
        }
        .padding(.vertical, 2)
    }
}

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    let onAdd: (FoodEntry) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Food Details") {
                    TextField("Food name", text: $name)
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)
                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                    TextField("Fat (g)", text: $fat)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addFood()
                    }
                    .disabled(name.isEmpty || calories.isEmpty)
                }
            }
        }
    }

    private func addFood() {
        let entry = FoodEntry(
            name: name,
            calories: Double(calories) ?? 0,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0
        )

        onAdd(entry)
        dismiss()
    }
}

class NutritionData: ObservableObject {
    @Published var dailyNutrition: [DailyNutrition] = []

    func getTodayNutrition() -> DailyNutrition? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyNutrition.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    func addFoodEntry(_ entry: FoodEntry) {
        let today = Calendar.current.startOfDay(for: Date())

        if let index = dailyNutrition.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyNutrition[index].entries.append(entry)
        } else {
            let newDayNutrition = DailyNutrition(date: today, entries: [entry])
            dailyNutrition.append(newDayNutrition)
        }
    }
}

#Preview {
    NutritionView()
}