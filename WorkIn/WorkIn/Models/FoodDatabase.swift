import Foundation

enum FoodCategory: String, CaseIterable {
    case proteins = "Proteins"
    case grains = "Grains"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case dairy = "Dairy"
    case nuts = "Nuts & Seeds"
    case beverages = "Beverages"
    case snacks = "Snacks"
    case fastFood = "Fast Food"
}

struct FoodTemplate: Identifiable {
    let id = UUID()
    let name: String
    let category: FoodCategory
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let servingSize: Double // in grams
    let servingDescription: String

    var caloriesPerServing: Double {
        (caloriesPer100g * servingSize) / 100
    }

    var proteinPerServing: Double {
        (proteinPer100g * servingSize) / 100
    }

    var carbsPerServing: Double {
        (carbsPer100g * servingSize) / 100
    }

    var fatPerServing: Double {
        (fatPer100g * servingSize) / 100
    }
}

class FoodDatabase: ObservableObject {
    static let shared = FoodDatabase()

    let foods: [FoodTemplate] = [
        // PROTEINS - Poultry
        FoodTemplate(name: "Chicken Breast (skinless)", category: .proteins, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Chicken Thigh (skinless)", category: .proteins, caloriesPer100g: 209, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 11, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Turkey Breast", category: .proteins, caloriesPer100g: 135, proteinPer100g: 30, carbsPer100g: 0, fatPer100g: 1, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Ground Turkey (93/7)", category: .proteins, caloriesPer100g: 120, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 2, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Rotisserie Chicken", category: .proteins, caloriesPer100g: 167, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 7, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Duck Breast", category: .proteins, caloriesPer100g: 201, proteinPer100g: 23.5, carbsPer100g: 0, fatPer100g: 11, servingSize: 100, servingDescription: "3.5 oz"),

        // PROTEINS - Beef
        FoodTemplate(name: "Lean Ground Beef (90/10)", category: .proteins, caloriesPer100g: 176, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 8, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Ground Beef (80/20)", category: .proteins, caloriesPer100g: 254, proteinPer100g: 17, carbsPer100g: 0, fatPer100g: 20, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Sirloin Steak", category: .proteins, caloriesPer100g: 201, proteinPer100g: 27, carbsPer100g: 0, fatPer100g: 10, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Ribeye Steak", category: .proteins, caloriesPer100g: 291, proteinPer100g: 25, carbsPer100g: 0, fatPer100g: 21, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Flank Steak", category: .proteins, caloriesPer100g: 192, proteinPer100g: 28, carbsPer100g: 0, fatPer100g: 8, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Beef Brisket", category: .proteins, caloriesPer100g: 248, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 16, servingSize: 100, servingDescription: "3.5 oz"),

        // PROTEINS - Pork
        FoodTemplate(name: "Pork Chop (lean)", category: .proteins, caloriesPer100g: 206, proteinPer100g: 27, carbsPer100g: 0, fatPer100g: 10, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Bacon", category: .proteins, caloriesPer100g: 541, proteinPer100g: 37, carbsPer100g: 1.4, fatPer100g: 42, servingSize: 28, servingDescription: "2 slices"),
        FoodTemplate(name: "Ham (deli)", category: .proteins, caloriesPer100g: 145, proteinPer100g: 21, carbsPer100g: 2, fatPer100g: 5, servingSize: 56, servingDescription: "2 oz"),
        FoodTemplate(name: "Pork Tenderloin", category: .proteins, caloriesPer100g: 143, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 4, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Italian Sausage", category: .proteins, caloriesPer100g: 346, proteinPer100g: 14, carbsPer100g: 4, fatPer100g: 30, servingSize: 67, servingDescription: "1 link"),

        // PROTEINS - Fish & Seafood
        FoodTemplate(name: "Salmon (Atlantic)", category: .proteins, caloriesPer100g: 208, proteinPer100g: 22, carbsPer100g: 0, fatPer100g: 12, servingSize: 100, servingDescription: "3.5 oz fillet"),
        FoodTemplate(name: "Tuna (canned in water)", category: .proteins, caloriesPer100g: 116, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 0.8, servingSize: 85, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Tilapia", category: .proteins, caloriesPer100g: 128, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 3, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Cod", category: .proteins, caloriesPer100g: 82, proteinPer100g: 18, carbsPer100g: 0, fatPer100g: 0.7, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Shrimp", category: .proteins, caloriesPer100g: 85, proteinPer100g: 18, carbsPer100g: 0.2, fatPer100g: 0.5, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Crab", category: .proteins, caloriesPer100g: 97, proteinPer100g: 19, carbsPer100g: 0, fatPer100g: 1.1, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Scallops", category: .proteins, caloriesPer100g: 88, proteinPer100g: 17, carbsPer100g: 2.4, fatPer100g: 0.8, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Mahi Mahi", category: .proteins, caloriesPer100g: 93, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 1, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Halibut", category: .proteins, caloriesPer100g: 111, proteinPer100g: 23, carbsPer100g: 0, fatPer100g: 2, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Sardines (canned)", category: .proteins, caloriesPer100g: 208, proteinPer100g: 25, carbsPer100g: 0, fatPer100g: 11, servingSize: 85, servingDescription: "3 oz"),

        // PROTEINS - Eggs & Dairy
        FoodTemplate(name: "Whole Eggs", category: .proteins, caloriesPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatPer100g: 11, servingSize: 50, servingDescription: "1 large egg"),
        FoodTemplate(name: "Egg Whites", category: .proteins, caloriesPer100g: 52, proteinPer100g: 11, carbsPer100g: 0.7, fatPer100g: 0.2, servingSize: 33, servingDescription: "1 large egg white"),
        FoodTemplate(name: "Greek Yogurt (Plain, Nonfat)", category: .proteins, caloriesPer100g: 59, proteinPer100g: 10, carbsPer100g: 3.6, fatPer100g: 0.4, servingSize: 170, servingDescription: "1 cup"),
        FoodTemplate(name: "Greek Yogurt (Full Fat)", category: .proteins, caloriesPer100g: 97, proteinPer100g: 9, carbsPer100g: 3.9, fatPer100g: 5, servingSize: 170, servingDescription: "1 cup"),
        FoodTemplate(name: "Cottage Cheese (Low-Fat)", category: .proteins, caloriesPer100g: 98, proteinPer100g: 11, carbsPer100g: 3.4, fatPer100g: 4.3, servingSize: 113, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Cottage Cheese (Full Fat)", category: .proteins, caloriesPer100g: 98, proteinPer100g: 11, carbsPer100g: 3.4, fatPer100g: 4.3, servingSize: 113, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Ricotta Cheese", category: .proteins, caloriesPer100g: 174, proteinPer100g: 11, carbsPer100g: 3, fatPer100g: 13, servingSize: 124, servingDescription: "1/2 cup"),

        // PROTEINS - Plant-Based
        FoodTemplate(name: "Tofu (Firm)", category: .proteins, caloriesPer100g: 76, proteinPer100g: 8, carbsPer100g: 1.9, fatPer100g: 4.8, servingSize: 100, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Tempeh", category: .proteins, caloriesPer100g: 193, proteinPer100g: 19, carbsPer100g: 9, fatPer100g: 11, servingSize: 84, servingDescription: "3 oz"),
        FoodTemplate(name: "Edamame", category: .proteins, caloriesPer100g: 121, proteinPer100g: 11, carbsPer100g: 10, fatPer100g: 5, servingSize: 155, servingDescription: "1 cup"),
        FoodTemplate(name: "Black Beans", category: .proteins, caloriesPer100g: 132, proteinPer100g: 8.9, carbsPer100g: 24, fatPer100g: 0.5, servingSize: 172, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Chickpeas (Garbanzo Beans)", category: .proteins, caloriesPer100g: 164, proteinPer100g: 8.9, carbsPer100g: 27, fatPer100g: 2.6, servingSize: 164, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Lentils", category: .proteins, caloriesPer100g: 116, proteinPer100g: 9, carbsPer100g: 20, fatPer100g: 0.4, servingSize: 198, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Kidney Beans", category: .proteins, caloriesPer100g: 127, proteinPer100g: 8.7, carbsPer100g: 23, fatPer100g: 0.5, servingSize: 177, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Pinto Beans", category: .proteins, caloriesPer100g: 143, proteinPer100g: 9, carbsPer100g: 26, fatPer100g: 0.7, servingSize: 171, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Seitan", category: .proteins, caloriesPer100g: 370, proteinPer100g: 75, carbsPer100g: 14, fatPer100g: 2, servingSize: 85, servingDescription: "3 oz"),

        // GRAINS & CARBS - Rice
        FoodTemplate(name: "Brown Rice (cooked)", category: .grains, caloriesPer100g: 112, proteinPer100g: 2.6, carbsPer100g: 23, fatPer100g: 0.9, servingSize: 195, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "White Rice (cooked)", category: .grains, caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28, fatPer100g: 0.3, servingSize: 195, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Jasmine Rice (cooked)", category: .grains, caloriesPer100g: 129, proteinPer100g: 2.7, carbsPer100g: 28, fatPer100g: 0.3, servingSize: 195, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Basmati Rice (cooked)", category: .grains, caloriesPer100g: 121, proteinPer100g: 2.5, carbsPer100g: 25, fatPer100g: 0.4, servingSize: 195, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Wild Rice (cooked)", category: .grains, caloriesPer100g: 101, proteinPer100g: 4, carbsPer100g: 21, fatPer100g: 0.3, servingSize: 164, servingDescription: "1 cup cooked"),

        // GRAINS & CARBS - Pasta & Noodles
        FoodTemplate(name: "Pasta (cooked)", category: .grains, caloriesPer100g: 131, proteinPer100g: 5, carbsPer100g: 25, fatPer100g: 1.1, servingSize: 140, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Whole Wheat Pasta (cooked)", category: .grains, caloriesPer100g: 124, proteinPer100g: 5.3, carbsPer100g: 26, fatPer100g: 0.5, servingSize: 140, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Spaghetti (cooked)", category: .grains, caloriesPer100g: 158, proteinPer100g: 5.8, carbsPer100g: 31, fatPer100g: 0.9, servingSize: 140, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Penne (cooked)", category: .grains, caloriesPer100g: 131, proteinPer100g: 5, carbsPer100g: 25, fatPer100g: 1.1, servingSize: 140, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Ramen Noodles", category: .grains, caloriesPer100g: 138, proteinPer100g: 4.5, carbsPer100g: 25, fatPer100g: 2.1, servingSize: 150, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Rice Noodles (cooked)", category: .grains, caloriesPer100g: 109, proteinPer100g: 1.8, carbsPer100g: 24, fatPer100g: 0.2, servingSize: 175, servingDescription: "1 cup cooked"),

        // GRAINS & CARBS - Bread
        FoodTemplate(name: "Whole Wheat Bread", category: .grains, caloriesPer100g: 247, proteinPer100g: 13, carbsPer100g: 41, fatPer100g: 4.2, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "White Bread", category: .grains, caloriesPer100g: 266, proteinPer100g: 8.9, carbsPer100g: 49, fatPer100g: 3.2, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "Sourdough Bread", category: .grains, caloriesPer100g: 289, proteinPer100g: 11.6, carbsPer100g: 56, fatPer100g: 1.5, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "Rye Bread", category: .grains, caloriesPer100g: 259, proteinPer100g: 8.5, carbsPer100g: 48, fatPer100g: 3.3, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "Bagel (Plain)", category: .grains, caloriesPer100g: 257, proteinPer100g: 10, carbsPer100g: 50, fatPer100g: 1.4, servingSize: 90, servingDescription: "1 bagel"),
        FoodTemplate(name: "English Muffin", category: .grains, caloriesPer100g: 227, proteinPer100g: 7.6, carbsPer100g: 44, fatPer100g: 2.2, servingSize: 57, servingDescription: "1 muffin"),
        FoodTemplate(name: "Pita Bread", category: .grains, caloriesPer100g: 275, proteinPer100g: 9.1, carbsPer100g: 55, fatPer100g: 1.2, servingSize: 60, servingDescription: "1 pita"),
        FoodTemplate(name: "Tortilla (flour)", category: .grains, caloriesPer100g: 312, proteinPer100g: 8, carbsPer100g: 51, fatPer100g: 8, servingSize: 46, servingDescription: "1 tortilla"),

        // GRAINS & CARBS - Potatoes
        FoodTemplate(name: "White Potato (baked)", category: .grains, caloriesPer100g: 93, proteinPer100g: 2.5, carbsPer100g: 21, fatPer100g: 0.1, servingSize: 173, servingDescription: "1 medium"),
        FoodTemplate(name: "Sweet Potato (baked)", category: .grains, caloriesPer100g: 90, proteinPer100g: 2, carbsPer100g: 21, fatPer100g: 0.2, servingSize: 130, servingDescription: "1 medium"),
        FoodTemplate(name: "Red Potato", category: .grains, caloriesPer100g: 70, proteinPer100g: 1.9, carbsPer100g: 16, fatPer100g: 0.1, servingSize: 148, servingDescription: "1 medium"),
        FoodTemplate(name: "Russet Potato", category: .grains, caloriesPer100g: 79, proteinPer100g: 2.1, carbsPer100g: 18, fatPer100g: 0.1, servingSize: 173, servingDescription: "1 medium"),
        FoodTemplate(name: "Mashed Potatoes", category: .grains, caloriesPer100g: 113, proteinPer100g: 2, carbsPer100g: 17, fatPer100g: 4.2, servingSize: 210, servingDescription: "1 cup"),

        // GRAINS & CARBS - Cereals & Oats
        FoodTemplate(name: "Oatmeal (cooked)", category: .grains, caloriesPer100g: 68, proteinPer100g: 2.4, carbsPer100g: 12, fatPer100g: 1.4, servingSize: 234, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Steel Cut Oats (cooked)", category: .grains, caloriesPer100g: 62, proteinPer100g: 2.5, carbsPer100g: 11, fatPer100g: 1.3, servingSize: 234, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Granola", category: .grains, caloriesPer100g: 471, proteinPer100g: 10, carbsPer100g: 64, fatPer100g: 20, servingSize: 60, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Cheerios", category: .grains, caloriesPer100g: 375, proteinPer100g: 12.5, carbsPer100g: 70, fatPer100g: 6.3, servingSize: 28, servingDescription: "1 cup"),
        FoodTemplate(name: "Cornflakes", category: .grains, caloriesPer100g: 357, proteinPer100g: 7.1, carbsPer100g: 84, fatPer100g: 0.4, servingSize: 28, servingDescription: "1 cup"),
        FoodTemplate(name: "Cream of Wheat (cooked)", category: .grains, caloriesPer100g: 54, proteinPer100g: 1.6, carbsPer100g: 11, fatPer100g: 0.4, servingSize: 241, servingDescription: "1 cup cooked"),

        // GRAINS & CARBS - Other
        FoodTemplate(name: "Quinoa (cooked)", category: .grains, caloriesPer100g: 120, proteinPer100g: 4.4, carbsPer100g: 22, fatPer100g: 1.9, servingSize: 185, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Couscous (cooked)", category: .grains, caloriesPer100g: 112, proteinPer100g: 3.8, carbsPer100g: 23, fatPer100g: 0.2, servingSize: 157, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Bulgur (cooked)", category: .grains, caloriesPer100g: 83, proteinPer100g: 3.1, carbsPer100g: 18, fatPer100g: 0.2, servingSize: 182, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Barley (cooked)", category: .grains, caloriesPer100g: 123, proteinPer100g: 2.3, carbsPer100g: 28, fatPer100g: 0.4, servingSize: 157, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Pancakes", category: .grains, caloriesPer100g: 227, proteinPer100g: 6.4, carbsPer100g: 28, fatPer100g: 9, servingSize: 77, servingDescription: "1 pancake"),
        FoodTemplate(name: "Waffles", category: .grains, caloriesPer100g: 291, proteinPer100g: 7.9, carbsPer100g: 37, fatPer100g: 12, servingSize: 75, servingDescription: "1 waffle"),

        // VEGETABLES - Cruciferous & Leafy Greens
        FoodTemplate(name: "Broccoli", category: .vegetables, caloriesPer100g: 34, proteinPer100g: 2.8, carbsPer100g: 7, fatPer100g: 0.4, servingSize: 91, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Cauliflower", category: .vegetables, caloriesPer100g: 25, proteinPer100g: 1.9, carbsPer100g: 5, fatPer100g: 0.3, servingSize: 100, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Brussels Sprouts", category: .vegetables, caloriesPer100g: 43, proteinPer100g: 3.4, carbsPer100g: 9, fatPer100g: 0.3, servingSize: 88, servingDescription: "1 cup"),
        FoodTemplate(name: "Cabbage", category: .vegetables, caloriesPer100g: 25, proteinPer100g: 1.3, carbsPer100g: 6, fatPer100g: 0.1, servingSize: 89, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Kale", category: .vegetables, caloriesPer100g: 35, proteinPer100g: 2.9, carbsPer100g: 6, fatPer100g: 1.5, servingSize: 67, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Spinach (raw)", category: .vegetables, caloriesPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6, fatPer100g: 0.4, servingSize: 30, servingDescription: "1 cup raw"),
        FoodTemplate(name: "Spinach (cooked)", category: .vegetables, caloriesPer100g: 23, proteinPer100g: 3, carbsPer100g: 3.8, fatPer100g: 0.3, servingSize: 180, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Lettuce (Romaine)", category: .vegetables, caloriesPer100g: 17, proteinPer100g: 1.2, carbsPer100g: 3.3, fatPer100g: 0.3, servingSize: 47, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Lettuce (Iceberg)", category: .vegetables, caloriesPer100g: 14, proteinPer100g: 0.9, carbsPer100g: 3, fatPer100g: 0.1, servingSize: 72, servingDescription: "1 cup shredded"),
        FoodTemplate(name: "Arugula", category: .vegetables, caloriesPer100g: 25, proteinPer100g: 2.6, carbsPer100g: 3.7, fatPer100g: 0.7, servingSize: 20, servingDescription: "1 cup"),
        FoodTemplate(name: "Swiss Chard", category: .vegetables, caloriesPer100g: 19, proteinPer100g: 1.8, carbsPer100g: 3.7, fatPer100g: 0.2, servingSize: 36, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Collard Greens", category: .vegetables, caloriesPer100g: 32, proteinPer100g: 3, carbsPer100g: 6, fatPer100g: 0.6, servingSize: 36, servingDescription: "1 cup chopped"),

        // VEGETABLES - Root Vegetables & Others
        FoodTemplate(name: "Carrots", category: .vegetables, caloriesPer100g: 41, proteinPer100g: 0.9, carbsPer100g: 10, fatPer100g: 0.2, servingSize: 61, servingDescription: "1 medium"),
        FoodTemplate(name: "Beets", category: .vegetables, caloriesPer100g: 43, proteinPer100g: 1.6, carbsPer100g: 10, fatPer100g: 0.2, servingSize: 82, servingDescription: "1 beet"),
        FoodTemplate(name: "Turnips", category: .vegetables, caloriesPer100g: 28, proteinPer100g: 0.9, carbsPer100g: 6, fatPer100g: 0.1, servingSize: 122, servingDescription: "1 cup cubed"),
        FoodTemplate(name: "Parsnips", category: .vegetables, caloriesPer100g: 75, proteinPer100g: 1.2, carbsPer100g: 18, fatPer100g: 0.3, servingSize: 133, servingDescription: "1 cup sliced"),
        FoodTemplate(name: "Radishes", category: .vegetables, caloriesPer100g: 16, proteinPer100g: 0.7, carbsPer100g: 3.4, fatPer100g: 0.1, servingSize: 116, servingDescription: "1 cup sliced"),

        // VEGETABLES - Peppers & Squash
        FoodTemplate(name: "Bell Peppers (red)", category: .vegetables, caloriesPer100g: 31, proteinPer100g: 1, carbsPer100g: 7, fatPer100g: 0.3, servingSize: 119, servingDescription: "1 medium"),
        FoodTemplate(name: "Bell Peppers (green)", category: .vegetables, caloriesPer100g: 20, proteinPer100g: 0.9, carbsPer100g: 4.6, fatPer100g: 0.2, servingSize: 119, servingDescription: "1 medium"),
        FoodTemplate(name: "Jalapeño Peppers", category: .vegetables, caloriesPer100g: 29, proteinPer100g: 0.9, carbsPer100g: 6, fatPer100g: 0.4, servingSize: 14, servingDescription: "1 pepper"),
        FoodTemplate(name: "Zucchini", category: .vegetables, caloriesPer100g: 17, proteinPer100g: 1.2, carbsPer100g: 3.1, fatPer100g: 0.3, servingSize: 124, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Yellow Squash", category: .vegetables, caloriesPer100g: 18, proteinPer100g: 1.2, carbsPer100g: 3.9, fatPer100g: 0.2, servingSize: 113, servingDescription: "1 cup sliced"),
        FoodTemplate(name: "Butternut Squash", category: .vegetables, caloriesPer100g: 45, proteinPer100g: 1, carbsPer100g: 12, fatPer100g: 0.1, servingSize: 205, servingDescription: "1 cup cubed"),
        FoodTemplate(name: "Acorn Squash", category: .vegetables, caloriesPer100g: 56, proteinPer100g: 1.1, carbsPer100g: 15, fatPer100g: 0.1, servingSize: 140, servingDescription: "1 cup cubed"),
        FoodTemplate(name: "Spaghetti Squash", category: .vegetables, caloriesPer100g: 31, proteinPer100g: 0.6, carbsPer100g: 7, fatPer100g: 0.6, servingSize: 155, servingDescription: "1 cup"),
        FoodTemplate(name: "Pumpkin", category: .vegetables, caloriesPer100g: 26, proteinPer100g: 1, carbsPer100g: 7, fatPer100g: 0.1, servingSize: 245, servingDescription: "1 cup cubed"),

        // VEGETABLES - Beans & Other
        FoodTemplate(name: "Green Beans", category: .vegetables, caloriesPer100g: 31, proteinPer100g: 1.8, carbsPer100g: 7, fatPer100g: 0.2, servingSize: 110, servingDescription: "1 cup"),
        FoodTemplate(name: "Asparagus", category: .vegetables, caloriesPer100g: 20, proteinPer100g: 2.2, carbsPer100g: 3.9, fatPer100g: 0.1, servingSize: 134, servingDescription: "1 cup"),
        FoodTemplate(name: "Celery", category: .vegetables, caloriesPer100g: 16, proteinPer100g: 0.7, carbsPer100g: 3, fatPer100g: 0.2, servingSize: 101, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Cucumber", category: .vegetables, caloriesPer100g: 16, proteinPer100g: 0.7, carbsPer100g: 4, fatPer100g: 0.1, servingSize: 104, servingDescription: "1 cup sliced"),
        FoodTemplate(name: "Tomatoes", category: .vegetables, caloriesPer100g: 18, proteinPer100g: 0.9, carbsPer100g: 3.9, fatPer100g: 0.2, servingSize: 123, servingDescription: "1 medium"),
        FoodTemplate(name: "Cherry Tomatoes", category: .vegetables, caloriesPer100g: 18, proteinPer100g: 0.9, carbsPer100g: 3.9, fatPer100g: 0.2, servingSize: 149, servingDescription: "1 cup"),
        FoodTemplate(name: "Mushrooms (white)", category: .vegetables, caloriesPer100g: 22, proteinPer100g: 3.1, carbsPer100g: 3.3, fatPer100g: 0.3, servingSize: 70, servingDescription: "1 cup sliced"),
        FoodTemplate(name: "Portobello Mushrooms", category: .vegetables, caloriesPer100g: 26, proteinPer100g: 2.5, carbsPer100g: 4.4, fatPer100g: 0.4, servingSize: 84, servingDescription: "1 cap"),
        FoodTemplate(name: "Onions", category: .vegetables, caloriesPer100g: 40, proteinPer100g: 1.1, carbsPer100g: 9, fatPer100g: 0.1, servingSize: 110, servingDescription: "1 medium"),
        FoodTemplate(name: "Garlic", category: .vegetables, caloriesPer100g: 149, proteinPer100g: 6.4, carbsPer100g: 33, fatPer100g: 0.5, servingSize: 3, servingDescription: "1 clove"),
        FoodTemplate(name: "Eggplant", category: .vegetables, caloriesPer100g: 25, proteinPer100g: 1, carbsPer100g: 6, fatPer100g: 0.2, servingSize: 82, servingDescription: "1 cup cubed"),
        FoodTemplate(name: "Corn (sweet, cooked)", category: .vegetables, caloriesPer100g: 96, proteinPer100g: 3.4, carbsPer100g: 21, fatPer100g: 1.5, servingSize: 154, servingDescription: "1 cup"),
        FoodTemplate(name: "Peas (green, cooked)", category: .vegetables, caloriesPer100g: 84, proteinPer100g: 5.4, carbsPer100g: 16, fatPer100g: 0.2, servingSize: 160, servingDescription: "1 cup"),

        // FRUITS - Berries
        FoodTemplate(name: "Blueberries", category: .fruits, caloriesPer100g: 57, proteinPer100g: 0.7, carbsPer100g: 14, fatPer100g: 0.3, servingSize: 148, servingDescription: "1 cup"),
        FoodTemplate(name: "Strawberries", category: .fruits, caloriesPer100g: 32, proteinPer100g: 0.7, carbsPer100g: 8, fatPer100g: 0.3, servingSize: 152, servingDescription: "1 cup halves"),
        FoodTemplate(name: "Raspberries", category: .fruits, caloriesPer100g: 52, proteinPer100g: 1.2, carbsPer100g: 12, fatPer100g: 0.7, servingSize: 123, servingDescription: "1 cup"),
        FoodTemplate(name: "Blackberries", category: .fruits, caloriesPer100g: 43, proteinPer100g: 1.4, carbsPer100g: 10, fatPer100g: 0.5, servingSize: 144, servingDescription: "1 cup"),
        FoodTemplate(name: "Cranberries", category: .fruits, caloriesPer100g: 46, proteinPer100g: 0.4, carbsPer100g: 12, fatPer100g: 0.1, servingSize: 100, servingDescription: "1 cup"),

        // FRUITS - Citrus
        FoodTemplate(name: "Orange", category: .fruits, caloriesPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 12, fatPer100g: 0.1, servingSize: 131, servingDescription: "1 medium"),
        FoodTemplate(name: "Grapefruit", category: .fruits, caloriesPer100g: 42, proteinPer100g: 0.8, carbsPer100g: 11, fatPer100g: 0.1, servingSize: 123, servingDescription: "1/2 fruit"),
        FoodTemplate(name: "Lemon", category: .fruits, caloriesPer100g: 29, proteinPer100g: 1.1, carbsPer100g: 9, fatPer100g: 0.3, servingSize: 58, servingDescription: "1 fruit"),
        FoodTemplate(name: "Lime", category: .fruits, caloriesPer100g: 30, proteinPer100g: 0.7, carbsPer100g: 11, fatPer100g: 0.2, servingSize: 67, servingDescription: "1 fruit"),
        FoodTemplate(name: "Tangerine", category: .fruits, caloriesPer100g: 53, proteinPer100g: 0.8, carbsPer100g: 13, fatPer100g: 0.3, servingSize: 88, servingDescription: "1 medium"),
        FoodTemplate(name: "Clementine", category: .fruits, caloriesPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 12, fatPer100g: 0.2, servingSize: 74, servingDescription: "1 fruit"),

        // FRUITS - Common Fruits
        FoodTemplate(name: "Apple", category: .fruits, caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14, fatPer100g: 0.2, servingSize: 182, servingDescription: "1 medium"),
        FoodTemplate(name: "Banana", category: .fruits, caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23, fatPer100g: 0.3, servingSize: 118, servingDescription: "1 medium"),
        FoodTemplate(name: "Grapes (red/green)", category: .fruits, caloriesPer100g: 69, proteinPer100g: 0.7, carbsPer100g: 18, fatPer100g: 0.2, servingSize: 92, servingDescription: "1 cup"),
        FoodTemplate(name: "Pear", category: .fruits, caloriesPer100g: 57, proteinPer100g: 0.4, carbsPer100g: 15, fatPer100g: 0.1, servingSize: 178, servingDescription: "1 medium"),
        FoodTemplate(name: "Peach", category: .fruits, caloriesPer100g: 39, proteinPer100g: 0.9, carbsPer100g: 10, fatPer100g: 0.3, servingSize: 150, servingDescription: "1 medium"),
        FoodTemplate(name: "Plum", category: .fruits, caloriesPer100g: 46, proteinPer100g: 0.7, carbsPer100g: 11, fatPer100g: 0.3, servingSize: 66, servingDescription: "1 fruit"),
        FoodTemplate(name: "Nectarine", category: .fruits, caloriesPer100g: 44, proteinPer100g: 1.1, carbsPer100g: 11, fatPer100g: 0.3, servingSize: 142, servingDescription: "1 medium"),
        FoodTemplate(name: "Apricot", category: .fruits, caloriesPer100g: 48, proteinPer100g: 1.4, carbsPer100g: 11, fatPer100g: 0.4, servingSize: 35, servingDescription: "1 fruit"),
        FoodTemplate(name: "Cherries", category: .fruits, caloriesPer100g: 63, proteinPer100g: 1.1, carbsPer100g: 16, fatPer100g: 0.2, servingSize: 138, servingDescription: "1 cup"),

        // FRUITS - Tropical
        FoodTemplate(name: "Pineapple", category: .fruits, caloriesPer100g: 50, proteinPer100g: 0.5, carbsPer100g: 13, fatPer100g: 0.1, servingSize: 165, servingDescription: "1 cup chunks"),
        FoodTemplate(name: "Mango", category: .fruits, caloriesPer100g: 60, proteinPer100g: 0.8, carbsPer100g: 15, fatPer100g: 0.4, servingSize: 165, servingDescription: "1 cup sliced"),
        FoodTemplate(name: "Papaya", category: .fruits, caloriesPer100g: 43, proteinPer100g: 0.5, carbsPer100g: 11, fatPer100g: 0.3, servingSize: 140, servingDescription: "1 cup cubed"),
        FoodTemplate(name: "Kiwi", category: .fruits, caloriesPer100g: 61, proteinPer100g: 1.1, carbsPer100g: 15, fatPer100g: 0.5, servingSize: 69, servingDescription: "1 fruit"),
        FoodTemplate(name: "Dragon Fruit", category: .fruits, caloriesPer100g: 60, proteinPer100g: 1.2, carbsPer100g: 13, fatPer100g: 0, servingSize: 100, servingDescription: "1 cup cubed"),
        FoodTemplate(name: "Guava", category: .fruits, caloriesPer100g: 68, proteinPer100g: 2.6, carbsPer100g: 14, fatPer100g: 1, servingSize: 55, servingDescription: "1 fruit"),
        FoodTemplate(name: "Passion Fruit", category: .fruits, caloriesPer100g: 97, proteinPer100g: 2.2, carbsPer100g: 23, fatPer100g: 0.7, servingSize: 18, servingDescription: "1 fruit"),
        FoodTemplate(name: "Coconut (meat)", category: .fruits, caloriesPer100g: 354, proteinPer100g: 3.3, carbsPer100g: 15, fatPer100g: 33, servingSize: 80, servingDescription: "1 cup shredded"),

        // FRUITS - Melons
        FoodTemplate(name: "Watermelon", category: .fruits, caloriesPer100g: 30, proteinPer100g: 0.6, carbsPer100g: 8, fatPer100g: 0.2, servingSize: 152, servingDescription: "1 cup diced"),
        FoodTemplate(name: "Cantaloupe", category: .fruits, caloriesPer100g: 34, proteinPer100g: 0.8, carbsPer100g: 8, fatPer100g: 0.2, servingSize: 177, servingDescription: "1 cup cubed"),
        FoodTemplate(name: "Honeydew Melon", category: .fruits, caloriesPer100g: 36, proteinPer100g: 0.5, carbsPer100g: 9, fatPer100g: 0.1, servingSize: 170, servingDescription: "1 cup cubed"),

        // FRUITS - Dried
        FoodTemplate(name: "Raisins", category: .fruits, caloriesPer100g: 299, proteinPer100g: 3.1, carbsPer100g: 79, fatPer100g: 0.5, servingSize: 43, servingDescription: "1/4 cup"),
        FoodTemplate(name: "Dates", category: .fruits, caloriesPer100g: 277, proteinPer100g: 1.8, carbsPer100g: 75, fatPer100g: 0.2, servingSize: 24, servingDescription: "1 date"),
        FoodTemplate(name: "Dried Apricots", category: .fruits, caloriesPer100g: 241, proteinPer100g: 3.4, carbsPer100g: 63, fatPer100g: 0.5, servingSize: 35, servingDescription: "1/4 cup"),
        FoodTemplate(name: "Prunes", category: .fruits, caloriesPer100g: 240, proteinPer100g: 2.2, carbsPer100g: 64, fatPer100g: 0.4, servingSize: 40, servingDescription: "4 prunes"),
        FoodTemplate(name: "Dried Cranberries", category: .fruits, caloriesPer100g: 308, proteinPer100g: 0, carbsPer100g: 82, fatPer100g: 1.4, servingSize: 40, servingDescription: "1/4 cup"),

        // DAIRY - Milk & Cream
        FoodTemplate(name: "Milk (Whole)", category: .dairy, caloriesPer100g: 61, proteinPer100g: 3.2, carbsPer100g: 4.8, fatPer100g: 3.3, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Milk (2%)", category: .dairy, caloriesPer100g: 50, proteinPer100g: 3.3, carbsPer100g: 4.7, fatPer100g: 2, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Milk (Skim/Nonfat)", category: .dairy, caloriesPer100g: 34, proteinPer100g: 3.4, carbsPer100g: 5, fatPer100g: 0.1, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Almond Milk (unsweetened)", category: .dairy, caloriesPer100g: 15, proteinPer100g: 0.6, carbsPer100g: 0.6, fatPer100g: 1.2, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Oat Milk", category: .dairy, caloriesPer100g: 47, proteinPer100g: 1, carbsPer100g: 7.5, fatPer100g: 1.5, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Soy Milk (unsweetened)", category: .dairy, caloriesPer100g: 33, proteinPer100g: 2.9, carbsPer100g: 1.7, fatPer100g: 1.7, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Heavy Cream", category: .dairy, caloriesPer100g: 340, proteinPer100g: 2.1, carbsPer100g: 2.8, fatPer100g: 36, servingSize: 15, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Half and Half", category: .dairy, caloriesPer100g: 131, proteinPer100g: 2.9, carbsPer100g: 4.3, fatPer100g: 12, servingSize: 15, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Sour Cream", category: .dairy, caloriesPer100g: 193, proteinPer100g: 2.4, carbsPer100g: 4.6, fatPer100g: 19, servingSize: 28, servingDescription: "2 tbsp"),

        // DAIRY - Cheese
        FoodTemplate(name: "Cheddar Cheese", category: .dairy, caloriesPer100g: 403, proteinPer100g: 25, carbsPer100g: 1.3, fatPer100g: 33, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Mozzarella Cheese", category: .dairy, caloriesPer100g: 300, proteinPer100g: 22, carbsPer100g: 2.2, fatPer100g: 22, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "American Cheese", category: .dairy, caloriesPer100g: 371, proteinPer100g: 22, carbsPer100g: 3.5, fatPer100g: 31, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "Swiss Cheese", category: .dairy, caloriesPer100g: 380, proteinPer100g: 27, carbsPer100g: 5, fatPer100g: 28, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Parmesan Cheese", category: .dairy, caloriesPer100g: 431, proteinPer100g: 38, carbsPer100g: 4.1, fatPer100g: 29, servingSize: 5, servingDescription: "1 tbsp grated"),
        FoodTemplate(name: "Feta Cheese", category: .dairy, caloriesPer100g: 264, proteinPer100g: 14, carbsPer100g: 4.1, fatPer100g: 21, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Blue Cheese", category: .dairy, caloriesPer100g: 353, proteinPer100g: 21, carbsPer100g: 2.3, fatPer100g: 29, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Goat Cheese", category: .dairy, caloriesPer100g: 364, proteinPer100g: 22, carbsPer100g: 2.5, fatPer100g: 30, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Brie Cheese", category: .dairy, caloriesPer100g: 334, proteinPer100g: 21, carbsPer100g: 0.5, fatPer100g: 28, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Provolone Cheese", category: .dairy, caloriesPer100g: 351, proteinPer100g: 25, carbsPer100g: 2.1, fatPer100g: 27, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Pepper Jack Cheese", category: .dairy, caloriesPer100g: 375, proteinPer100g: 25, carbsPer100g: 0.5, fatPer100g: 30, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Cream Cheese", category: .dairy, caloriesPer100g: 342, proteinPer100g: 5.9, carbsPer100g: 5.5, fatPer100g: 34, servingSize: 28, servingDescription: "2 tbsp"),

        // DAIRY - Other
        FoodTemplate(name: "Butter", category: .dairy, caloriesPer100g: 717, proteinPer100g: 0.9, carbsPer100g: 0.1, fatPer100g: 81, servingSize: 14, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Butter (salted)", category: .dairy, caloriesPer100g: 717, proteinPer100g: 0.9, carbsPer100g: 0.1, fatPer100g: 81, servingSize: 14, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Margarine", category: .dairy, caloriesPer100g: 717, proteinPer100g: 0.2, carbsPer100g: 0.9, fatPer100g: 80, servingSize: 14, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Plain Yogurt (whole milk)", category: .dairy, caloriesPer100g: 61, proteinPer100g: 3.5, carbsPer100g: 4.7, fatPer100g: 3.3, servingSize: 170, servingDescription: "1 cup"),
        FoodTemplate(name: "Plain Yogurt (low-fat)", category: .dairy, caloriesPer100g: 63, proteinPer100g: 5.3, carbsPer100g: 7, fatPer100g: 1.6, servingSize: 170, servingDescription: "1 cup"),

        // NUTS & SEEDS - Nuts
        FoodTemplate(name: "Almonds", category: .nuts, caloriesPer100g: 579, proteinPer100g: 21, carbsPer100g: 22, fatPer100g: 50, servingSize: 28, servingDescription: "1 oz (23 nuts)"),
        FoodTemplate(name: "Walnuts", category: .nuts, caloriesPer100g: 654, proteinPer100g: 15, carbsPer100g: 14, fatPer100g: 65, servingSize: 28, servingDescription: "1 oz (14 halves)"),
        FoodTemplate(name: "Cashews", category: .nuts, caloriesPer100g: 553, proteinPer100g: 18, carbsPer100g: 30, fatPer100g: 44, servingSize: 28, servingDescription: "1 oz (18 nuts)"),
        FoodTemplate(name: "Peanuts", category: .nuts, caloriesPer100g: 567, proteinPer100g: 26, carbsPer100g: 16, fatPer100g: 49, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Pecans", category: .nuts, caloriesPer100g: 691, proteinPer100g: 9, carbsPer100g: 14, fatPer100g: 72, servingSize: 28, servingDescription: "1 oz (19 halves)"),
        FoodTemplate(name: "Pistachios", category: .nuts, caloriesPer100g: 560, proteinPer100g: 20, carbsPer100g: 28, fatPer100g: 45, servingSize: 28, servingDescription: "1 oz (49 nuts)"),
        FoodTemplate(name: "Macadamia Nuts", category: .nuts, caloriesPer100g: 718, proteinPer100g: 8, carbsPer100g: 14, fatPer100g: 76, servingSize: 28, servingDescription: "1 oz (10-12 nuts)"),
        FoodTemplate(name: "Brazil Nuts", category: .nuts, caloriesPer100g: 656, proteinPer100g: 14, carbsPer100g: 12, fatPer100g: 66, servingSize: 28, servingDescription: "1 oz (6 nuts)"),
        FoodTemplate(name: "Hazelnuts", category: .nuts, caloriesPer100g: 628, proteinPer100g: 15, carbsPer100g: 17, fatPer100g: 61, servingSize: 28, servingDescription: "1 oz (21 nuts)"),
        FoodTemplate(name: "Pine Nuts", category: .nuts, caloriesPer100g: 673, proteinPer100g: 14, carbsPer100g: 13, fatPer100g: 68, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Mixed Nuts", category: .nuts, caloriesPer100g: 607, proteinPer100g: 20, carbsPer100g: 21, fatPer100g: 54, servingSize: 28, servingDescription: "1 oz"),

        // NUTS & SEEDS - Nut Butters
        FoodTemplate(name: "Peanut Butter", category: .nuts, caloriesPer100g: 588, proteinPer100g: 25, carbsPer100g: 20, fatPer100g: 50, servingSize: 32, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Almond Butter", category: .nuts, caloriesPer100g: 614, proteinPer100g: 21, carbsPer100g: 19, fatPer100g: 56, servingSize: 32, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Cashew Butter", category: .nuts, caloriesPer100g: 587, proteinPer100g: 18, carbsPer100g: 27, fatPer100g: 49, servingSize: 32, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Sunflower Seed Butter", category: .nuts, caloriesPer100g: 617, proteinPer100g: 20, carbsPer100g: 20, fatPer100g: 54, servingSize: 32, servingDescription: "2 tbsp"),

        // NUTS & SEEDS - Seeds
        FoodTemplate(name: "Chia Seeds", category: .nuts, caloriesPer100g: 486, proteinPer100g: 17, carbsPer100g: 42, fatPer100g: 31, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Flaxseeds", category: .nuts, caloriesPer100g: 534, proteinPer100g: 18, carbsPer100g: 29, fatPer100g: 42, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Pumpkin Seeds", category: .nuts, caloriesPer100g: 559, proteinPer100g: 30, carbsPer100g: 14, fatPer100g: 49, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Sunflower Seeds", category: .nuts, caloriesPer100g: 584, proteinPer100g: 21, carbsPer100g: 20, fatPer100g: 51, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Hemp Seeds", category: .nuts, caloriesPer100g: 553, proteinPer100g: 32, carbsPer100g: 4.7, fatPer100g: 49, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Sesame Seeds", category: .nuts, caloriesPer100g: 573, proteinPer100g: 18, carbsPer100g: 23, fatPer100g: 50, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Poppy Seeds", category: .nuts, caloriesPer100g: 525, proteinPer100g: 18, carbsPer100g: 28, fatPer100g: 42, servingSize: 28, servingDescription: "1 oz"),

        // BEVERAGES - Juices
        FoodTemplate(name: "Orange Juice", category: .beverages, caloriesPer100g: 45, proteinPer100g: 0.7, carbsPer100g: 10, fatPer100g: 0.2, servingSize: 248, servingDescription: "1 cup"),
        FoodTemplate(name: "Apple Juice", category: .beverages, caloriesPer100g: 46, proteinPer100g: 0.1, carbsPer100g: 11, fatPer100g: 0.1, servingSize: 248, servingDescription: "1 cup"),
        FoodTemplate(name: "Grape Juice", category: .beverages, caloriesPer100g: 60, proteinPer100g: 0.4, carbsPer100g: 15, fatPer100g: 0.1, servingSize: 253, servingDescription: "1 cup"),
        FoodTemplate(name: "Cranberry Juice", category: .beverages, caloriesPer100g: 46, proteinPer100g: 0, carbsPer100g: 12, fatPer100g: 0.1, servingSize: 253, servingDescription: "1 cup"),
        FoodTemplate(name: "Tomato Juice", category: .beverages, caloriesPer100g: 17, proteinPer100g: 0.8, carbsPer100g: 4, fatPer100g: 0, servingSize: 243, servingDescription: "1 cup"),
        FoodTemplate(name: "Pineapple Juice", category: .beverages, caloriesPer100g: 53, proteinPer100g: 0.4, carbsPer100g: 13, fatPer100g: 0.1, servingSize: 250, servingDescription: "1 cup"),
        FoodTemplate(name: "Grapefruit Juice", category: .beverages, caloriesPer100g: 39, proteinPer100g: 0.5, carbsPer100g: 9, fatPer100g: 0.1, servingSize: 247, servingDescription: "1 cup"),

        // BEVERAGES - Hot Drinks
        FoodTemplate(name: "Coffee (black)", category: .beverages, caloriesPer100g: 2, proteinPer100g: 0.3, carbsPer100g: 0, fatPer100g: 0, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Coffee with Cream & Sugar", category: .beverages, caloriesPer100g: 25, proteinPer100g: 0.4, carbsPer100g: 3.8, fatPer100g: 1, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Latte (whole milk)", category: .beverages, caloriesPer100g: 54, proteinPer100g: 2.8, carbsPer100g: 5.2, fatPer100g: 2.5, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Cappuccino", category: .beverages, caloriesPer100g: 38, proteinPer100g: 2.1, carbsPer100g: 3.7, fatPer100g: 1.5, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Green Tea", category: .beverages, caloriesPer100g: 1, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 0, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Black Tea", category: .beverages, caloriesPer100g: 1, proteinPer100g: 0, carbsPer100g: 0.3, fatPer100g: 0, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Hot Chocolate", category: .beverages, caloriesPer100g: 77, proteinPer100g: 3.5, carbsPer100g: 10.7, fatPer100g: 2.3, servingSize: 240, servingDescription: "1 cup"),

        // BEVERAGES - Soft Drinks & Other
        FoodTemplate(name: "Coca Cola", category: .beverages, caloriesPer100g: 42, proteinPer100g: 0, carbsPer100g: 11, fatPer100g: 0, servingSize: 355, servingDescription: "12 fl oz can"),
        FoodTemplate(name: "Pepsi", category: .beverages, caloriesPer100g: 41, proteinPer100g: 0, carbsPer100g: 11, fatPer100g: 0, servingSize: 355, servingDescription: "12 fl oz can"),
        FoodTemplate(name: "Sprite", category: .beverages, caloriesPer100g: 40, proteinPer100g: 0, carbsPer100g: 10, fatPer100g: 0, servingSize: 355, servingDescription: "12 fl oz can"),
        FoodTemplate(name: "Mountain Dew", category: .beverages, caloriesPer100g: 46, proteinPer100g: 0, carbsPer100g: 12, fatPer100g: 0, servingSize: 355, servingDescription: "12 fl oz can"),
        FoodTemplate(name: "Red Bull", category: .beverages, caloriesPer100g: 45, proteinPer100g: 0.4, carbsPer100g: 11, fatPer100g: 0, servingSize: 250, servingDescription: "1 can"),
        FoodTemplate(name: "Monster Energy", category: .beverages, caloriesPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 11, fatPer100g: 0, servingSize: 473, servingDescription: "1 can"),
        FoodTemplate(name: "Gatorade", category: .beverages, caloriesPer100g: 25, proteinPer100g: 0, carbsPer100g: 6, fatPer100g: 0, servingSize: 355, servingDescription: "12 fl oz"),
        FoodTemplate(name: "Vitamin Water", category: .beverages, caloriesPer100g: 19, proteinPer100g: 0, carbsPer100g: 5, fatPer100g: 0, servingSize: 591, servingDescription: "1 bottle"),
        FoodTemplate(name: "Coconut Water", category: .beverages, caloriesPer100g: 19, proteinPer100g: 0.7, carbsPer100g: 3.7, fatPer100g: 0.2, servingSize: 240, servingDescription: "1 cup"),

        // BEVERAGES - Protein Shakes
        FoodTemplate(name: "Whey Protein Shake", category: .beverages, caloriesPer100g: 133, proteinPer100g: 20, carbsPer100g: 6, fatPer100g: 3, servingSize: 30, servingDescription: "1 scoop"),
        FoodTemplate(name: "Plant Protein Shake", category: .beverages, caloriesPer100g: 120, proteinPer100g: 20, carbsPer100g: 7, fatPer100g: 2, servingSize: 30, servingDescription: "1 scoop"),
        FoodTemplate(name: "Muscle Milk", category: .beverages, caloriesPer100g: 63, proteinPer100g: 6, carbsPer100g: 6, fatPer100g: 2, servingSize: 330, servingDescription: "11 fl oz"),
        FoodTemplate(name: "Premier Protein Shake", category: .beverages, caloriesPer100g: 47, proteinPer100g: 9, carbsPer100g: 1, fatPer100g: 1, servingSize: 325, servingDescription: "11 fl oz"),

        // SNACKS - Protein Bars & Healthy
        FoodTemplate(name: "Quest Protein Bar", category: .snacks, caloriesPer100g: 333, proteinPer100g: 35, carbsPer100g: 38, fatPer100g: 13, servingSize: 60, servingDescription: "1 bar"),
        FoodTemplate(name: "Clif Bar", category: .snacks, caloriesPer100g: 378, proteinPer100g: 16, carbsPer100g: 66, fatPer100g: 9, servingSize: 68, servingDescription: "1 bar"),
        FoodTemplate(name: "Kind Bar", category: .snacks, caloriesPer100g: 450, proteinPer100g: 10, carbsPer100g: 50, fatPer100g: 22, servingSize: 40, servingDescription: "1 bar"),
        FoodTemplate(name: "Granola Bar", category: .snacks, caloriesPer100g: 471, proteinPer100g: 10, carbsPer100g: 64, fatPer100g: 20, servingSize: 28, servingDescription: "1 bar"),
        FoodTemplate(name: "RX Bar", category: .snacks, caloriesPer100g: 400, proteinPer100g: 24, carbsPer100g: 44, fatPer100g: 14, servingSize: 52, servingDescription: "1 bar"),
        FoodTemplate(name: "Protein Cookie", category: .snacks, caloriesPer100g: 450, proteinPer100g: 25, carbsPer100g: 52, fatPer100g: 16, servingSize: 50, servingDescription: "1 cookie"),

        // SNACKS - Chips & Savory
        FoodTemplate(name: "Potato Chips", category: .snacks, caloriesPer100g: 536, proteinPer100g: 7, carbsPer100g: 53, fatPer100g: 34, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Tortilla Chips", category: .snacks, caloriesPer100g: 489, proteinPer100g: 7, carbsPer100g: 66, fatPer100g: 21, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Doritos", category: .snacks, caloriesPer100g: 498, proteinPer100g: 7, carbsPer100g: 63, fatPer100g: 25, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Cheetos", category: .snacks, caloriesPer100g: 571, proteinPer100g: 7, carbsPer100g: 57, fatPer100g: 36, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Pretzels", category: .snacks, caloriesPer100g: 381, proteinPer100g: 10, carbsPer100g: 80, fatPer100g: 3, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Popcorn (air-popped)", category: .snacks, caloriesPer100g: 387, proteinPer100g: 13, carbsPer100g: 78, fatPer100g: 4, servingSize: 8, servingDescription: "1 cup"),
        FoodTemplate(name: "Popcorn (buttered)", category: .snacks, caloriesPer100g: 500, proteinPer100g: 9, carbsPer100g: 57, fatPer100g: 28, servingSize: 11, servingDescription: "1 cup"),
        FoodTemplate(name: "Crackers (saltine)", category: .snacks, caloriesPer100g: 421, proteinPer100g: 9, carbsPer100g: 71, fatPer100g: 10, servingSize: 28, servingDescription: "5 crackers"),
        FoodTemplate(name: "Rice Cakes", category: .snacks, caloriesPer100g: 387, proteinPer100g: 8, carbsPer100g: 82, fatPer100g: 3, servingSize: 9, servingDescription: "1 cake"),

        // SNACKS - Sweet
        FoodTemplate(name: "Dark Chocolate (70-85%)", category: .snacks, caloriesPer100g: 598, proteinPer100g: 7.8, carbsPer100g: 46, fatPer100g: 43, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Milk Chocolate", category: .snacks, caloriesPer100g: 535, proteinPer100g: 8, carbsPer100g: 59, fatPer100g: 30, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "M&M's", category: .snacks, caloriesPer100g: 492, proteinPer100g: 4.5, carbsPer100g: 70, fatPer100g: 21, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Snickers Bar", category: .snacks, caloriesPer100g: 488, proteinPer100g: 9, carbsPer100g: 61, fatPer100g: 24, servingSize: 52, servingDescription: "1 bar"),
        FoodTemplate(name: "Reese's Peanut Butter Cups", category: .snacks, caloriesPer100g: 515, proteinPer100g: 10.5, carbsPer100g: 57, fatPer100g: 29, servingSize: 42, servingDescription: "2 cups"),
        FoodTemplate(name: "Oreo Cookies", category: .snacks, caloriesPer100g: 480, proteinPer100g: 4.7, carbsPer100g: 68, fatPer100g: 21, servingSize: 34, servingDescription: "3 cookies"),
        FoodTemplate(name: "Chips Ahoy Cookies", category: .snacks, caloriesPer100g: 481, proteinPer100g: 5, carbsPer100g: 68, fatPer100g: 21, servingSize: 31, servingDescription: "3 cookies"),
        FoodTemplate(name: "Brownie", category: .snacks, caloriesPer100g: 466, proteinPer100g: 5, carbsPer100g: 63, fatPer100g: 23, servingSize: 56, servingDescription: "1 brownie"),
        FoodTemplate(name: "Donut (glazed)", category: .snacks, caloriesPer100g: 452, proteinPer100g: 5, carbsPer100g: 51, fatPer100g: 25, servingSize: 52, servingDescription: "1 donut"),
        FoodTemplate(name: "Muffin (blueberry)", category: .snacks, caloriesPer100g: 377, proteinPer100g: 6, carbsPer100g: 51, fatPer100g: 17, servingSize: 113, servingDescription: "1 muffin"),
        FoodTemplate(name: "Cupcake", category: .snacks, caloriesPer100g: 305, proteinPer100g: 3.6, carbsPer100g: 45, fatPer100g: 12, servingSize: 50, servingDescription: "1 cupcake"),
        FoodTemplate(name: "Ice Cream (vanilla)", category: .snacks, caloriesPer100g: 207, proteinPer100g: 3.5, carbsPer100g: 24, fatPer100g: 11, servingSize: 132, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Ice Cream (chocolate)", category: .snacks, caloriesPer100g: 216, proteinPer100g: 3.8, carbsPer100g: 28, fatPer100g: 11, servingSize: 132, servingDescription: "1/2 cup"),

        // FAST FOOD - McDonald's
        FoodTemplate(name: "McDonald's Big Mac", category: .fastFood, caloriesPer100g: 257, proteinPer100g: 12, carbsPer100g: 20, fatPer100g: 14, servingSize: 215, servingDescription: "1 sandwich"),
        FoodTemplate(name: "McDonald's Quarter Pounder", category: .fastFood, caloriesPer100g: 244, proteinPer100g: 14, carbsPer100g: 19, fatPer100g: 13, servingSize: 194, servingDescription: "1 sandwich"),
        FoodTemplate(name: "McDonald's Chicken McNuggets", category: .fastFood, caloriesPer100g: 296, proteinPer100g: 15, carbsPer100g: 17, fatPer100g: 19, servingSize: 170, servingDescription: "10 pieces"),
        FoodTemplate(name: "McDonald's French Fries (medium)", category: .fastFood, caloriesPer100g: 323, proteinPer100g: 3.4, carbsPer100g: 43, fatPer100g: 15, servingSize: 117, servingDescription: "medium"),
        FoodTemplate(name: "McDonald's Egg McMuffin", category: .fastFood, caloriesPer100g: 231, proteinPer100g: 13, carbsPer100g: 18, fatPer100g: 11, servingSize: 137, servingDescription: "1 sandwich"),

        // FAST FOOD - Other Chains
        FoodTemplate(name: "Burger King Whopper", category: .fastFood, caloriesPer100g: 252, proteinPer100g: 12, carbsPer100g: 23, fatPer100g: 13, servingSize: 290, servingDescription: "1 sandwich"),
        FoodTemplate(name: "Wendy's Dave's Single", category: .fastFood, caloriesPer100g: 248, proteinPer100g: 14, carbsPer100g: 18, fatPer100g: 13, servingSize: 230, servingDescription: "1 sandwich"),
        FoodTemplate(name: "Chick-fil-A Sandwich", category: .fastFood, caloriesPer100g: 252, proteinPer100g: 14, carbsPer100g: 21, fatPer100g: 13, servingSize: 170, servingDescription: "1 sandwich"),
        FoodTemplate(name: "KFC Original Recipe Chicken", category: .fastFood, caloriesPer100g: 246, proteinPer100g: 18, carbsPer100g: 8, fatPer100g: 16, servingSize: 161, servingDescription: "1 breast"),
        FoodTemplate(name: "Taco Bell Crunchy Taco", category: .fastFood, caloriesPer100g: 213, proteinPer100g: 8, carbsPer100g: 16, fatPer100g: 13, servingSize: 78, servingDescription: "1 taco"),
        FoodTemplate(name: "Taco Bell Burrito Supreme", category: .fastFood, caloriesPer100g: 154, proteinPer100g: 7, carbsPer100g: 18, fatPer100g: 6, servingSize: 248, servingDescription: "1 burrito"),
        FoodTemplate(name: "Subway 6\" Turkey Sub", category: .fastFood, caloriesPer100g: 117, proteinPer100g: 8, carbsPer100g: 16, fatPer100g: 2, servingSize: 238, servingDescription: "6 inch"),
        FoodTemplate(name: "Domino's Pizza (cheese)", category: .fastFood, caloriesPer100g: 266, proteinPer100g: 12, carbsPer100g: 33, fatPer100g: 10, servingSize: 107, servingDescription: "1 slice"),
        FoodTemplate(name: "Pizza Hut Pizza (pepperoni)", category: .fastFood, caloriesPer100g: 285, proteinPer100g: 12, carbsPer100g: 29, fatPer100g: 13, servingSize: 105, servingDescription: "1 slice"),
        FoodTemplate(name: "Chipotle Chicken Bowl", category: .fastFood, caloriesPer100g: 88, proteinPer100g: 7.3, carbsPer100g: 9, fatPer100g: 2.5, servingSize: 500, servingDescription: "1 bowl"),
        FoodTemplate(name: "Panera Bread Bowl", category: .fastFood, caloriesPer100g: 65, proteinPer100g: 2, carbsPer100g: 13, fatPer100g: 1, servingSize: 454, servingDescription: "1 bowl"),
        FoodTemplate(name: "Five Guys Burger", category: .fastFood, caloriesPer100g: 295, proteinPer100g: 13, carbsPer100g: 20, fatPer100g: 18, servingSize: 240, servingDescription: "1 burger"),
        FoodTemplate(name: "In-N-Out Double-Double", category: .fastFood, caloriesPer100g: 234, proteinPer100g: 13, carbsPer100g: 19, fatPer100g: 13, servingSize: 330, servingDescription: "1 burger"),
        FoodTemplate(name: "Popeyes Chicken Sandwich", category: .fastFood, caloriesPer100g: 287, proteinPer100g: 13, carbsPer100g: 24, fatPer100g: 16, servingSize: 219, servingDescription: "1 sandwich"),
        FoodTemplate(name: "Subway Footlong", category: .fastFood, caloriesPer100g: 117, proteinPer100g: 8, carbsPer100g: 16, fatPer100g: 2, servingSize: 476, servingDescription: "12 inch"),
        FoodTemplate(name: "Jimmy John's Turkey Tom", category: .fastFood, caloriesPer100g: 113, proteinPer100g: 9, carbsPer100g: 15, fatPer100g: 2, servingSize: 265, servingDescription: "1 sandwich"),
        FoodTemplate(name: "Qdoba Burrito", category: .fastFood, caloriesPer100g: 145, proteinPer100g: 6, carbsPer100g: 18, fatPer100g: 5, servingSize: 425, servingDescription: "1 burrito"),
        FoodTemplate(name: "Panda Express Orange Chicken", category: .fastFood, caloriesPer100g: 176, proteinPer100g: 7, carbsPer100g: 19, fatPer100g: 8, servingSize: 196, servingDescription: "1 serving"),
        FoodTemplate(name: "Shake Shack ShackBurger", category: .fastFood, caloriesPer100g: 262, proteinPer100g: 12, carbsPer100g: 19, fatPer100g: 15, servingSize: 198, servingDescription: "1 burger"),

        // PROTEINS - Additional Common Meats
        FoodTemplate(name: "Chicken Wings", category: .proteins, caloriesPer100g: 203, proteinPer100g: 30, carbsPer100g: 0, fatPer100g: 8, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Chicken Drumstick", category: .proteins, caloriesPer100g: 172, proteinPer100g: 28, carbsPer100g: 0, fatPer100g: 6, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Ground Chicken", category: .proteins, caloriesPer100g: 143, proteinPer100g: 17, carbsPer100g: 0, fatPer100g: 8, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Lamb Chop", category: .proteins, caloriesPer100g: 282, proteinPer100g: 25, carbsPer100g: 0, fatPer100g: 20, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Venison", category: .proteins, caloriesPer100g: 120, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 2, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Bison", category: .proteins, caloriesPer100g: 146, proteinPer100g: 28, carbsPer100g: 0, fatPer100g: 2.4, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Pepperoni", category: .proteins, caloriesPer100g: 504, proteinPer100g: 23, carbsPer100g: 4, fatPer100g: 44, servingSize: 30, servingDescription: "1 oz"),
        FoodTemplate(name: "Salami", category: .proteins, caloriesPer100g: 407, proteinPer100g: 22, carbsPer100g: 1, fatPer100g: 34, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Hot Dog", category: .proteins, caloriesPer100g: 290, proteinPer100g: 10, carbsPer100g: 3, fatPer100g: 26, servingSize: 57, servingDescription: "1 hot dog"),
        FoodTemplate(name: "Bratwurst", category: .proteins, caloriesPer100g: 297, proteinPer100g: 12, carbsPer100g: 4, fatPer100g: 27, servingSize: 85, servingDescription: "1 link"),
        FoodTemplate(name: "Chorizo", category: .proteins, caloriesPer100g: 455, proteinPer100g: 24, carbsPer100g: 2, fatPer100g: 38, servingSize: 60, servingDescription: "1 link"),
        FoodTemplate(name: "Prosciutto", category: .proteins, caloriesPer100g: 158, proteinPer100g: 27, carbsPer100g: 0, fatPer100g: 5, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Anchovies (canned)", category: .proteins, caloriesPer100g: 210, proteinPer100g: 29, carbsPer100g: 0, fatPer100g: 10, servingSize: 45, servingDescription: "1.5 oz"),
        FoodTemplate(name: "Catfish", category: .proteins, caloriesPer100g: 105, proteinPer100g: 18, carbsPer100g: 0, fatPer100g: 3, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Trout", category: .proteins, caloriesPer100g: 148, proteinPer100g: 21, carbsPer100g: 0, fatPer100g: 7, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Swordfish", category: .proteins, caloriesPer100g: 144, proteinPer100g: 24, carbsPer100g: 0, fatPer100g: 5, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Lobster", category: .proteins, caloriesPer100g: 89, proteinPer100g: 19, carbsPer100g: 0, fatPer100g: 1, servingSize: 145, servingDescription: "1 tail"),
        FoodTemplate(name: "Clams", category: .proteins, caloriesPer100g: 148, proteinPer100g: 26, carbsPer100g: 5, fatPer100g: 2, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Mussels", category: .proteins, caloriesPer100g: 172, proteinPer100g: 24, carbsPer100g: 7, fatPer100g: 4, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Oysters", category: .proteins, caloriesPer100g: 68, proteinPer100g: 7, carbsPer100g: 4, fatPer100g: 2.5, servingSize: 84, servingDescription: "6 oysters"),
        FoodTemplate(name: "Calamari", category: .proteins, caloriesPer100g: 92, proteinPer100g: 16, carbsPer100g: 3, fatPer100g: 1.4, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Imitation Crab", category: .proteins, caloriesPer100g: 81, proteinPer100g: 6, carbsPer100g: 13, fatPer100g: 0.4, servingSize: 85, servingDescription: "3 oz"),

        // PROTEINS - More Plant-Based
        FoodTemplate(name: "Beyond Burger", category: .proteins, caloriesPer100g: 224, proteinPer100g: 18, carbsPer100g: 7, fatPer100g: 14, servingSize: 113, servingDescription: "1 patty"),
        FoodTemplate(name: "Impossible Burger", category: .proteins, caloriesPer100g: 212, proteinPer100g: 17, carbsPer100g: 8, fatPer100g: 12, servingSize: 113, servingDescription: "1 patty"),
        FoodTemplate(name: "Black Bean Burger", category: .proteins, caloriesPer100g: 115, proteinPer100g: 5, carbsPer100g: 16, fatPer100g: 4, servingSize: 90, servingDescription: "1 patty"),
        FoodTemplate(name: "Lima Beans", category: .proteins, caloriesPer100g: 115, proteinPer100g: 8, carbsPer100g: 21, fatPer100g: 0.4, servingSize: 170, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Navy Beans", category: .proteins, caloriesPer100g: 140, proteinPer100g: 8.2, carbsPer100g: 26, fatPer100g: 0.6, servingSize: 182, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "White Beans", category: .proteins, caloriesPer100g: 139, proteinPer100g: 9.7, carbsPer100g: 25, fatPer100g: 0.4, servingSize: 179, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Refried Beans", category: .proteins, caloriesPer100g: 92, proteinPer100g: 5, carbsPer100g: 15, fatPer100g: 1.2, servingSize: 126, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Hummus", category: .proteins, caloriesPer100g: 166, proteinPer100g: 8, carbsPer100g: 14, fatPer100g: 10, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Falafel", category: .proteins, caloriesPer100g: 333, proteinPer100g: 13, carbsPer100g: 32, fatPer100g: 18, servingSize: 51, servingDescription: "1 patty"),

        // GRAINS - More Common Items
        FoodTemplate(name: "Dinner Roll", category: .grains, caloriesPer100g: 291, proteinPer100g: 9, carbsPer100g: 50, fatPer100g: 5, servingSize: 43, servingDescription: "1 roll"),
        FoodTemplate(name: "Croissant", category: .grains, caloriesPer100g: 406, proteinPer100g: 8, carbsPer100g: 45, fatPer100g: 21, servingSize: 67, servingDescription: "1 croissant"),
        FoodTemplate(name: "Biscuit", category: .grains, caloriesPer100g: 353, proteinPer100g: 6, carbsPer100g: 45, fatPer100g: 16, servingSize: 60, servingDescription: "1 biscuit"),
        FoodTemplate(name: "Cornbread", category: .grains, caloriesPer100g: 305, proteinPer100g: 7, carbsPer100g: 45, fatPer100g: 11, servingSize: 60, servingDescription: "1 piece"),
        FoodTemplate(name: "Naan Bread", category: .grains, caloriesPer100g: 262, proteinPer100g: 9, carbsPer100g: 45, fatPer100g: 5, servingSize: 90, servingDescription: "1 naan"),
        FoodTemplate(name: "Flatbread", category: .grains, caloriesPer100g: 275, proteinPer100g: 9, carbsPer100g: 55, fatPer100g: 1, servingSize: 60, servingDescription: "1 piece"),
        FoodTemplate(name: "Breadstick", category: .grains, caloriesPer100g: 376, proteinPer100g: 12, carbsPer100g: 71, fatPer100g: 5, servingSize: 30, servingDescription: "1 stick"),
        FoodTemplate(name: "Garlic Bread", category: .grains, caloriesPer100g: 350, proteinPer100g: 9, carbsPer100g: 40, fatPer100g: 17, servingSize: 50, servingDescription: "1 slice"),
        FoodTemplate(name: "Texas Toast", category: .grains, caloriesPer100g: 310, proteinPer100g: 8, carbsPer100g: 38, fatPer100g: 14, servingSize: 40, servingDescription: "1 slice"),
        FoodTemplate(name: "French Toast", category: .grains, caloriesPer100g: 222, proteinPer100g: 8, carbsPer100g: 28, fatPer100g: 9, servingSize: 65, servingDescription: "1 slice"),
        FoodTemplate(name: "Tater Tots", category: .grains, caloriesPer100g: 166, proteinPer100g: 2, carbsPer100g: 23, fatPer100g: 7, servingSize: 86, servingDescription: "10 pieces"),
        FoodTemplate(name: "Hash Browns", category: .grains, caloriesPer100g: 265, proteinPer100g: 3, carbsPer100g: 35, fatPer100g: 13, servingSize: 100, servingDescription: "1 patty"),
        FoodTemplate(name: "Stuffing/Dressing", category: .grains, caloriesPer100g: 107, proteinPer100g: 3, carbsPer100g: 14, fatPer100g: 4, servingSize: 100, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Croutons", category: .grains, caloriesPer100g: 407, proteinPer100g: 12, carbsPer100g: 74, fatPer100g: 6, servingSize: 30, servingDescription: "1 cup"),
        FoodTemplate(name: "Farro", category: .grains, caloriesPer100g: 123, proteinPer100g: 5, carbsPer100g: 26, fatPer100g: 0.4, servingSize: 165, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Freekeh", category: .grains, caloriesPer100g: 129, proteinPer100g: 5, carbsPer100g: 26, fatPer100g: 1, servingSize: 180, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Millet", category: .grains, caloriesPer100g: 119, proteinPer100g: 3.5, carbsPer100g: 24, fatPer100g: 1, servingSize: 174, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Polenta", category: .grains, caloriesPer100g: 70, proteinPer100g: 1.5, carbsPer100g: 16, fatPer100g: 0.3, servingSize: 125, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Grits", category: .grains, caloriesPer100g: 59, proteinPer100g: 1.5, carbsPer100g: 13, fatPer100g: 0.2, servingSize: 242, servingDescription: "1 cup cooked"),

        // VEGETABLES - More Common Items
        FoodTemplate(name: "Avocado", category: .vegetables, caloriesPer100g: 160, proteinPer100g: 2, carbsPer100g: 9, fatPer100g: 15, servingSize: 100, servingDescription: "1/2 avocado"),
        FoodTemplate(name: "Olives (black)", category: .vegetables, caloriesPer100g: 115, proteinPer100g: 0.8, carbsPer100g: 6, fatPer100g: 11, servingSize: 15, servingDescription: "5 olives"),
        FoodTemplate(name: "Olives (green)", category: .vegetables, caloriesPer100g: 145, proteinPer100g: 1, carbsPer100g: 4, fatPer100g: 15, servingSize: 15, servingDescription: "5 olives"),
        FoodTemplate(name: "Pickles (dill)", category: .vegetables, caloriesPer100g: 11, proteinPer100g: 0.3, carbsPer100g: 2.3, fatPer100g: 0.2, servingSize: 65, servingDescription: "1 pickle"),
        FoodTemplate(name: "Sauerkraut", category: .vegetables, caloriesPer100g: 19, proteinPer100g: 0.9, carbsPer100g: 4.3, fatPer100g: 0.1, servingSize: 142, servingDescription: "1 cup"),
        FoodTemplate(name: "Kimchi", category: .vegetables, caloriesPer100g: 15, proteinPer100g: 1.1, carbsPer100g: 2.4, fatPer100g: 0.5, servingSize: 150, servingDescription: "1 cup"),
        FoodTemplate(name: "Artichoke", category: .vegetables, caloriesPer100g: 47, proteinPer100g: 3.3, carbsPer100g: 11, fatPer100g: 0.2, servingSize: 128, servingDescription: "1 medium"),
        FoodTemplate(name: "Artichoke Hearts (canned)", category: .vegetables, caloriesPer100g: 38, proteinPer100g: 2.4, carbsPer100g: 9, fatPer100g: 0.3, servingSize: 84, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Water Chestnuts", category: .vegetables, caloriesPer100g: 97, proteinPer100g: 1.4, carbsPer100g: 24, fatPer100g: 0.1, servingSize: 124, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Bamboo Shoots", category: .vegetables, caloriesPer100g: 27, proteinPer100g: 2.6, carbsPer100g: 5, fatPer100g: 0.3, servingSize: 131, servingDescription: "1 cup"),
        FoodTemplate(name: "Bean Sprouts", category: .vegetables, caloriesPer100g: 30, proteinPer100g: 3, carbsPer100g: 6, fatPer100g: 0.2, servingSize: 104, servingDescription: "1 cup"),
        FoodTemplate(name: "Bok Choy", category: .vegetables, caloriesPer100g: 13, proteinPer100g: 1.5, carbsPer100g: 2.2, fatPer100g: 0.2, servingSize: 70, servingDescription: "1 cup"),
        FoodTemplate(name: "Snow Peas", category: .vegetables, caloriesPer100g: 42, proteinPer100g: 2.8, carbsPer100g: 7.6, fatPer100g: 0.2, servingSize: 98, servingDescription: "1 cup"),
        FoodTemplate(name: "Sugar Snap Peas", category: .vegetables, caloriesPer100g: 42, proteinPer100g: 2.8, carbsPer100g: 7.6, fatPer100g: 0.2, servingSize: 98, servingDescription: "1 cup"),
        FoodTemplate(name: "Leeks", category: .vegetables, caloriesPer100g: 61, proteinPer100g: 1.5, carbsPer100g: 14, fatPer100g: 0.3, servingSize: 89, servingDescription: "1 leek"),
        FoodTemplate(name: "Shallots", category: .vegetables, caloriesPer100g: 72, proteinPer100g: 2.5, carbsPer100g: 17, fatPer100g: 0.1, servingSize: 10, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Scallions/Green Onions", category: .vegetables, caloriesPer100g: 32, proteinPer100g: 1.8, carbsPer100g: 7, fatPer100g: 0.2, servingSize: 15, servingDescription: "1 onion"),
        FoodTemplate(name: "Chives", category: .vegetables, caloriesPer100g: 30, proteinPer100g: 3.3, carbsPer100g: 4.4, fatPer100g: 0.7, servingSize: 3, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Ginger Root", category: .vegetables, caloriesPer100g: 80, proteinPer100g: 1.8, carbsPer100g: 18, fatPer100g: 0.8, servingSize: 11, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Horseradish", category: .vegetables, caloriesPer100g: 48, proteinPer100g: 1.2, carbsPer100g: 11, fatPer100g: 0.7, servingSize: 15, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Jalapeño (pickled)", category: .vegetables, caloriesPer100g: 27, proteinPer100g: 0.9, carbsPer100g: 5, fatPer100g: 0.4, servingSize: 28, servingDescription: "1 oz"),

        // FRUITS - More Common Items
        FoodTemplate(name: "Avocado (Hass)", category: .fruits, caloriesPer100g: 160, proteinPer100g: 2, carbsPer100g: 9, fatPer100g: 15, servingSize: 100, servingDescription: "1/2 avocado"),
        FoodTemplate(name: "Pomegranate", category: .fruits, caloriesPer100g: 83, proteinPer100g: 1.7, carbsPer100g: 19, fatPer100g: 1.2, servingSize: 87, servingDescription: "1/2 cup seeds"),
        FoodTemplate(name: "Fig", category: .fruits, caloriesPer100g: 74, proteinPer100g: 0.8, carbsPer100g: 19, fatPer100g: 0.3, servingSize: 50, servingDescription: "1 fig"),
        FoodTemplate(name: "Persimmon", category: .fruits, caloriesPer100g: 70, proteinPer100g: 0.6, carbsPer100g: 19, fatPer100g: 0.2, servingSize: 168, servingDescription: "1 fruit"),
        FoodTemplate(name: "Star Fruit", category: .fruits, caloriesPer100g: 31, proteinPer100g: 1, carbsPer100g: 7, fatPer100g: 0.3, servingSize: 91, servingDescription: "1 fruit"),
        FoodTemplate(name: "Lychee", category: .fruits, caloriesPer100g: 66, proteinPer100g: 0.8, carbsPer100g: 17, fatPer100g: 0.4, servingSize: 10, servingDescription: "1 fruit"),
        FoodTemplate(name: "Plantain", category: .fruits, caloriesPer100g: 122, proteinPer100g: 1.3, carbsPer100g: 32, fatPer100g: 0.4, servingSize: 179, servingDescription: "1 medium"),
        FoodTemplate(name: "Applesauce (unsweetened)", category: .fruits, caloriesPer100g: 42, proteinPer100g: 0.2, carbsPer100g: 11, fatPer100g: 0.1, servingSize: 122, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Fruit Cocktail (canned)", category: .fruits, caloriesPer100g: 75, proteinPer100g: 0.4, carbsPer100g: 19, fatPer100g: 0.1, servingSize: 124, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Mandarin Oranges (canned)", category: .fruits, caloriesPer100g: 62, proteinPer100g: 0.6, carbsPer100g: 16, fatPer100g: 0.1, servingSize: 126, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Peaches (canned)", category: .fruits, caloriesPer100g: 54, proteinPer100g: 0.6, carbsPer100g: 14, fatPer100g: 0, servingSize: 124, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Pineapple (canned)", category: .fruits, caloriesPer100g: 57, proteinPer100g: 0.4, carbsPer100g: 15, fatPer100g: 0.1, servingSize: 124, servingDescription: "1/2 cup"),

        // DAIRY - More Items
        FoodTemplate(name: "Buttermilk", category: .dairy, caloriesPer100g: 40, proteinPer100g: 3.3, carbsPer100g: 4.8, fatPer100g: 0.9, servingSize: 245, servingDescription: "1 cup"),
        FoodTemplate(name: "Condensed Milk (sweetened)", category: .dairy, caloriesPer100g: 321, proteinPer100g: 7.9, carbsPer100g: 55, fatPer100g: 8.7, servingSize: 38, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Evaporated Milk", category: .dairy, caloriesPer100g: 134, proteinPer100g: 6.8, carbsPer100g: 10, fatPer100g: 7.6, servingSize: 32, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Whipped Cream", category: .dairy, caloriesPer100g: 257, proteinPer100g: 2.2, carbsPer100g: 12.5, fatPer100g: 23, servingSize: 15, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Cool Whip", category: .dairy, caloriesPer100g: 400, proteinPer100g: 0, carbsPer100g: 28, fatPer100g: 32, servingSize: 9, servingDescription: "2 tbsp"),
        FoodTemplate(name: "String Cheese", category: .dairy, caloriesPer100g: 318, proteinPer100g: 25, carbsPer100g: 3, fatPer100g: 24, servingSize: 28, servingDescription: "1 stick"),
        FoodTemplate(name: "Cheese Curds", category: .dairy, caloriesPer100g: 364, proteinPer100g: 23, carbsPer100g: 3, fatPer100g: 30, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Queso Fresco", category: .dairy, caloriesPer100g: 321, proteinPer100g: 21, carbsPer100g: 4, fatPer100g: 25, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Paneer", category: .dairy, caloriesPer100g: 265, proteinPer100g: 14, carbsPer100g: 6, fatPer100g: 20, servingSize: 56, servingDescription: "2 oz"),
        FoodTemplate(name: "Halloumi", category: .dairy, caloriesPer100g: 316, proteinPer100g: 21, carbsPer100g: 2, fatPer100g: 26, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Velveeta", category: .dairy, caloriesPer100g: 357, proteinPer100g: 18, carbsPer100g: 14, fatPer100g: 25, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Cheese Whiz", category: .dairy, caloriesPer100g: 250, proteinPer100g: 14, carbsPer100g: 11, fatPer100g: 18, servingSize: 32, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Nacho Cheese", category: .dairy, caloriesPer100g: 255, proteinPer100g: 9, carbsPer100g: 10, fatPer100g: 20, servingSize: 60, servingDescription: "1/4 cup"),

        // NUTS & SEEDS - More Items
        FoodTemplate(name: "Trail Mix", category: .nuts, caloriesPer100g: 462, proteinPer100g: 13, carbsPer100g: 45, fatPer100g: 29, servingSize: 38, servingDescription: "1/4 cup"),
        FoodTemplate(name: "Honey Roasted Peanuts", category: .nuts, caloriesPer100g: 569, proteinPer100g: 24, carbsPer100g: 25, fatPer100g: 45, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Candied Pecans", category: .nuts, caloriesPer100g: 489, proteinPer100g: 4, carbsPer100g: 54, fatPer100g: 29, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Candied Walnuts", category: .nuts, caloriesPer100g: 525, proteinPer100g: 8, carbsPer100g: 48, fatPer100g: 35, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Coconut Flakes (sweetened)", category: .nuts, caloriesPer100g: 501, proteinPer100g: 3.2, carbsPer100g: 50, fatPer100g: 33, servingSize: 28, servingDescription: "1/4 cup"),
        FoodTemplate(name: "Coconut Flakes (unsweetened)", category: .nuts, caloriesPer100g: 660, proteinPer100g: 6.9, carbsPer100g: 24, fatPer100g: 65, servingSize: 28, servingDescription: "1/4 cup"),

        // SNACKS - More Common Items
        FoodTemplate(name: "Goldfish Crackers", category: .snacks, caloriesPer100g: 488, proteinPer100g: 9, carbsPer100g: 64, fatPer100g: 20, servingSize: 30, servingDescription: "55 pieces"),
        FoodTemplate(name: "Cheez-Its", category: .snacks, caloriesPer100g: 514, proteinPer100g: 8, carbsPer100g: 58, fatPer100g: 26, servingSize: 30, servingDescription: "27 crackers"),
        FoodTemplate(name: "Wheat Thins", category: .snacks, caloriesPer100g: 464, proteinPer100g: 8, carbsPer100g: 68, fatPer100g: 17, servingSize: 28, servingDescription: "16 crackers"),
        FoodTemplate(name: "Triscuits", category: .snacks, caloriesPer100g: 429, proteinPer100g: 8, carbsPer100g: 68, fatPer100g: 14, servingSize: 28, servingDescription: "6 crackers"),
        FoodTemplate(name: "Ritz Crackers", category: .snacks, caloriesPer100g: 500, proteinPer100g: 6.3, carbsPer100g: 63, fatPer100g: 25, servingSize: 16, servingDescription: "5 crackers"),
        FoodTemplate(name: "Club Crackers", category: .snacks, caloriesPer100g: 500, proteinPer100g: 6.7, carbsPer100g: 60, fatPer100g: 26, servingSize: 14, servingDescription: "4 crackers"),
        FoodTemplate(name: "Graham Crackers", category: .snacks, caloriesPer100g: 423, proteinPer100g: 6.7, carbsPer100g: 77, fatPer100g: 10, servingSize: 28, servingDescription: "2 sheets"),
        FoodTemplate(name: "Animal Crackers", category: .snacks, caloriesPer100g: 458, proteinPer100g: 6.7, carbsPer100g: 74, fatPer100g: 14, servingSize: 30, servingDescription: "8 crackers"),
        FoodTemplate(name: "Vanilla Wafers", category: .snacks, caloriesPer100g: 462, proteinPer100g: 5, carbsPer100g: 73, fatPer100g: 16, servingSize: 30, servingDescription: "8 cookies"),
        FoodTemplate(name: "Nutter Butter", category: .snacks, caloriesPer100g: 492, proteinPer100g: 7.5, carbsPer100g: 63, fatPer100g: 23, servingSize: 28, servingDescription: "2 cookies"),
        FoodTemplate(name: "Fig Newtons", category: .snacks, caloriesPer100g: 348, proteinPer100g: 3.5, carbsPer100g: 71, fatPer100g: 5, servingSize: 31, servingDescription: "2 cookies"),
        FoodTemplate(name: "Gummy Bears", category: .snacks, caloriesPer100g: 325, proteinPer100g: 6.8, carbsPer100g: 77, fatPer100g: 0, servingSize: 40, servingDescription: "10 bears"),
        FoodTemplate(name: "Skittles", category: .snacks, caloriesPer100g: 405, proteinPer100g: 0, carbsPer100g: 91, fatPer100g: 4.4, servingSize: 61, servingDescription: "1 pack"),
        FoodTemplate(name: "Starburst", category: .snacks, caloriesPer100g: 408, proteinPer100g: 0, carbsPer100g: 84, fatPer100g: 8, servingSize: 45, servingDescription: "8 pieces"),
        FoodTemplate(name: "Twizzlers", category: .snacks, caloriesPer100g: 352, proteinPer100g: 3, carbsPer100g: 82, fatPer100g: 1, servingSize: 40, servingDescription: "4 pieces"),
        FoodTemplate(name: "Sour Patch Kids", category: .snacks, caloriesPer100g: 400, proteinPer100g: 0, carbsPer100g: 93, fatPer100g: 0, servingSize: 56, servingDescription: "16 pieces"),
        FoodTemplate(name: "Jelly Beans", category: .snacks, caloriesPer100g: 375, proteinPer100g: 0, carbsPer100g: 93, fatPer100g: 0, servingSize: 40, servingDescription: "35 beans"),
        FoodTemplate(name: "Lifesavers", category: .snacks, caloriesPer100g: 400, proteinPer100g: 0, carbsPer100g: 100, fatPer100g: 0, servingSize: 15, servingDescription: "4 pieces"),
        FoodTemplate(name: "Hershey's Bar", category: .snacks, caloriesPer100g: 531, proteinPer100g: 7, carbsPer100g: 57, fatPer100g: 31, servingSize: 43, servingDescription: "1 bar"),
        FoodTemplate(name: "Kit Kat", category: .snacks, caloriesPer100g: 518, proteinPer100g: 6, carbsPer100g: 63, fatPer100g: 27, servingSize: 42, servingDescription: "1 bar"),
        FoodTemplate(name: "Twix", category: .snacks, caloriesPer100g: 502, proteinPer100g: 4.9, carbsPer100g: 65, fatPer100g: 25, servingSize: 50, servingDescription: "2 bars"),
        FoodTemplate(name: "Milky Way", category: .snacks, caloriesPer100g: 456, proteinPer100g: 4.3, carbsPer100g: 70, fatPer100g: 17, servingSize: 52, servingDescription: "1 bar"),
        FoodTemplate(name: "3 Musketeers", category: .snacks, caloriesPer100g: 449, proteinPer100g: 3.7, carbsPer100g: 75, fatPer100g: 15, servingSize: 60, servingDescription: "1 bar"),
        FoodTemplate(name: "Butterfinger", category: .snacks, caloriesPer100g: 482, proteinPer100g: 7.5, carbsPer100g: 64, fatPer100g: 22, servingSize: 54, servingDescription: "1 bar"),
        FoodTemplate(name: "Baby Ruth", category: .snacks, caloriesPer100g: 485, proteinPer100g: 6.7, carbsPer100g: 62, fatPer100g: 24, servingSize: 60, servingDescription: "1 bar"),
        FoodTemplate(name: "Almond Joy", category: .snacks, caloriesPer100g: 479, proteinPer100g: 4.7, carbsPer100g: 57, fatPer100g: 27, servingSize: 45, servingDescription: "1 bar"),
        FoodTemplate(name: "Mounds Bar", category: .snacks, caloriesPer100g: 469, proteinPer100g: 3.5, carbsPer100g: 58, fatPer100g: 26, servingSize: 49, servingDescription: "1 bar"),
        FoodTemplate(name: "Peanut M&M's", category: .snacks, caloriesPer100g: 519, proteinPer100g: 10, carbsPer100g: 60, fatPer100g: 26, servingSize: 42, servingDescription: "1 pack"),
        FoodTemplate(name: "Pringles", category: .snacks, caloriesPer100g: 536, proteinPer100g: 4, carbsPer100g: 53, fatPer100g: 33, servingSize: 28, servingDescription: "15 chips"),
        FoodTemplate(name: "Sun Chips", category: .snacks, caloriesPer100g: 500, proteinPer100g: 7, carbsPer100g: 60, fatPer100g: 25, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Funyuns", category: .snacks, caloriesPer100g: 536, proteinPer100g: 4, carbsPer100g: 64, fatPer100g: 29, servingSize: 28, servingDescription: "13 rings"),
        FoodTemplate(name: "Smartfood Popcorn", category: .snacks, caloriesPer100g: 536, proteinPer100g: 7, carbsPer100g: 57, fatPer100g: 29, servingSize: 28, servingDescription: "2 cups"),
        FoodTemplate(name: "Pirates Booty", category: .snacks, caloriesPer100g: 536, proteinPer100g: 4, carbsPer100g: 61, fatPer100g: 29, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Veggie Straws", category: .snacks, caloriesPer100g: 500, proteinPer100g: 0, carbsPer100g: 67, fatPer100g: 25, servingSize: 28, servingDescription: "38 straws"),
        FoodTemplate(name: "Beef Jerky", category: .snacks, caloriesPer100g: 410, proteinPer100g: 33, carbsPer100g: 11, fatPer100g: 26, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Slim Jim", category: .snacks, caloriesPer100g: 464, proteinPer100g: 21, carbsPer100g: 7, fatPer100g: 39, servingSize: 26, servingDescription: "1 stick"),
        FoodTemplate(name: "Pepperoni Slices", category: .snacks, caloriesPer100g: 494, proteinPer100g: 20, carbsPer100g: 2, fatPer100g: 45, servingSize: 30, servingDescription: "1 oz"),
        FoodTemplate(name: "String Cheese (Polly-O)", category: .snacks, caloriesPer100g: 280, proteinPer100g: 28, carbsPer100g: 4, fatPer100g: 18, servingSize: 28, servingDescription: "1 stick"),
        FoodTemplate(name: "Babybel Cheese", category: .snacks, caloriesPer100g: 321, proteinPer100g: 21, carbsPer100g: 0, fatPer100g: 26, servingSize: 21, servingDescription: "1 piece"),

        // GRAINS - More Specific Cereals
        FoodTemplate(name: "Cheerios (Original)", category: .grains, caloriesPer100g: 375, proteinPer100g: 12.5, carbsPer100g: 70, fatPer100g: 6.3, servingSize: 28, servingDescription: "1 cup"),
        FoodTemplate(name: "Honey Nut Cheerios", category: .grains, caloriesPer100g: 393, proteinPer100g: 10.7, carbsPer100g: 78, fatPer100g: 5.4, servingSize: 28, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Apple Cinnamon Cheerios", category: .grains, caloriesPer100g: 393, proteinPer100g: 7.1, carbsPer100g: 82, fatPer100g: 3.6, servingSize: 28, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Multigrain Cheerios", category: .grains, caloriesPer100g: 357, proteinPer100g: 10.7, carbsPer100g: 75, fatPer100g: 3.6, servingSize: 28, servingDescription: "1 cup"),
        FoodTemplate(name: "Frosted Cheerios", category: .grains, caloriesPer100g: 400, proteinPer100g: 7.1, carbsPer100g: 82, fatPer100g: 3.6, servingSize: 28, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Frosted Flakes (Kellogg's)", category: .grains, caloriesPer100g: 375, proteinPer100g: 3.6, carbsPer100g: 89, fatPer100g: 0, servingSize: 41, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Corn Flakes (Kellogg's)", category: .grains, caloriesPer100g: 357, proteinPer100g: 7.1, carbsPer100g: 84, fatPer100g: 0.4, servingSize: 28, servingDescription: "1 cup"),
        FoodTemplate(name: "Rice Krispies", category: .grains, caloriesPer100g: 393, proteinPer100g: 7.1, carbsPer100g: 89, fatPer100g: 0, servingSize: 33, servingDescription: "1.25 cups"),
        FoodTemplate(name: "Froot Loops", category: .grains, caloriesPer100g: 393, proteinPer100g: 3.6, carbsPer100g: 86, fatPer100g: 3.6, servingSize: 29, servingDescription: "1 cup"),
        FoodTemplate(name: "Apple Jacks", category: .grains, caloriesPer100g: 393, proteinPer100g: 3.6, carbsPer100g: 86, fatPer100g: 3.6, servingSize: 28, servingDescription: "1 cup"),
        FoodTemplate(name: "Cocoa Puffs", category: .grains, caloriesPer100g: 400, proteinPer100g: 7.1, carbsPer100g: 82, fatPer100g: 3.6, servingSize: 36, servingDescription: "1 cup"),
        FoodTemplate(name: "Trix", category: .grains, caloriesPer100g: 393, proteinPer100g: 3.6, carbsPer100g: 86, fatPer100g: 3.6, servingSize: 28, servingDescription: "1 cup"),
        FoodTemplate(name: "Lucky Charms", category: .grains, caloriesPer100g: 400, proteinPer100g: 7.1, carbsPer100g: 82, fatPer100g: 3.6, servingSize: 36, servingDescription: "1 cup"),
        FoodTemplate(name: "Cinnamon Toast Crunch", category: .grains, caloriesPer100g: 429, proteinPer100g: 3.6, carbsPer100g: 79, fatPer100g: 10.7, servingSize: 31, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Cap'n Crunch", category: .grains, caloriesPer100g: 407, proteinPer100g: 3.6, carbsPer100g: 86, fatPer100g: 7.1, servingSize: 27, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Cap'n Crunch Berries", category: .grains, caloriesPer100g: 400, proteinPer100g: 3.6, carbsPer100g: 86, fatPer100g: 7.1, servingSize: 27, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Raisin Bran", category: .grains, caloriesPer100g: 321, proteinPer100g: 7.1, carbsPer100g: 75, fatPer100g: 3.6, servingSize: 59, servingDescription: "1 cup"),
        FoodTemplate(name: "Corn Pops", category: .grains, caloriesPer100g: 393, proteinPer100g: 3.6, carbsPer100g: 89, fatPer100g: 0, servingSize: 31, servingDescription: "1 cup"),
        FoodTemplate(name: "Special K (Original)", category: .grains, caloriesPer100g: 393, proteinPer100g: 14.3, carbsPer100g: 75, fatPer100g: 1.8, servingSize: 31, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Special K Red Berries", category: .grains, caloriesPer100g: 379, proteinPer100g: 10.7, carbsPer100g: 82, fatPer100g: 1.8, servingSize: 31, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Honey Bunches of Oats", category: .grains, caloriesPer100g: 407, proteinPer100g: 7.1, carbsPer100g: 79, fatPer100g: 7.1, servingSize: 30, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Life Cereal", category: .grains, caloriesPer100g: 379, proteinPer100g: 10.7, carbsPer100g: 75, fatPer100g: 5.4, servingSize: 32, servingDescription: "2/3 cup"),
        FoodTemplate(name: "Chex (Corn)", category: .grains, caloriesPer100g: 393, proteinPer100g: 7.1, carbsPer100g: 86, fatPer100g: 0, servingSize: 31, servingDescription: "1 cup"),
        FoodTemplate(name: "Chex (Rice)", category: .grains, caloriesPer100g: 393, proteinPer100g: 7.1, carbsPer100g: 89, fatPer100g: 0, servingSize: 31, servingDescription: "1.25 cups"),
        FoodTemplate(name: "Chex (Wheat)", category: .grains, caloriesPer100g: 357, proteinPer100g: 10.7, carbsPer100g: 82, fatPer100g: 1.8, servingSize: 47, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Grape Nuts", category: .grains, caloriesPer100g: 379, proteinPer100g: 10.7, carbsPer100g: 82, fatPer100g: 1.8, servingSize: 58, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Wheaties", category: .grains, caloriesPer100g: 357, proteinPer100g: 10.7, carbsPer100g: 79, fatPer100g: 1.8, servingSize: 36, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Kix", category: .grains, caloriesPer100g: 393, proteinPer100g: 7.1, carbsPer100g: 86, fatPer100g: 1.8, servingSize: 30, servingDescription: "1.25 cups"),
        FoodTemplate(name: "Golden Grahams", category: .grains, caloriesPer100g: 407, proteinPer100g: 7.1, carbsPer100g: 82, fatPer100g: 3.6, servingSize: 30, servingDescription: "3/4 cup"),
        FoodTemplate(name: "Cookie Crisp", category: .grains, caloriesPer100g: 407, proteinPer100g: 3.6, carbsPer100g: 86, fatPer100g: 7.1, servingSize: 31, servingDescription: "1 cup"),
        FoodTemplate(name: "Reese's Puffs", category: .grains, caloriesPer100g: 407, proteinPer100g: 7.1, carbsPer100g: 79, fatPer100g: 10.7, servingSize: 36, servingDescription: "3/4 cup"),

        // PROTEINS - Specific Chicken Preparations
        FoodTemplate(name: "Chicken Breast (grilled)", category: .proteins, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Chicken Breast (baked)", category: .proteins, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Chicken Breast (fried)", category: .proteins, caloriesPer100g: 246, proteinPer100g: 27, carbsPer100g: 9, fatPer100g: 11, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Chicken Breast (breaded)", category: .proteins, caloriesPer100g: 223, proteinPer100g: 26, carbsPer100g: 10, fatPer100g: 8, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Chicken Thigh (grilled)", category: .proteins, caloriesPer100g: 209, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 11, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Chicken Thigh (fried)", category: .proteins, caloriesPer100g: 277, proteinPer100g: 24, carbsPer100g: 8, fatPer100g: 17, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Chicken Tenders (breaded)", category: .proteins, caloriesPer100g: 256, proteinPer100g: 18, carbsPer100g: 15, fatPer100g: 14, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Chicken Nuggets (frozen)", category: .proteins, caloriesPer100g: 296, proteinPer100g: 15, carbsPer100g: 17, fatPer100g: 19, servingSize: 100, servingDescription: "5 nuggets"),
        FoodTemplate(name: "Buffalo Wings (fried)", category: .proteins, caloriesPer100g: 290, proteinPer100g: 24, carbsPer100g: 3, fatPer100g: 20, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "BBQ Chicken Wings", category: .proteins, caloriesPer100g: 265, proteinPer100g: 23, carbsPer100g: 10, fatPer100g: 15, servingSize: 100, servingDescription: "3.5 oz"),

        // PROTEINS - Specific Beef Preparations
        FoodTemplate(name: "Ground Beef (95/5 lean)", category: .proteins, caloriesPer100g: 137, proteinPer100g: 23, carbsPer100g: 0, fatPer100g: 5, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Ground Beef (85/15 lean)", category: .proteins, caloriesPer100g: 215, proteinPer100g: 19, carbsPer100g: 0, fatPer100g: 15, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Ground Beef (70/30 lean)", category: .proteins, caloriesPer100g: 332, proteinPer100g: 14, carbsPer100g: 0, fatPer100g: 30, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Steak (grilled)", category: .proteins, caloriesPer100g: 271, proteinPer100g: 25, carbsPer100g: 0, fatPer100g: 19, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Steak (pan-seared)", category: .proteins, caloriesPer100g: 271, proteinPer100g: 25, carbsPer100g: 0, fatPer100g: 19, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "T-Bone Steak", category: .proteins, caloriesPer100g: 247, proteinPer100g: 24, carbsPer100g: 0, fatPer100g: 16, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "New York Strip Steak", category: .proteins, caloriesPer100g: 215, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 11, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Filet Mignon", category: .proteins, caloriesPer100g: 227, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 13, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Beef Roast", category: .proteins, caloriesPer100g: 259, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 17, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Corned Beef", category: .proteins, caloriesPer100g: 251, proteinPer100g: 18, carbsPer100g: 0.5, fatPer100g: 19, servingSize: 56, servingDescription: "2 oz"),
        FoodTemplate(name: "Beef Jerky (Teriyaki)", category: .proteins, caloriesPer100g: 410, proteinPer100g: 33, carbsPer100g: 11, fatPer100g: 26, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Beef Jerky (Original)", category: .proteins, caloriesPer100g: 410, proteinPer100g: 33, carbsPer100g: 11, fatPer100g: 26, servingSize: 28, servingDescription: "1 oz"),

        // PROTEINS - Specific Pork Preparations
        FoodTemplate(name: "Pork Chop (grilled)", category: .proteins, caloriesPer100g: 206, proteinPer100g: 27, carbsPer100g: 0, fatPer100g: 10, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Pork Chop (breaded)", category: .proteins, caloriesPer100g: 267, proteinPer100g: 23, carbsPer100g: 12, fatPer100g: 14, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Pork Ribs (BBQ)", category: .proteins, caloriesPer100g: 361, proteinPer100g: 22, carbsPer100g: 11, fatPer100g: 26, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Pulled Pork", category: .proteins, caloriesPer100g: 242, proteinPer100g: 21, carbsPer100g: 8, fatPer100g: 14, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Pork Sausage (breakfast)", category: .proteins, caloriesPer100g: 339, proteinPer100g: 13, carbsPer100g: 1, fatPer100g: 32, servingSize: 48, servingDescription: "2 links"),
        FoodTemplate(name: "Canadian Bacon", category: .proteins, caloriesPer100g: 147, proteinPer100g: 21, carbsPer100g: 1, fatPer100g: 6, servingSize: 56, servingDescription: "2 slices"),
        FoodTemplate(name: "Bacon (thick cut)", category: .proteins, caloriesPer100g: 541, proteinPer100g: 37, carbsPer100g: 1.4, fatPer100g: 42, servingSize: 34, servingDescription: "2 slices"),
        FoodTemplate(name: "Turkey Bacon", category: .proteins, caloriesPer100g: 225, proteinPer100g: 30, carbsPer100g: 3, fatPer100g: 10, servingSize: 28, servingDescription: "2 slices"),

        // PROTEINS - Specific Fish Preparations
        FoodTemplate(name: "Salmon (grilled)", category: .proteins, caloriesPer100g: 206, proteinPer100g: 22, carbsPer100g: 0, fatPer100g: 13, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Salmon (baked)", category: .proteins, caloriesPer100g: 206, proteinPer100g: 22, carbsPer100g: 0, fatPer100g: 13, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Salmon (smoked)", category: .proteins, caloriesPer100g: 117, proteinPer100g: 18, carbsPer100g: 0, fatPer100g: 4, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Tuna Steak (grilled)", category: .proteins, caloriesPer100g: 144, proteinPer100g: 30, carbsPer100g: 0, fatPer100g: 1, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Tuna (canned in oil)", category: .proteins, caloriesPer100g: 198, proteinPer100g: 29, carbsPer100g: 0, fatPer100g: 8, servingSize: 85, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Tilapia (breaded)", category: .proteins, caloriesPer100g: 206, proteinPer100g: 18, carbsPer100g: 14, fatPer100g: 9, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Fish Sticks (frozen)", category: .proteins, caloriesPer100g: 277, proteinPer100g: 11, carbsPer100g: 22, fatPer100g: 16, servingSize: 100, servingDescription: "4 sticks"),
        FoodTemplate(name: "Shrimp (fried)", category: .proteins, caloriesPer100g: 242, proteinPer100g: 15, carbsPer100g: 13, fatPer100g: 15, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Shrimp (boiled)", category: .proteins, caloriesPer100g: 99, proteinPer100g: 24, carbsPer100g: 0, fatPer100g: 0.3, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Shrimp Cocktail", category: .proteins, caloriesPer100g: 80, proteinPer100g: 17, carbsPer100g: 2, fatPer100g: 0.5, servingSize: 100, servingDescription: "3.5 oz"),

        // EGGS - Specific Preparations
        FoodTemplate(name: "Eggs (scrambled)", category: .proteins, caloriesPer100g: 149, proteinPer100g: 10, carbsPer100g: 2, fatPer100g: 11, servingSize: 122, servingDescription: "2 eggs"),
        FoodTemplate(name: "Eggs (fried)", category: .proteins, caloriesPer100g: 196, proteinPer100g: 14, carbsPer100g: 1, fatPer100g: 15, servingSize: 92, servingDescription: "2 eggs"),
        FoodTemplate(name: "Eggs (poached)", category: .proteins, caloriesPer100g: 143, proteinPer100g: 13, carbsPer100g: 0.8, fatPer100g: 10, servingSize: 100, servingDescription: "2 eggs"),
        FoodTemplate(name: "Eggs (hard boiled)", category: .proteins, caloriesPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatPer100g: 11, servingSize: 100, servingDescription: "2 eggs"),
        FoodTemplate(name: "Eggs (soft boiled)", category: .proteins, caloriesPer100g: 143, proteinPer100g: 12, carbsPer100g: 1, fatPer100g: 10, servingSize: 100, servingDescription: "2 eggs"),
        FoodTemplate(name: "Egg Omelet (plain)", category: .proteins, caloriesPer100g: 154, proteinPer100g: 11, carbsPer100g: 1, fatPer100g: 12, servingSize: 122, servingDescription: "2 eggs"),
        FoodTemplate(name: "Egg Omelet (cheese)", category: .proteins, caloriesPer100g: 196, proteinPer100g: 13, carbsPer100g: 2, fatPer100g: 15, servingSize: 122, servingDescription: "2 eggs"),
        FoodTemplate(name: "Egg White Omelet", category: .proteins, caloriesPer100g: 73, proteinPer100g: 14, carbsPer100g: 2, fatPer100g: 0.5, servingSize: 122, servingDescription: "2 eggs"),
        FoodTemplate(name: "Egg Salad", category: .proteins, caloriesPer100g: 190, proteinPer100g: 8, carbsPer100g: 2, fatPer100g: 17, servingSize: 100, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Deviled Eggs", category: .proteins, caloriesPer100g: 206, proteinPer100g: 9, carbsPer100g: 2, fatPer100g: 18, servingSize: 50, servingDescription: "1 half"),

        // DAIRY - Specific Milk Types
        FoodTemplate(name: "Milk (Whole, Organic)", category: .dairy, caloriesPer100g: 61, proteinPer100g: 3.2, carbsPer100g: 4.8, fatPer100g: 3.3, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Milk (1%)", category: .dairy, caloriesPer100g: 42, proteinPer100g: 3.4, carbsPer100g: 5, fatPer100g: 1, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Chocolate Milk (2%)", category: .dairy, caloriesPer100g: 83, proteinPer100g: 3.2, carbsPer100g: 13, fatPer100g: 2, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Chocolate Milk (Whole)", category: .dairy, caloriesPer100g: 103, proteinPer100g: 3.4, carbsPer100g: 13, fatPer100g: 4, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Strawberry Milk", category: .dairy, caloriesPer100g: 86, proteinPer100g: 3.1, carbsPer100g: 14, fatPer100g: 2, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Lactose-Free Milk (2%)", category: .dairy, caloriesPer100g: 50, proteinPer100g: 3.3, carbsPer100g: 4.7, fatPer100g: 2, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Fairlife Milk (2%)", category: .dairy, caloriesPer100g: 50, proteinPer100g: 5.3, carbsPer100g: 2.5, fatPer100g: 2, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Almond Milk (Vanilla)", category: .dairy, caloriesPer100g: 21, proteinPer100g: 0.4, carbsPer100g: 3.3, fatPer100g: 1, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Almond Milk (Sweetened)", category: .dairy, caloriesPer100g: 25, proteinPer100g: 0.4, carbsPer100g: 4.2, fatPer100g: 1, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Coconut Milk (beverage)", category: .dairy, caloriesPer100g: 19, proteinPer100g: 0, carbsPer100g: 2, fatPer100g: 1.7, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Coconut Milk (canned)", category: .dairy, caloriesPer100g: 230, proteinPer100g: 2.3, carbsPer100g: 6, fatPer100g: 24, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Oat Milk (Vanilla)", category: .dairy, caloriesPer100g: 50, proteinPer100g: 1, carbsPer100g: 8.3, fatPer100g: 1.7, servingSize: 240, servingDescription: "1 cup"),

        // DAIRY - Specific Yogurt Types
        FoodTemplate(name: "Greek Yogurt (Vanilla)", category: .dairy, caloriesPer100g: 97, proteinPer100g: 9, carbsPer100g: 13, fatPer100g: 0.4, servingSize: 170, servingDescription: "1 container"),
        FoodTemplate(name: "Greek Yogurt (Strawberry)", category: .dairy, caloriesPer100g: 90, proteinPer100g: 8, carbsPer100g: 14, fatPer100g: 0.4, servingSize: 170, servingDescription: "1 container"),
        FoodTemplate(name: "Greek Yogurt (Blueberry)", category: .dairy, caloriesPer100g: 88, proteinPer100g: 8, carbsPer100g: 13, fatPer100g: 0.4, servingSize: 170, servingDescription: "1 container"),
        FoodTemplate(name: "Chobani Greek Yogurt (0%)", category: .dairy, caloriesPer100g: 59, proteinPer100g: 10, carbsPer100g: 3.6, fatPer100g: 0.4, servingSize: 170, servingDescription: "1 container"),
        FoodTemplate(name: "Fage Greek Yogurt (0%)", category: .dairy, caloriesPer100g: 59, proteinPer100g: 10, carbsPer100g: 3.6, fatPer100g: 0.4, servingSize: 170, servingDescription: "1 container"),
        FoodTemplate(name: "Fage Greek Yogurt (2%)", category: .dairy, caloriesPer100g: 80, proteinPer100g: 9, carbsPer100g: 4, fatPer100g: 3, servingSize: 170, servingDescription: "1 container"),
        FoodTemplate(name: "Yoplait Original Yogurt", category: .dairy, caloriesPer100g: 88, proteinPer100g: 3.5, carbsPer100g: 15, fatPer100g: 1.2, servingSize: 170, servingDescription: "1 container"),
        FoodTemplate(name: "Dannon Yogurt", category: .dairy, caloriesPer100g: 82, proteinPer100g: 4, carbsPer100g: 14, fatPer100g: 1, servingSize: 170, servingDescription: "1 container"),
        FoodTemplate(name: "Activia Yogurt", category: .dairy, caloriesPer100g: 76, proteinPer100g: 3.5, carbsPer100g: 13, fatPer100g: 1, servingSize: 113, servingDescription: "1 container"),
        FoodTemplate(name: "Skyr Yogurt (Plain)", category: .dairy, caloriesPer100g: 63, proteinPer100g: 11, carbsPer100g: 3, fatPer100g: 0.2, servingSize: 170, servingDescription: "1 container"),

        // GRAINS - Specific Bread Types
        FoodTemplate(name: "White Bread (Wonder)", category: .grains, caloriesPer100g: 266, proteinPer100g: 8.9, carbsPer100g: 49, fatPer100g: 3.2, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "Wheat Bread (Whole Grain)", category: .grains, caloriesPer100g: 247, proteinPer100g: 13, carbsPer100g: 41, fatPer100g: 4.2, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "Multigrain Bread", category: .grains, caloriesPer100g: 265, proteinPer100g: 13, carbsPer100g: 43, fatPer100g: 4, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "Pumpernickel Bread", category: .grains, caloriesPer100g: 250, proteinPer100g: 9, carbsPer100g: 47, fatPer100g: 3, servingSize: 32, servingDescription: "1 slice"),
        FoodTemplate(name: "Italian Bread", category: .grains, caloriesPer100g: 271, proteinPer100g: 9, carbsPer100g: 50, fatPer100g: 3.5, servingSize: 30, servingDescription: "1 slice"),
        FoodTemplate(name: "French Bread", category: .grains, caloriesPer100g: 275, proteinPer100g: 9, carbsPer100g: 52, fatPer100g: 3, servingSize: 32, servingDescription: "1 slice"),
        FoodTemplate(name: "Ciabatta Bread", category: .grains, caloriesPer100g: 271, proteinPer100g: 9, carbsPer100g: 52, fatPer100g: 2, servingSize: 30, servingDescription: "1 slice"),
        FoodTemplate(name: "Brioche Bread", category: .grains, caloriesPer100g: 333, proteinPer100g: 8, carbsPer100g: 50, fatPer100g: 11, servingSize: 40, servingDescription: "1 slice"),
        FoodTemplate(name: "Potato Bread", category: .grains, caloriesPer100g: 266, proteinPer100g: 8, carbsPer100g: 50, fatPer100g: 3, servingSize: 38, servingDescription: "1 slice"),
        FoodTemplate(name: "Cinnamon Raisin Bread", category: .grains, caloriesPer100g: 273, proteinPer100g: 8, carbsPer100g: 52, fatPer100g: 4, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "Gluten-Free Bread", category: .grains, caloriesPer100g: 250, proteinPer100g: 3, carbsPer100g: 48, fatPer100g: 4, servingSize: 32, servingDescription: "1 slice"),
        FoodTemplate(name: "Ezekiel Bread", category: .grains, caloriesPer100g: 250, proteinPer100g: 14, carbsPer100g: 40, fatPer100g: 3, servingSize: 34, servingDescription: "1 slice"),
        FoodTemplate(name: "Honey Wheat Bread", category: .grains, caloriesPer100g: 260, proteinPer100g: 10, carbsPer100g: 45, fatPer100g: 3.5, servingSize: 28, servingDescription: "1 slice"),

        // VEGETABLES - Specific Preparations
        FoodTemplate(name: "Broccoli (steamed)", category: .vegetables, caloriesPer100g: 35, proteinPer100g: 2.4, carbsPer100g: 7, fatPer100g: 0.4, servingSize: 91, servingDescription: "1 cup"),
        FoodTemplate(name: "Broccoli (roasted)", category: .vegetables, caloriesPer100g: 50, proteinPer100g: 3, carbsPer100g: 8, fatPer100g: 2, servingSize: 91, servingDescription: "1 cup"),
        FoodTemplate(name: "Carrots (raw)", category: .vegetables, caloriesPer100g: 41, proteinPer100g: 0.9, carbsPer100g: 10, fatPer100g: 0.2, servingSize: 61, servingDescription: "1 medium"),
        FoodTemplate(name: "Carrots (cooked)", category: .vegetables, caloriesPer100g: 35, proteinPer100g: 0.8, carbsPer100g: 8, fatPer100g: 0.2, servingSize: 78, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Sweet Potato (baked with skin)", category: .vegetables, caloriesPer100g: 90, proteinPer100g: 2, carbsPer100g: 21, fatPer100g: 0.2, servingSize: 130, servingDescription: "1 medium"),
        FoodTemplate(name: "Sweet Potato (mashed)", category: .vegetables, caloriesPer100g: 105, proteinPer100g: 2, carbsPer100g: 21, fatPer100g: 2, servingSize: 200, servingDescription: "1 cup"),
        FoodTemplate(name: "Sweet Potato Fries", category: .vegetables, caloriesPer100g: 180, proteinPer100g: 2, carbsPer100g: 28, fatPer100g: 7, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Potato (baked with skin)", category: .vegetables, caloriesPer100g: 93, proteinPer100g: 2.5, carbsPer100g: 21, fatPer100g: 0.1, servingSize: 173, servingDescription: "1 medium"),
        FoodTemplate(name: "Potato (baked without skin)", category: .vegetables, caloriesPer100g: 77, proteinPer100g: 2, carbsPer100g: 17, fatPer100g: 0.1, servingSize: 156, servingDescription: "1 medium"),
        FoodTemplate(name: "French Fries (fast food)", category: .vegetables, caloriesPer100g: 312, proteinPer100g: 3.4, carbsPer100g: 41, fatPer100g: 15, servingSize: 117, servingDescription: "medium"),
        FoodTemplate(name: "French Fries (frozen, baked)", category: .vegetables, caloriesPer100g: 166, proteinPer100g: 2, carbsPer100g: 26, fatPer100g: 5, servingSize: 85, servingDescription: "10 fries"),

        // CONDIMENTS & SAUCES (new category items)
        FoodTemplate(name: "Ketchup", category: .snacks, caloriesPer100g: 101, proteinPer100g: 1, carbsPer100g: 25, fatPer100g: 0.1, servingSize: 17, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Mustard (Yellow)", category: .snacks, caloriesPer100g: 66, proteinPer100g: 4, carbsPer100g: 6, fatPer100g: 3.5, servingSize: 5, servingDescription: "1 tsp"),
        FoodTemplate(name: "Mustard (Dijon)", category: .snacks, caloriesPer100g: 66, proteinPer100g: 4, carbsPer100g: 6, fatPer100g: 3.5, servingSize: 5, servingDescription: "1 tsp"),
        FoodTemplate(name: "Mayonnaise (regular)", category: .snacks, caloriesPer100g: 680, proteinPer100g: 1, carbsPer100g: 0.6, fatPer100g: 75, servingSize: 15, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Mayonnaise (light)", category: .snacks, caloriesPer100g: 400, proteinPer100g: 0.7, carbsPer100g: 13, fatPer100g: 37, servingSize: 15, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Ranch Dressing", category: .snacks, caloriesPer100g: 533, proteinPer100g: 1.3, carbsPer100g: 8, fatPer100g: 53, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Caesar Dressing", category: .snacks, caloriesPer100g: 467, proteinPer100g: 4, carbsPer100g: 8, fatPer100g: 47, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Italian Dressing", category: .snacks, caloriesPer100g: 333, proteinPer100g: 0, carbsPer100g: 13, fatPer100g: 33, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Balsamic Vinaigrette", category: .snacks, caloriesPer100g: 267, proteinPer100g: 0, carbsPer100g: 20, fatPer100g: 20, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Thousand Island Dressing", category: .snacks, caloriesPer100g: 400, proteinPer100g: 0.7, carbsPer100g: 20, fatPer100g: 36, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Blue Cheese Dressing", category: .snacks, caloriesPer100g: 533, proteinPer100g: 5, carbsPer100g: 5, fatPer100g: 55, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Honey Mustard Dressing", category: .snacks, caloriesPer100g: 400, proteinPer100g: 1, carbsPer100g: 24, fatPer100g: 33, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "BBQ Sauce", category: .snacks, caloriesPer100g: 172, proteinPer100g: 1, carbsPer100g: 41, fatPer100g: 0.5, servingSize: 36, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Hot Sauce", category: .snacks, caloriesPer100g: 13, proteinPer100g: 0.8, carbsPer100g: 1, fatPer100g: 0.5, servingSize: 5, servingDescription: "1 tsp"),
        FoodTemplate(name: "Sriracha", category: .snacks, caloriesPer100g: 93, proteinPer100g: 2, carbsPer100g: 18, fatPer100g: 0.6, servingSize: 17, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Soy Sauce", category: .snacks, caloriesPer100g: 60, proteinPer100g: 6, carbsPer100g: 6, fatPer100g: 0, servingSize: 16, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Teriyaki Sauce", category: .snacks, caloriesPer100g: 120, proteinPer100g: 2, carbsPer100g: 24, fatPer100g: 0, servingSize: 36, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Worcestershire Sauce", category: .snacks, caloriesPer100g: 78, proteinPer100g: 0, carbsPer100g: 19, fatPer100g: 0, servingSize: 17, servingDescription: "1 tbsp"),
        FoodTemplate(name: "Buffalo Sauce", category: .snacks, caloriesPer100g: 33, proteinPer100g: 0, carbsPer100g: 2, fatPer100g: 2.7, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Marinara Sauce", category: .snacks, caloriesPer100g: 60, proteinPer100g: 1.5, carbsPer100g: 10, fatPer100g: 2, servingSize: 125, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Alfredo Sauce", category: .snacks, caloriesPer100g: 213, proteinPer100g: 4, carbsPer100g: 5, fatPer100g: 20, servingSize: 125, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Pesto Sauce", category: .snacks, caloriesPer100g: 467, proteinPer100g: 6, carbsPer100g: 8, fatPer100g: 47, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Salsa (mild)", category: .snacks, caloriesPer100g: 36, proteinPer100g: 1.5, carbsPer100g: 8, fatPer100g: 0.2, servingSize: 60, servingDescription: "1/4 cup"),
        FoodTemplate(name: "Guacamole", category: .snacks, caloriesPer100g: 150, proteinPer100g: 2, carbsPer100g: 9, fatPer100g: 13, servingSize: 60, servingDescription: "1/4 cup"),
        FoodTemplate(name: "Sour Cream (regular)", category: .dairy, caloriesPer100g: 193, proteinPer100g: 2.4, carbsPer100g: 4.6, fatPer100g: 19, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Sour Cream (light)", category: .dairy, caloriesPer100g: 136, proteinPer100g: 3.5, carbsPer100g: 7, fatPer100g: 10, servingSize: 30, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Tartar Sauce", category: .snacks, caloriesPer100g: 467, proteinPer100g: 0.7, carbsPer100g: 13, fatPer100g: 47, servingSize: 28, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Cocktail Sauce", category: .snacks, caloriesPer100g: 100, proteinPer100g: 1, carbsPer100g: 24, fatPer100g: 0.2, servingSize: 30, servingDescription: "2 tbsp"),
    ]

    func searchFoods(query: String, category: FoodCategory? = nil) -> [FoodTemplate] {
        var filtered = foods

        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }

        if !query.isEmpty {
            filtered = filtered.filter { food in
                food.name.localizedCaseInsensitiveContains(query)
            }
        }

        return filtered.sorted { $0.name < $1.name }
    }

    func getFoodsByCategory(_ category: FoodCategory) -> [FoodTemplate] {
        foods.filter { $0.category == category }.sorted { $0.name < $1.name }
    }
}