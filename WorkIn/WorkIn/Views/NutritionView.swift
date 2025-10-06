import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var templateStore: TemplateStore
    @EnvironmentObject var profileStore: UserProfileStore
    @State private var showingAddFood = false
    @State private var showingBarcodeScanner = false
    @State private var showingScannedFood = false
    @State private var scannedFoodData: ScannedFoodData?
    @State private var isLoadingBarcode = false
    @State private var barcodeError: String?
    @State private var showBarcodeError = false
    @State private var showingAIMealGenerator = false

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
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: { showingAIMealGenerator = true }) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                    }

                    Button(action: { showingBarcodeScanner = true }) {
                        Image(systemName: "barcode.viewfinder")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFood = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                FoodSelectionView { foodEntry in
                    nutritionStore.addFoodEntry(foodEntry)
                }
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView { barcode in
                    handleScannedBarcode(barcode)
                }
            }
            .sheet(isPresented: $showingScannedFood) {
                if let foodData = scannedFoodData {
                    ScannedFoodDetailView(scannedFood: foodData) { foodEntry in
                        nutritionStore.addFoodEntry(foodEntry)
                    }
                }
            }
            .sheet(isPresented: $showingAIMealGenerator) {
                AIMealGeneratorView()
                    .environmentObject(templateStore)
                    .environmentObject(profileStore)
                    .environmentObject(nutritionStore)
            }
            .alert("Barcode Error", isPresented: $showBarcodeError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(barcodeError ?? "Unknown error")
            }
            .overlay {
                if isLoadingBarcode {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)

                            Text("Looking up product...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(32)
                        .background(Color.gray.opacity(0.9))
                        .cornerRadius(16)
                    }
                }
            }
        }
    }

    private func handleScannedBarcode(_ barcode: String) {
        isLoadingBarcode = true
        print("📷 Scanned barcode: \(barcode)")

        Task {
            do {
                let foodData = try await BarcodeNutritionService.shared.fetchNutritionData(barcode: barcode)
                print("✅ Successfully fetched food data: \(foodData.name)")
                await MainActor.run {
                    isLoadingBarcode = false
                    scannedFoodData = foodData
                    showingScannedFood = true
                }
            } catch let error as BarcodeError {
                print("❌ BarcodeError: \(error.localizedDescription ?? "Unknown")")
                await MainActor.run {
                    isLoadingBarcode = false
                    barcodeError = error.localizedDescription
                    showBarcodeError = true
                }
            } catch {
                print("❌ Unexpected error: \(error.localizedDescription)")
                print("❌ Error details: \(error)")
                await MainActor.run {
                    isLoadingBarcode = false
                    barcodeError = "Error: \(error.localizedDescription)\n\nBarcode: \(barcode)"
                    showBarcodeError = true
                }
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
                    entries: todaysEntries(for: mealType),
                    nutritionStore: nutritionStore
                )
            }
        }
    }

    private func todaysEntries(for mealType: MealType) -> [FoodEntry] {
        guard let todayNutrition = nutritionStore.getTodayNutrition() else { return [] }
        return todayNutrition.entries.filter { entry in
            entry.mealType == mealType
        }
    }
}

struct MealSectionView: View {
    let mealType: MealType
    let entries: [FoodEntry]
    let nutritionStore: NutritionStore

    @State private var editingEntry: FoodEntry?
    @State private var showingEditSheet = false

    var totalCalories: Double {
        entries.reduce(0) { $0 + $1.calories }
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) {
                                nutritionStore.deleteFoodEntry(entry)
                            }
                        }
                        .contextMenu {
                            Button("Edit") {
                                editingEntry = entry
                                showingEditSheet = true
                            }
                            Button("Delete", role: .destructive) {
                                nutritionStore.deleteFoodEntry(entry)
                            }
                        }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .sheet(isPresented: $showingEditSheet) {
            if let entry = editingEntry {
                EditFoodEntryView(
                    entry: entry,
                    nutritionStore: nutritionStore
                ) {
                    showingEditSheet = false
                    editingEntry = nil
                }
            }
        }
    }
}

struct FoodEntryRowView: View {
    let entry: FoodEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline)
                Text("\(Int(entry.protein))p | \(Int(entry.carbs))c | \(Int(entry.fat))f")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(Int(entry.calories)) cal")
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
            name: food.name,
            calories: food.caloriesPerServing * servingCount,
            protein: food.proteinPerServing * servingCount,
            carbs: food.carbsPerServing * servingCount,
            fat: food.fatPerServing * servingCount
        )
        nutritionStore.addFoodEntry(entry)
        dismiss()
    }
}

struct EditFoodEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let originalEntry: FoodEntry
    let nutritionStore: NutritionStore
    let onSave: () -> Void

    @State private var name: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var mealType: MealType

    init(entry: FoodEntry, nutritionStore: NutritionStore, onSave: @escaping () -> Void) {
        self.originalEntry = entry
        self.nutritionStore = nutritionStore
        self.onSave = onSave

        _name = State(initialValue: entry.name)
        _calories = State(initialValue: String(format: "%.0f", entry.calories))
        _protein = State(initialValue: String(format: "%.1f", entry.protein))
        _carbs = State(initialValue: String(format: "%.1f", entry.carbs))
        _fat = State(initialValue: String(format: "%.1f", entry.fat))
        _mealType = State(initialValue: entry.mealType)
    }

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

                Section("Meal Type") {
                    Picker("Meal Type", selection: $mealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Text(mealType.rawValue).tag(mealType)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Edit Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || calories.isEmpty)
                }
            }
        }
    }

    private func saveChanges() {
        // Create updated entry with safe limits
        let updatedEntry = FoodEntry(
            name: name,
            calories: min(max(Double(calories) ?? 0, 0), 99999),
            protein: min(max(Double(protein) ?? 0, 0), 9999),
            carbs: min(max(Double(carbs) ?? 0, 0), 9999),
            fat: min(max(Double(fat) ?? 0, 0), 9999),
            mealType: mealType
        )

        // Update the entry
        nutritionStore.updateFoodEntry(originalEntry, with: updatedEntry)

        onSave()
        dismiss()
    }
}

#Preview {
    NutritionView()
        .environmentObject(NutritionStore())
        .environmentObject(ThemeManager())
}