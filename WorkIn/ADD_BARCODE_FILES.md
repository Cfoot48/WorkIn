# Add Barcode Scanning Files to Xcode Project

The barcode scanning feature has been implemented, but the new files need to be added to the Xcode project manually.

## Files to Add:

### In WorkIn/Components/ folder:
1. `BarcodeScannerView.swift` - Camera-based barcode scanner UI
2. `ScannedFoodDetailView.swift` - View to display scanned food details

### In WorkIn/Models/ folder:
3. `BarcodeNutritionService.swift` - Service to fetch nutrition data from Open Food Facts API

### In WorkIn/ folder:
4. `Info.plist` - Contains camera permission description

## Steps to Add Files in Xcode:

1. Open `WorkIn.xcodeproj` in Xcode
2. Right-click on the `Components` folder in the left sidebar
3. Select "Add Files to 'WorkIn'..."
4. Navigate to `WorkIn/Components/` and select:
   - `BarcodeScannerView.swift`
   - `ScannedFoodDetailView.swift`
5. Make sure "Copy items if needed" is **unchecked** (files are already in place)
6. Make sure "WorkIn" target is **checked**
7. Click "Add"

8. Repeat for the `Models` folder:
   - Right-click on `Models` folder
   - Add `BarcodeNutritionService.swift`

9. For Info.plist:
   - Select the WorkIn project (blue icon at top)
   - Select the WorkIn target
   - Go to "Info" tab
   - If needed, add custom iOS Target Properties:
     - Key: "Privacy - Camera Usage Description"
     - Value: "We need camera access to scan food barcodes and help you track nutrition."

10. Build the project (Cmd+B)

## How to Use:

Once the files are added and the project builds successfully:

1. Go to the **Nutrition** tab
2. Tap the **barcode scanner icon** in the top-left
3. Allow camera permissions when prompted
4. Point the camera at a food barcode (UPC/EAN)
5. The barcode will be scanned automatically
6. Review the nutrition information
7. Adjust servings if needed
8. Tap **"Add to Diary"** to log the food

## API Used:

The barcode scanner uses the **Open Food Facts** API (https://world.openfoodfacts.org/), which is a free, open database of food products from around the world.

- No API key required
- Works with most UPC and EAN barcodes
- Returns nutrition data per 100g
- Includes product names, brands, and images
