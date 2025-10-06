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

        return ScannedFoodData(
            barcode: barcode,
            name: product.productName ?? "Unknown Product",
            brand: product.brands ?? "",
            calories: product.nutriments.energyKcal100g ?? 0,
            protein: product.nutriments.proteins100g ?? 0,
            carbs: product.nutriments.carbohydrates100g ?? 0,
            fat: product.nutriments.fat100g ?? 0,
            servingSize: product.servingQuantity ?? 100,
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
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let servingSize: Double
    let servingUnit: String
    let imageURL: String?

    // Convert to FoodEntry
    func toFoodEntry(servings: Double = 1) -> FoodEntry {
        let multiplier = servings
        return FoodEntry(
            name: brand.isEmpty ? name : "\(brand) - \(name)",
            calories: calories * multiplier,
            protein: protein * multiplier,
            carbs: carbs * multiplier,
            fat: fat * multiplier,
            date: Date()
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
