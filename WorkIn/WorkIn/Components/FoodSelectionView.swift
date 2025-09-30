import SwiftUI

struct FoodSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var foodDatabase = FoodDatabase.shared

    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showingManualEntry = false
    @State private var selectedFood: FoodTemplate?
    @State private var servingMultiplier: Double = 1.0

    let onSelection: (FoodEntry) -> Void

    var body: some View {
        NavigationView {
            VStack {
                // Toggle between database search and manual entry
                Picker("Entry Mode", selection: $showingManualEntry) {
                    Text("Search Database").tag(false)
                    Text("Manual Entry").tag(true)
                }
                .pickerStyle(.segmented)
                .padding()

                if showingManualEntry {
                    manualEntryView
                } else {
                    foodSearchView
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
            }
            .sheet(item: $selectedFood) { food in
                FoodDetailView(food: food) { entry in
                    onSelection(entry)
                    dismiss()
                }
            }
        }
    }

    private var foodSearchView: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search foods...", text: $searchText)
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

                    ForEach(FoodCategory.allCases, id: \.self) { category in
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

            // Food list
            List(filteredFoods, id: \.id) { food in
                FoodRowView(food: food) {
                    selectedFood = food
                }
            }
        }
    }

    private var manualEntryView: some View {
        ManualFoodEntryView { entry in
            onSelection(entry)
            dismiss()
        }
    }

    private var filteredFoods: [FoodTemplate] {
        foodDatabase.searchFoods(query: searchText, category: selectedCategory)
    }
}

struct FoodRowView: View {
    let food: FoodTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(food.servingDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        NutritionBadge(value: Int(food.caloriesPerServing), label: "cal", color: .orange)
                        NutritionBadge(value: Int(food.proteinPerServing), label: "P", color: .red)
                        NutritionBadge(value: Int(food.carbsPerServing), label: "C", color: .blue)
                        NutritionBadge(value: Int(food.fatPerServing), label: "F", color: .yellow)
                    }

                    Text(food.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(categoryColor(food.category).opacity(0.2))
                        .foregroundColor(categoryColor(food.category))
                        .cornerRadius(6)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func categoryColor(_ category: FoodCategory) -> Color {
        switch category {
        case .proteins:
            return .red
        case .grains:
            return .orange
        case .vegetables:
            return .green
        case .fruits:
            return .pink
        case .dairy:
            return .blue
        case .nuts:
            return .brown
        case .beverages:
            return .cyan
        case .snacks:
            return .purple
        case .fastFood:
            return .gray
        }
    }
}

struct NutritionBadge: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text("\(value)")
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
        }
        .foregroundColor(color)
    }
}

struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let food: FoodTemplate
    @State private var servingMultiplier: Double = 1.0
    @State private var customServingSize: String = ""
    @State private var useCustomServing = false

    let onAdd: (FoodEntry) -> Void

    var finalCalories: Double {
        if useCustomServing, let customSize = Double(customServingSize) {
            return (food.caloriesPer100g * customSize) / 100
        }
        return food.caloriesPerServing * servingMultiplier
    }

    var finalProtein: Double {
        if useCustomServing, let customSize = Double(customServingSize) {
            return (food.proteinPer100g * customSize) / 100
        }
        return food.proteinPerServing * servingMultiplier
    }

    var finalCarbs: Double {
        if useCustomServing, let customSize = Double(customServingSize) {
            return (food.carbsPer100g * customSize) / 100
        }
        return food.carbsPerServing * servingMultiplier
    }

    var finalFat: Double {
        if useCustomServing, let customSize = Double(customServingSize) {
            return (food.fatPer100g * customSize) / 100
        }
        return food.fatPerServing * servingMultiplier
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Food info
                VStack(alignment: .leading, spacing: 8) {
                    Text(food.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(food.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor(food.category).opacity(0.2))
                        .foregroundColor(categoryColor(food.category))
                        .cornerRadius(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // Serving size selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Serving Size")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 12) {
                        // Standard serving
                        HStack {
                            Button(action: { useCustomServing = false }) {
                                HStack {
                                    Image(systemName: useCustomServing ? "circle" : "checkmark.circle.fill")
                                        .foregroundColor(useCustomServing ? .gray : .blue)
                                    VStack(alignment: .leading) {
                                        Text("Standard: \(food.servingDescription)")
                                            .font(.subheadline)
                                        Text("\(Int(food.servingSize))g")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                            Spacer()
                        }

                        if !useCustomServing {
                            HStack {
                                Text("Servings:")
                                Spacer()
                                HStack {
                                    Button("-") {
                                        if servingMultiplier > 0.25 {
                                            servingMultiplier -= 0.25
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(servingMultiplier <= 0.25)

                                    Text(String(format: "%.2f", servingMultiplier))
                                        .frame(width: 60)
                                        .font(.headline)

                                    Button("+") {
                                        servingMultiplier += 0.25
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }

                        // Custom serving
                        HStack {
                            Button(action: { useCustomServing = true }) {
                                HStack {
                                    Image(systemName: useCustomServing ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(useCustomServing ? .blue : .gray)
                                    Text("Custom amount (grams)")
                                        .font(.subheadline)
                                }
                            }
                            .buttonStyle(.plain)

                            Spacer()
                        }

                        if useCustomServing {
                            TextField("Enter grams", text: $customServingSize)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // Nutrition preview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Nutrition Information")
                        .font(.headline)

                    HStack {
                        NutritionPreviewCard(title: "Calories", value: Int(finalCalories), color: .orange)
                        NutritionPreviewCard(title: "Protein", value: Int(finalProtein), unit: "g", color: .red)
                        NutritionPreviewCard(title: "Carbs", value: Int(finalCarbs), unit: "g", color: .blue)
                        NutritionPreviewCard(title: "Fat", value: Int(finalFat), unit: "g", color: .yellow)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Spacer()
            }
            .padding()
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
                    .disabled(useCustomServing && customServingSize.isEmpty)
                }
            }
        }
    }

    private func addFood() {
        let entry = FoodEntry(
            name: food.name,
            calories: finalCalories,
            protein: finalProtein,
            carbs: finalCarbs,
            fat: finalFat
        )
        onAdd(entry)
        dismiss()
    }

    private func categoryColor(_ category: FoodCategory) -> Color {
        switch category {
        case .proteins:
            return .red
        case .grains:
            return .orange
        case .vegetables:
            return .green
        case .fruits:
            return .pink
        case .dairy:
            return .blue
        case .nuts:
            return .brown
        case .beverages:
            return .cyan
        case .snacks:
            return .purple
        case .fastFood:
            return .gray
        }
    }
}

struct NutritionPreviewCard: View {
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

struct ManualFoodEntryView: View {
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    let onAdd: (FoodEntry) -> Void

    var body: some View {
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

            Section {
                Button("Add Food") {
                    addFood()
                }
                .disabled(name.isEmpty || calories.isEmpty)
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
    }
}

extension FoodTemplate: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FoodTemplate, rhs: FoodTemplate) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    FoodSelectionView { entry in
        print("Added food: \(entry.name)")
    }
}