import Foundation

// Run this code to reset onboarding
UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
UserDefaults.standard.removeObject(forKey: "userProfile")
print("✅ Onboarding reset complete!")
print("Delete the app and reinstall, or run this in your app's debug console")
