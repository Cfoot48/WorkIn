import Foundation

struct Food: Identifiable, Codable {
    let id: UUID
    var name: String
    var caloriesPerServing: Double
    var proteinPerServing: Double
    var carbsPerServing: Double
    var fatPerServing: Double
    var servingSize: String

    init(name: String, caloriesPerServing: Double, proteinPerServing: Double, carbsPerServing: Double, fatPerServing: Double, servingSize: String) {
        self.id = UUID()
        self.name = name
        self.caloriesPerServing = caloriesPerServing
        self.proteinPerServing = proteinPerServing
        self.carbsPerServing = carbsPerServing
        self.fatPerServing = fatPerServing
        self.servingSize = servingSize
    }
}

struct FoodEntry: Identifiable, Codable {
    let id: UUID
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var mealType: MealType

    init(id: UUID = UUID(), name: String, calories: Double, protein: Double, carbs: Double, fat: Double, mealType: MealType = .breakfast) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.mealType = mealType
    }
}

struct DailyNutrition: Identifiable, Codable {
    let id: UUID
    var date: Date
    var entries: [FoodEntry]

    var totalCalories: Double {
        entries.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        entries.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.carbs }
    }

    var totalFat: Double {
        entries.reduce(0) { $0 + $1.fat }
    }

    init(id: UUID = UUID(), date: Date = Date(), entries: [FoodEntry] = []) {
        self.id = id
        self.date = date
        self.entries = entries
    }
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}

struct NutritionGoals: Codable {
    var dailyCalories: Double
    var dailyProtein: Double
    var dailyCarbs: Double
    var dailyFat: Double

    init(calories: Double = 2000, protein: Double = 150, carbs: Double = 250, fat: Double = 65) {
        self.dailyCalories = calories
        self.dailyProtein = protein
        self.dailyCarbs = carbs
        self.dailyFat = fat
    }
}

class NutritionStore: ObservableObject {
    @Published var dailyNutrition: [DailyNutrition] = []
    @Published var nutritionGoals = NutritionGoals()
    @Published var foods: [Food] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firestoreManager = FirestoreManager()

    init() {
        print("🔥 NutritionStore: Initializing...")
        loadSampleFoods()
        // Load initial goals from UserDefaults
        loadNutritionGoalsFromUserDefaults()
        // Don't set up Firebase listeners immediately - wait for authentication
    }

    func loadNutritionGoalsFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            nutritionGoals.dailyCalories = Double(profile.dailyCalories)
            nutritionGoals.dailyProtein = Double(profile.dailyProtein)
            print("🔥 NutritionStore: Loaded goals from UserDefaults - Calories: \(nutritionGoals.dailyCalories), Protein: \(nutritionGoals.dailyProtein)")
        }
    }

    func syncNutritionGoalsFromProfile() {
        loadNutritionGoalsFromUserDefaults()
    }

    // MARK: - Firebase Integration
    func startFirebaseListeners() {
        setupFirestoreListeners()
    }

    private func setupFirestoreListeners() {
        print("🔥 NutritionStore: Setting up Firestore listeners...")
        firestoreManager.listenToNutrition { [weak self] (nutrition: [DailyNutrition]) in
            print("🔥 NutritionStore: Received \(nutrition.count) nutrition entries from Firestore")
            DispatchQueue.main.async {
                self?.dailyNutrition = nutrition
                self?.isLoading = false
            }
        }
    }

    func addFoodEntry(_ entry: FoodEntry, to date: Date = Date()) {
        print("🔥 NutritionStore: Adding food entry '\(entry.name)' to meal '\(entry.mealType.rawValue)'")
        let calendar = Calendar.current

        if let index = dailyNutrition.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            dailyNutrition[index].entries.append(entry)
            // Save updated nutrition to Firebase
            Task {
                await saveDailyNutrition(dailyNutrition[index])
            }
        } else {
            let newDailyNutrition = DailyNutrition(date: date, entries: [entry])
            dailyNutrition.append(newDailyNutrition)
            // Save new nutrition to Firebase
            Task {
                await saveDailyNutrition(newDailyNutrition)
            }
        }
    }

    func deleteFoodEntry(_ entry: FoodEntry, from date: Date = Date()) {
        print("🔥 NutritionStore: Deleting food entry '\(entry.name)' from meal '\(entry.mealType.rawValue)'")
        let calendar = Calendar.current

        if let dayIndex = dailyNutrition.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            dailyNutrition[dayIndex].entries.removeAll { $0.id == entry.id }

            // Save updated nutrition to Firebase
            Task {
                await saveDailyNutrition(dailyNutrition[dayIndex])
            }
        }
    }

    func updateFoodEntry(_ originalEntry: FoodEntry, with updatedEntry: FoodEntry, on date: Date = Date()) {
        print("🔥 NutritionStore: Updating food entry '\(originalEntry.name)' to '\(updatedEntry.name)'")
        let calendar = Calendar.current

        if let dayIndex = dailyNutrition.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }),
           let entryIndex = dailyNutrition[dayIndex].entries.firstIndex(where: { $0.id == originalEntry.id }) {

            // Update the entry in place, preserving the original ID
            var updated = updatedEntry
            updated = FoodEntry(
                id: originalEntry.id,
                name: updatedEntry.name,
                calories: updatedEntry.calories,
                protein: updatedEntry.protein,
                carbs: updatedEntry.carbs,
                fat: updatedEntry.fat,
                mealType: updatedEntry.mealType
            )

            dailyNutrition[dayIndex].entries[entryIndex] = updated

            // Save updated nutrition to Firebase
            Task {
                await saveDailyNutrition(dailyNutrition[dayIndex])
            }
        }
    }

    func saveDailyNutrition(_ nutrition: DailyNutrition) async {
        print("🔥 NutritionStore: Attempting to save nutrition for date \(nutrition.date)")
        do {
            try await firestoreManager.saveDailyNutrition(nutrition)
            print("🔥 NutritionStore: Successfully saved nutrition for \(nutrition.date) to Firestore")
        } catch {
            print("🔥 NutritionStore: Failed to save nutrition: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Failed to save nutrition: \(error.localizedDescription)"
            }
        }
    }

    func getTodayNutrition() -> DailyNutrition? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyNutrition.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    func todaysTotals() -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        guard let todayNutrition = getTodayNutrition() else {
            return (0, 0, 0, 0)
        }
        return (todayNutrition.totalCalories, todayNutrition.totalProtein, todayNutrition.totalCarbs, todayNutrition.totalFat)
    }

    private func loadSampleFoods() {
        // Only load sample foods if foods array is empty
        guard foods.isEmpty else { return }

        foods = [
            Food(name: "Chicken Breast", caloriesPerServing: 231, proteinPerServing: 43.5, carbsPerServing: 0, fatPerServing: 5, servingSize: "100g"),
            Food(name: "Brown Rice", caloriesPerServing: 111, proteinPerServing: 2.6, carbsPerServing: 23, fatPerServing: 0.9, servingSize: "100g"),
            Food(name: "Broccoli", caloriesPerServing: 34, proteinPerServing: 2.8, carbsPerServing: 7, fatPerServing: 0.4, servingSize: "100g"),
            Food(name: "Banana", caloriesPerServing: 89, proteinPerServing: 1.1, carbsPerServing: 23, fatPerServing: 0.3, servingSize: "1 medium"),
            Food(name: "Greek Yogurt", caloriesPerServing: 59, proteinPerServing: 10, carbsPerServing: 3.6, fatPerServing: 0.4, servingSize: "100g"),
            Food(name: "Oatmeal", caloriesPerServing: 154, proteinPerServing: 5.3, carbsPerServing: 28, fatPerServing: 2.5, servingSize: "1 cup"),
            Food(name: "Salmon", caloriesPerServing: 208, proteinPerServing: 25.4, carbsPerServing: 0, fatPerServing: 12.4, servingSize: "100g"),
            Food(name: "Apple", caloriesPerServing: 95, proteinPerServing: 0.5, carbsPerServing: 25, fatPerServing: 0.3, servingSize: "1 medium")
        ]
    }

    deinit {
        firestoreManager.removeAllListeners()
    }
}

// MARK: - Barcode Nutrition Service

// Service to fetch nutrition data from barcode
class BarcodeNutritionService {

    static let shared = BarcodeNutritionService()

    private init() {}

    // Fetch nutrition data from Open Food Facts API
    func fetchNutritionData(barcode: String) async throws -> ScannedFoodData {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json"

        print("🌐 Fetching nutrition data for barcode: \(barcode)")
        print("🌐 URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            throw BarcodeError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        print("📥 Received response")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Not an HTTP response")
            throw BarcodeError.serverError
        }

        print("📊 HTTP Status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            print("❌ Server error: \(httpResponse.statusCode)")
            throw BarcodeError.serverError
        }

        let decoder = JSONDecoder()

        do {
            let productResponse = try decoder.decode(OpenFoodFactsResponse.self, from: data)
            print("✅ Successfully decoded response, status: \(productResponse.status)")

            guard productResponse.status == 1,
                  let product = productResponse.product else {
                print("❌ Product not found or status != 1")
                throw BarcodeError.productNotFound
            }

            print("✅ Product found: \(product.productName ?? "Unknown")")

            // Get nutrition data with fallbacks
            let nutriments = product.nutriments
            let calories = nutriments?.bestCalories ?? nutriments?.energyKcal100g ?? 0
            let protein = nutriments?.bestProtein ?? nutriments?.proteins100g ?? 0
            let carbs = nutriments?.bestCarbs ?? nutriments?.carbohydrates100g ?? 0
            let fat = nutriments?.fat100g ?? 0

            print("📊 Nutrition data - Cal: \(calories), P: \(protein), C: \(carbs), F: \(fat)")

            // Choose best available image
            let imageURL = product.imageFrontUrl ?? product.imageFrontSmallUrl ?? product.imageUrl

            // If no nutrition data at all, still allow the product but warn
            if calories == 0 && protein == 0 && carbs == 0 && fat == 0 {
                print("⚠️ Warning: No nutrition data available for this product")
            }

            return ScannedFoodData(
                barcode: barcode,
                name: product.productName ?? "Unknown Product",
                brand: product.brands ?? "",
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                servingSize: product.servingQuantity ?? 100,
                servingUnit: product.servingQuantityUnit ?? "g",
                imageURL: imageURL
            )
        } catch let decodingError as DecodingError {
            print("❌ Decoding error: \(decodingError)")

            // Print detailed error info
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("❌ Missing key: \(key.stringValue) - \(context.debugDescription)")
                print("❌ Coding path: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("❌ Type mismatch for type: \(type) - \(context.debugDescription)")
                print("❌ Coding path: \(context.codingPath)")
            case .valueNotFound(let type, let context):
                print("❌ Value not found for type: \(type) - \(context.debugDescription)")
                print("❌ Coding path: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("❌ Data corrupted: \(context.debugDescription)")
                print("❌ Coding path: \(context.codingPath)")
            @unknown default:
                print("❌ Unknown decoding error")
            }

            // Print the raw JSON for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw JSON (first 1000 chars): \(jsonString.prefix(1000))")
            }
            throw BarcodeError.decodingError
        }
    }
}

// Scanned food data model
struct ScannedFoodData {
    let barcode: String
    let name: String
    let brand: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let servingSize: Double
    let servingUnit: String
    let imageURL: String?

    // Convert to FoodEntry
    func toFoodEntry(servings: Double = 1, mealType: MealType = .breakfast) -> FoodEntry {
        let multiplier = servings
        return FoodEntry(
            name: brand.isEmpty ? name : "\(brand) - \(name)",
            calories: calories * multiplier,
            protein: protein * multiplier,
            carbs: carbs * multiplier,
            fat: fat * multiplier,
            mealType: mealType
        )
    }
}

// Error types
enum BarcodeError: LocalizedError {
    case invalidURL
    case serverError
    case productNotFound
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid barcode format"
        case .serverError:
            return "Server error - please try again"
        case .productNotFound:
            return "Product not found in database. Try searching manually or scanning a different barcode."
        case .decodingError:
            return "Could not read product data"
        }
    }
}

// Open Food Facts API response models
struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: OpenFoodProduct?
}

struct OpenFoodProduct: Codable {
    let productName: String?
    let brands: String?
    let nutriments: Nutriments?
    let servingQuantity: Double?
    let servingQuantityUnit: String?
    let imageFrontUrl: String?
    let imageFrontSmallUrl: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case nutriments
        case servingQuantity = "serving_quantity"
        case servingQuantityUnit = "serving_quantity_unit"
        case imageFrontUrl = "image_front_url"
        case imageFrontSmallUrl = "image_front_small_url"
        case imageUrl = "image_url"
    }

    // Custom decoder to handle serving_quantity as either String or Double
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        productName = try container.decodeIfPresent(String.self, forKey: .productName)
        brands = try container.decodeIfPresent(String.self, forKey: .brands)
        nutriments = try container.decodeIfPresent(Nutriments.self, forKey: .nutriments)
        servingQuantityUnit = try container.decodeIfPresent(String.self, forKey: .servingQuantityUnit)
        imageFrontUrl = try container.decodeIfPresent(String.self, forKey: .imageFrontUrl)
        imageFrontSmallUrl = try container.decodeIfPresent(String.self, forKey: .imageFrontSmallUrl)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)

        // Handle servingQuantity as either String or Double
        if let quantityString = try? container.decode(String.self, forKey: .servingQuantity) {
            servingQuantity = Double(quantityString)
        } else if let quantityDouble = try? container.decode(Double.self, forKey: .servingQuantity) {
            servingQuantity = quantityDouble
        } else {
            servingQuantity = nil
        }
    }
}

struct Nutriments: Codable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?

    // Alternative field names that might be used
    let energy100g: Double?
    let protein100g: Double?
    let carbs100g: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case energy100g = "energy_100g"
        case protein100g = "protein_100g"
        case carbs100g = "carbs_100g"
    }

    // Helper to get the best available calorie value
    var bestCalories: Double? {
        energyKcal100g ?? (energy100g != nil ? energy100g! / 4.184 : nil)
    }

    // Helper to get the best available protein value
    var bestProtein: Double? {
        proteins100g ?? protein100g
    }

    // Helper to get the best available carbs value
    var bestCarbs: Double? {
        carbohydrates100g ?? carbs100g
    }
}