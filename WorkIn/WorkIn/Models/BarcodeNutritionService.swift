import Foundation

// Service to fetch nutrition data from barcode
class BarcodeNutritionService {

    static let shared = BarcodeNutritionService()

    private init() {}

    // Fetch nutrition data from Open Food Facts API
    func fetchNutritionData(barcode: String) async throws -> ScannedFoodData {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json"

        guard let url = URL(string: urlString) else {
            throw BarcodeError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BarcodeError.serverError
        }

        let decoder = JSONDecoder()
        let productResponse = try decoder.decode(OpenFoodFactsResponse.self, from: data)

        guard productResponse.status == 1,
              let product = productResponse.product else {
            throw BarcodeError.productNotFound
        }

        // Calculate per-serving nutrition from per-100g values
        let servingSize = product.servingQuantity ?? 100
        let servingMultiplier = servingSize / 100.0

        return ScannedFoodData(
            barcode: barcode,
            name: product.productName ?? "Unknown Product",
            brand: product.brands ?? "",
            caloriesPerServing: (product.nutriments.energyKcal100g ?? 0) * servingMultiplier,
            proteinPerServing: (product.nutriments.proteins100g ?? 0) * servingMultiplier,
            carbsPerServing: (product.nutriments.carbohydrates100g ?? 0) * servingMultiplier,
            fatPerServing: (product.nutriments.fat100g ?? 0) * servingMultiplier,
            caloriesPer100g: product.nutriments.energyKcal100g ?? 0,
            proteinPer100g: product.nutriments.proteins100g ?? 0,
            carbsPer100g: product.nutriments.carbohydrates100g ?? 0,
            fatPer100g: product.nutriments.fat100g ?? 0,
            servingSize: servingSize,
            servingUnit: product.servingQuantityUnit ?? "g",
            imageURL: product.imageFrontUrl
        )
    }
}

// Scanned food data model
struct ScannedFoodData {
    let barcode: String
    let name: String
    let brand: String
    let caloriesPerServing: Double
    let proteinPerServing: Double
    let carbsPerServing: Double
    let fatPerServing: Double
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let servingSize: Double
    let servingUnit: String
    let imageURL: String?

    // Convert to FoodEntry - can be by servings or by grams
    func toFoodEntry(servings: Double? = nil, grams: Double? = nil) -> FoodEntry {
        let multiplier: Double
        if let grams = grams {
            // Calculate based on grams
            multiplier = grams / 100.0
            return FoodEntry(
                name: brand.isEmpty ? name : "\(brand) - \(name)",
                calories: caloriesPer100g * multiplier,
                protein: proteinPer100g * multiplier,
                carbs: carbsPer100g * multiplier,
                fat: fatPer100g * multiplier,
                date: Date()
            )
        } else {
            // Calculate based on servings
            multiplier = servings ?? 1.0
            return FoodEntry(
                name: brand.isEmpty ? name : "\(brand) - \(name)",
                calories: caloriesPerServing * multiplier,
                protein: proteinPerServing * multiplier,
                carbs: carbsPerServing * multiplier,
                fat: fatPerServing * multiplier,
                date: Date()
            )
        }
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
    let nutriments: Nutriments
    let servingQuantity: Double?
    let servingQuantityUnit: String?
    let imageFrontUrl: String?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case nutriments
        case servingQuantity = "serving_quantity"
        case servingQuantityUnit = "serving_quantity_unit"
        case imageFrontUrl = "image_front_url"
    }
}

struct Nutriments: Codable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
    }
}
