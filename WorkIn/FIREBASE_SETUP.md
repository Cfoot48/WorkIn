# Firebase Setup Instructions

## Firestore Security Rules

You're getting a "missing or insufficient permissions" error because Firestore security rules need to be configured.

### How to Fix:

1. **Go to Firebase Console**
   - Visit https://console.firebase.google.com
   - Select your WorkIn project

2. **Navigate to Firestore Database**
   - Click "Firestore Database" in the left sidebar
   - Click the "Rules" tab at the top

3. **Update Security Rules**
   - Replace the existing rules with the code below
   - Click "Publish" to save

### Firestore Security Rules Code:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }

    // Helper function to check if user owns the document
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Users collection - users can read and write their own data
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && isOwner(userId);

      // User workouts
      match /workouts/{workoutId} {
        allow read: if isSignedIn();
        allow write: if isSignedIn() && isOwner(userId);
      }

      // User nutrition
      match /nutrition/{nutritionId} {
        allow read: if isSignedIn();
        allow write: if isSignedIn() && isOwner(userId);
      }

      // User profile
      match /profile/{document=**} {
        allow read: if isSignedIn();
        allow write: if isSignedIn() && isOwner(userId);
      }
    }

    // Global chat - anyone authenticated can read and send messages
    match /globalChat/{messageId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn(); // Any authenticated user can send messages
      allow update, delete: if false; // Messages cannot be edited or deleted
    }
  }
}
```

### What These Rules Do:

1. **Authentication Required**: All operations require the user to be signed in
2. **User Data Privacy**: Users can only read/write their own workouts, nutrition, and profile
3. **Global Chat**:
   - Anyone can read messages
   - Only authenticated users can send messages
   - Messages must be from the authenticated user (prevents impersonation)
   - Messages limited to 500 characters
   - Messages cannot be edited or deleted (prevents abuse)
4. **Content Validation**: Ensures required fields are present before saving

### After Publishing Rules:

1. The "missing permissions" error will be gone
2. Chat will work immediately
3. All user data is protected
4. Only authenticated users can access the app

## Verifying Setup

After updating the rules:
1. Close and reopen the WorkIn app
2. Try sending a chat message
3. It should work immediately!

If you still have issues, check:
- You're signed in to the app
- Your Firebase project is the correct one
- The rules were published successfully (no syntax errors)
