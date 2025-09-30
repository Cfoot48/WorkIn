import SwiftUI

struct MockAuthenticationView: View {
    @StateObject private var firebaseManager = MockFirebaseManager.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("WorkIn")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Track your fitness journey")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                Spacer()

                // Demo Message
                VStack(spacing: 16) {
                    Text("Firebase Demo Mode")
                        .font(.headline)
                        .foregroundColor(.orange)

                    Text("This is a demo using mock Firebase. Your data will be stored locally during this session.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: {
                        firebaseManager.signInAnonymously()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Demo")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Firebase Setup Instructions
                VStack(spacing: 12) {
                    Text("To use real Firebase:")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Add Firebase SDK to Xcode project")
                        Text("2. Replace GoogleService-Info.plist with your config")
                        Text("3. Update GymBrosApp.swift to use FirebaseManager")
                        Text("4. Enable Authentication and Firestore in Firebase Console")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MockAuthenticationView()
}