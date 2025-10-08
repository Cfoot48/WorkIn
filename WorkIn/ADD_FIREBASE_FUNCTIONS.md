# Add Firebase Functions Package to Xcode

Since I can't modify the Xcode project file directly, follow these steps to add Firebase Functions:

## Steps:

1. **Open WorkIn.xcodeproj in Xcode**

2. **Add Firebase Functions Package**:
   - Go to File → Add Package Dependencies (or click the + button in the project navigator under "Package Dependencies")
   - The Firebase package should already be there
   - Find **FirebaseFunctions** in the package products list
   - Check the box next to **FirebaseFunctions**
   - Click "Add Package"

3. **Verify the import**:
   - Build the project (Cmd+B)
   - The `import FirebaseFunctions` error should be gone

## Alternative Method:

If the package isn't showing up:

1. Click on the **WorkIn** project in the navigator
2. Select the **WorkIn** target
3. Go to **Frameworks, Libraries, and Embedded Content**
4. Click the **+** button
5. Search for "Firebase Functions"
6. Add **FirebaseFunctions** to the target

## After Adding:

The Swift code is already updated to use Cloud Functions. Once you:
1. Add the FirebaseFunctions package (above)
2. Deploy the Cloud Functions (see PERSPECTIVE_API_SETUP.md)
3. The chat will use Perspective API for content moderation!

## Current Status:

✅ Cloud Function created (`functions/index.js`)
✅ Swift code updated to call Cloud Function
✅ Firestore rules updated
✅ Setup documentation created
⏳ **YOU NEED TO**: Add FirebaseFunctions package to Xcode (steps above)
⏳ **YOU NEED TO**: Deploy functions (see PERSPECTIVE_API_SETUP.md)
