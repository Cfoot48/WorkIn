import SwiftUI

struct NutritionView: View {
    @StateObject private var nutritionStore = NutritionStore()
    @State private var showingAddFood = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    DailyNutritionSummaryView(nutritionStore: nutritionStore)

                    MealSectionsView(nutritionStore: nutritionStore)
                }
                .padding()
            }
            .navigationTitle("Nutrition")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFood = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView(nutritionStore: nutritionStore)
            }
        }
    }
}

struct DailyNutritionSummaryView: View {
    @ObservedObject var nutritionStore: NutritionStore

    var body: some View {
        let totals = nutritionStore.todaysTotals()
        let goals = nutritionStore.nutritionGoals

        VStack(spacing: 16) {
            Text("Today's Nutrition")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 20) {
                NutritionCircleView(
                    title: "Calories",
                    current: totals.calories,
                    goal: goals.dailyCalories,
                    color: .orange
                )

                NutritionCircleView(
                    title: "Protein",
                    current: totals.protein,
                    goal: goals.dailyProtein,
                    color: .red,
                    unit: "g"
                )

                NutritionCircleView(
                    title: "Carbs",
                    current: totals.carbs,
                    goal: goals.dailyCarbs,
                    color: .blue,
                    unit: "g"
                )

                NutritionCircleView(
                    title: "Fat",
                    current: totals.fat,
                    goal: goals.dailyFat,
                    color: .yellow,
                    unit: "g"
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct NutritionCircleView: View {
    let title: String
    let current: Double
    let goal: Double
    let color: Color
    let unit: String

    init(title: String, current: Double, goal: Double, color: Color, unit: String = "cal") {
        self.title = title
        self.current = current
        self.goal = goal
        self.color = color
        self.unit = unit
    }

    var progress: Double {
        min(current / goal, 1.0)
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 6)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)

                Text("\(Int(current))")
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            Text(title)
                .font(.caption2)
                .fontWeight(.medium)

            Text("\(Int(goal)) \(unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct MealSectionsView: View {
    @ObservedObject var nutritionStore: NutritionStore

    var body: some View {
        VStack(spacing: 16) {
            ForEach(MealType.allCases, id: \.self) { mealType in
                MealSectionView(
                    mealType: mealType,
                    entries: nutritionStore.todaysEntries().filter { $0.meal == mealType }
                )
            }
        }
    }
}

struct MealSectionView: View {
    let mealType: MealType
    let entries: [FoodEntry]

    var totalCalories: Double {
        entries.reduce(0) { $0 + $1.totalCalories }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(mealType.rawValue)
                    .font(.headline)
                Spacer()
                Text("\(Int(totalCalories)) cal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if entries.isEmpty {
                Text("No foods logged")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(entries) { entry in
                    FoodEntryRowView(entry: entry)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct FoodEntryRowView: View {
    let entry: FoodEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.food.name)
                    .font(.subheadline)
                Text("\(String(format: "%.1f", entry.servings)) servings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(Int(entry.totalCalories)) cal")
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var nutritionStore: NutritionStore
    @State private var selectedFood: Food?
    @State private var servings: String = "1.0"
    @State private var selectedMeal: MealType = .breakfast

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Picker("Meal", selection: $selectedMeal) {
                    ForEach(MealType.allCases, id: \.self) { meal in
                        Text(meal.rawValue).tag(meal)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List(nutritionStore.foods) { food in
                    Button(action: { selectedFood = food }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(food.name)
                                    .foregroundColor(.primary)
                                Text("\(Int(food.caloriesPerServing)) cal per \(food.servingSize)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedFood?.id == food.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                if selectedFood != nil {
                    VStack {
                        TextField("Servings", text: $servings)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)

                        Button("Add Food") {
                            addFood()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedFood == nil || servings.isEmpty)
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func addFood() {
        guard let food = selectedFood,
              let servingCount = Double(servings) else { return }

        let entry = FoodEntry(
            food: food,
            servings: servingCount,
            meal: selectedMeal
        )
        nutritionStore.addFoodEntry(entry)
        dismiss()
    }
}

#Preview {
    NutritionView()
}