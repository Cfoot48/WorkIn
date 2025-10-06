import SwiftUI

struct FoodSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var foodDatabase = FoodDatabase.shared

    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showingManualEntry = false
    @State private var selectedFood: FoodTemplate?
    @State private var servingMultiplier: Double = 1.0
    @State private var selectedMealType: MealType = .breakfast

    let onSelection: (FoodEntry) -> Void

    var body: some View {
        NavigationView {
            VStack {
                // Meal type selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Meal")
                        .font(.headline)
                        .padding(.horizontal)

                    Picker("Meal Type", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Text(mealType.rawValue).tag(mealType)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                .padding(.bottom)

                // Toggle between database search and manual entry
                Picker("Entry Mode", selection: $showingManualEntry) {
                    Text("Search Database").tag(false)
                    Text("Manual Entry").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

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
                FoodDetailView(food: food, mealType: selectedMealType) { entry in
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
        ManualFoodEntryView(mealType: selectedMealType) { entry in
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
    let mealType: MealType
    @State private var servingMultiplier: Double = 1.0
    @State private var customServingSize: String = ""
    @State private var useCustomServing = false

    let onAdd: (FoodEntry) -> Void

    var finalCalories: Double {
        if useCustomServing, let customSize = safeCustomSize {
            return min((food.caloriesPer100g * customSize) / 100, 99999)
        }
        return min(food.caloriesPerServing * servingMultiplier, 99999)
    }

    var finalProtein: Double {
        if useCustomServing, let customSize = safeCustomSize {
            return min((food.proteinPer100g * customSize) / 100, 9999)
        }
        return min(food.proteinPerServing * servingMultiplier, 9999)
    }

    var finalCarbs: Double {
        if useCustomServing, let customSize = safeCustomSize {
            return min((food.carbsPer100g * customSize) / 100, 9999)
        }
        return min(food.carbsPerServing * servingMultiplier, 9999)
    }

    var finalFat: Double {
        if useCustomServing, let customSize = safeCustomSize {
            return min((food.fatPer100g * customSize) / 100, 9999)
        }
        return min(food.fatPerServing * servingMultiplier, 9999)
    }

    private var safeCustomSize: Double? {
        guard let customSize = Double(customServingSize),
              customSize > 0,
              customSize <= 10000,
              customSize.isFinite else {
            return nil
        }
        return customSize
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
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Enter grams", text: $customServingSize)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)

                                if !customServingSize.isEmpty && safeCustomSize == nil {
                                    Text("Please enter a valid amount (1-10,000 grams)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
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
                    .disabled(useCustomServing && safeCustomSize == nil)
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
            fat: finalFat,
            mealType: mealType
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
    let mealType: MealType
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
            calories: min(Double(calories) ?? 0, 99999),
            protein: min(Double(protein) ?? 0, 9999),
            carbs: min(Double(carbs) ?? 0, 9999),
            fat: min(Double(fat) ?? 0, 9999),
            mealType: mealType
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

// MARK: - Barcode Scanner Components

import AVFoundation

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BarcodeScannerViewModel()
    let onBarcodeScanned: (String) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview
                BarcodeCameraPreview(session: viewModel.captureSession)
                    .ignoresSafeArea()

                // Scanning overlay
                VStack {
                    Spacer()

                    // Scanning frame
                    Rectangle()
                        .stroke(Color.green, lineWidth: 3)
                        .frame(width: 280, height: 200)
                        .overlay(
                            VStack {
                                if viewModel.isScanning {
                                    Text("Scanning...")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(8)
                                } else {
                                    Text("Position barcode in frame")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(8)
                                }
                            }
                        )

                    Spacer()

                    // Instructions
                    VStack(spacing: 8) {
                        Text("Align barcode within the frame")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("The barcode will be scanned automatically")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding()
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.torchAvailable {
                        Button(action: { viewModel.toggleTorch() }) {
                            Image(systemName: viewModel.torchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .alert("Camera Access Required", isPresented: $viewModel.showPermissionAlert) {
                Button("Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Please allow camera access in Settings to scan barcodes.")
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            viewModel.startScanning { barcode in
                onBarcodeScanned(barcode)
                dismiss()
            }
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}

// Camera preview layer
struct BarcodeCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// ViewModel for barcode scanner
class BarcodeScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var isScanning = false
    @Published var showPermissionAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    @Published var torchOn = false
    @Published var torchAvailable = false

    let captureSession = AVCaptureSession()
    private var onBarcodeScanned: ((String) -> Void)?

    override init() {
        super.init()
    }

    func startScanning(onBarcodeScanned: @escaping (String) -> Void) {
        self.onBarcodeScanned = onBarcodeScanned

        checkCameraPermission { [weak self] granted in
            if granted {
                self?.setupCaptureSession()
            } else {
                DispatchQueue.main.async {
                    self?.showPermissionAlert = true
                }
            }
        }
    }

    func stopScanning() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
        torchOff()
    }

    func toggleTorch() {
        if torchOn {
            torchOff()
        } else {
            torchOnFunc()
        }
    }

    private func torchOnFunc() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = .on
            torchOn = true
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }

    private func torchOff() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            torchOn = false
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be turned off")
        }
    }

    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }

    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            DispatchQueue.main.async {
                self.errorMessage = "Camera not available"
                self.showErrorAlert = true
            }
            return
        }

        // Check if torch is available
        DispatchQueue.main.async {
            self.torchAvailable = videoCaptureDevice.hasTorch
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Could not create video input"
                self.showErrorAlert = true
            }
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not add video input"
                self.showErrorAlert = true
            }
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .code39]
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not add metadata output"
                self.showErrorAlert = true
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.isScanning = true
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let barcode = readableObject.stringValue else {
            return
        }

        // Vibration feedback
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        // Call the callback with the scanned barcode
        onBarcodeScanned?(barcode)

        // Stop scanning after first successful scan
        stopScanning()
    }
}

// Scanned food detail view
struct ScannedFoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let scannedFood: ScannedFoodData
    let onConfirm: (FoodEntry) -> Void

    @State private var servings: Double = 1.0
    @State private var servingText: String = "1"
    @State private var selectedMealType: MealType = .breakfast

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

                    // Meal type selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Meal")
                            .font(.headline)

                        Picker("Meal Type", selection: $selectedMealType) {
                            ForEach(MealType.allCases, id: \.self) { mealType in
                                Text(mealType.rawValue).tag(mealType)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                    // Serving size selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Servings")
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

                    // Nutrition info per serving
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Nutrition (per 100\(scannedFood.servingUnit))")
                            .font(.headline)

                        VStack(spacing: 12) {
                            NutritionRowView(
                                label: "Calories",
                                value: scannedFood.calories,
                                unit: "cal",
                                color: .orange
                            )

                            NutritionRowView(
                                label: "Protein",
                                value: scannedFood.protein,
                                unit: "g",
                                color: .red
                            )

                            NutritionRowView(
                                label: "Carbs",
                                value: scannedFood.carbs,
                                unit: "g",
                                color: .blue
                            )

                            NutritionRowView(
                                label: "Fat",
                                value: scannedFood.fat,
                                unit: "g",
                                color: .yellow
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                    // Total nutrition (with servings multiplier)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Total (\(String(format: "%.2f", servings)) servings)")
                            .font(.headline)

                        VStack(spacing: 12) {
                            NutritionRowView(
                                label: "Calories",
                                value: scannedFood.calories * servings,
                                unit: "cal",
                                color: .orange,
                                isBold: true
                            )

                            NutritionRowView(
                                label: "Protein",
                                value: scannedFood.protein * servings,
                                unit: "g",
                                color: .red,
                                isBold: true
                            )

                            NutritionRowView(
                                label: "Carbs",
                                value: scannedFood.carbs * servings,
                                unit: "g",
                                color: .blue,
                                isBold: true
                            )

                            NutritionRowView(
                                label: "Fat",
                                value: scannedFood.fat * servings,
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
                        let foodEntry = scannedFood.toFoodEntry(servings: servings, mealType: selectedMealType)
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
    FoodSelectionView { entry in
        print("Added food: \(entry.name)")
    }
}