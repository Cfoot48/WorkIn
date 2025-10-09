import SwiftUI

struct ScannedFoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let scannedFood: ScannedFoodData
    let onConfirm: (FoodEntry) -> Void

    @State private var servings: Double = 1.0
    @State private var servingText: String = "1"
    @State private var grams: Double = 100
    @State private var gramsText: String = "100"
    @State private var logByServings: Bool = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Product image (if available)
                    if let imageURLString = scannedFood.imageURL,
                       let imageURL = URL(string: imageURLString) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 200)
                                    .cornerRadius(12)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                    .frame(height: 200)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }

                    // Product info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(scannedFood.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        if !scannedFood.brand.isEmpty {
                            Text(scannedFood.brand)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }

                        Text("Barcode: \(scannedFood.barcode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                    // Log by selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Log by")
                            .font(.headline)

                        Picker("Log by", selection: $logByServings) {
                            Text("Servings").tag(true)
                            Text("Grams").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                    // Amount selector
                    if logByServings {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Number of Servings")
                                .font(.headline)

                            HStack {
                                Button(action: {
                                    if servings > 0.25 {
                                        servings -= 0.25
                                        servingText = String(format: "%.2f", servings)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }

                                TextField("Servings", text: $servingText)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 100)
                                    .onChange(of: servingText) { newValue in
                                        if let value = Double(newValue), value > 0 {
                                            servings = value
                                        }
                                    }

                                Button(action: {
                                    servings += 0.25
                                    servingText = String(format: "%.2f", servings)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }

                            Text("1 serving = \(Int(scannedFood.servingSize)) \(scannedFood.servingUnit)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Amount in Grams")
                                .font(.headline)

                            HStack {
                                Button(action: {
                                    if grams > 10 {
                                        grams -= 10
                                        gramsText = String(format: "%.0f", grams)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }

                                TextField("Grams", text: $gramsText)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 100)
                                    .onChange(of: gramsText) { newValue in
                                        if let value = Double(newValue), value > 0 {
                                            grams = value
                                        }
                                    }

                                Button(action: {
                                    grams += 10
                                    gramsText = String(format: "%.0f", grams)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }

                            Text("Enter custom amount in grams")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Nutrition info per serving
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Nutrition (per serving)")
                            .font(.headline)

                        VStack(spacing: 12) {
                            NutritionRowView(
                                label: "Calories",
                                value: scannedFood.caloriesPerServing,
                                unit: "cal",
                                color: .orange
                            )

                            NutritionRowView(
                                label: "Protein",
                                value: scannedFood.proteinPerServing,
                                unit: "g",
                                color: .red
                            )

                            NutritionRowView(
                                label: "Carbs",
                                value: scannedFood.carbsPerServing,
                                unit: "g",
                                color: .blue
                            )

                            NutritionRowView(
                                label: "Fat",
                                value: scannedFood.fatPerServing,
                                unit: "g",
                                color: .yellow
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                    // Total nutrition
                    VStack(alignment: .leading, spacing: 16) {
                        if logByServings {
                            Text("Total (\(String(format: "%.2f", servings)) servings)")
                                .font(.headline)
                        } else {
                            Text("Total (\(String(format: "%.0f", grams))g)")
                                .font(.headline)
                        }

                        VStack(spacing: 12) {
                            NutritionRowView(
                                label: "Calories",
                                value: logByServings ? scannedFood.caloriesPerServing * servings : scannedFood.caloriesPer100g * (grams / 100.0),
                                unit: "cal",
                                color: .orange,
                                isBold: true
                            )

                            NutritionRowView(
                                label: "Protein",
                                value: logByServings ? scannedFood.proteinPerServing * servings : scannedFood.proteinPer100g * (grams / 100.0),
                                unit: "g",
                                color: .red,
                                isBold: true
                            )

                            NutritionRowView(
                                label: "Carbs",
                                value: logByServings ? scannedFood.carbsPerServing * servings : scannedFood.carbsPer100g * (grams / 100.0),
                                unit: "g",
                                color: .blue,
                                isBold: true
                            )

                            NutritionRowView(
                                label: "Fat",
                                value: logByServings ? scannedFood.fatPerServing * servings : scannedFood.fatPer100g * (grams / 100.0),
                                unit: "g",
                                color: .yellow,
                                isBold: true
                            )
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

                    // Add button
                    Button(action: {
                        let foodEntry: FoodEntry
                        if logByServings {
                            foodEntry = scannedFood.toFoodEntry(servings: servings)
                        } else {
                            foodEntry = scannedFood.toFoodEntry(grams: grams)
                        }
                        onConfirm(foodEntry)
                        dismiss()
                    }) {
                        Text("Add to Diary")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Scanned Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NutritionRowView: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    var isBold: Bool = false

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)

                Text(label)
                    .font(isBold ? .body : .subheadline)
                    .fontWeight(isBold ? .semibold : .regular)
            }

            Spacer()

            Text("\(Int(value)) \(unit)")
                .font(isBold ? .body : .subheadline)
                .fontWeight(isBold ? .bold : .regular)
                .foregroundColor(color)
        }
    }
}

#Preview {
    ScannedFoodDetailView(
        scannedFood: ScannedFoodData(
            barcode: "012345678901",
            name: "Greek Yogurt",
            brand: "Chobani",
            caloriesPerServing: 100,
            proteinPerServing: 17,
            carbsPerServing: 6.1,
            fatPerServing: 0.7,
            caloriesPer100g: 59,
            proteinPer100g: 10,
            carbsPer100g: 3.6,
            fatPer100g: 0.4,
            servingSize: 170,
            servingUnit: "g",
            imageURL: nil
        ),
        onConfirm: { _ in }
    )
}
