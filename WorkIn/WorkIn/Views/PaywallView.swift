import SwiftUI
import RevenueCat
import RevenueCatUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var offerings: Offerings?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isRestoring = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        DesignSystem.Colors.primary,
                        DesignSystem.Colors.primary.opacity(0.7),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 10)

                            Text("WorkIn Premium")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)

                            Text("Unlock Your Full Potential")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 40)

                        // Features
                        VStack(alignment: .leading, spacing: 20) {
                            FeatureRow(
                                icon: "sparkles",
                                title: "Unlimited AI Workouts",
                                description: "Generate personalized workout plans with AI"
                            )

                            FeatureRow(
                                icon: "fork.knife",
                                title: "Unlimited AI Meal Plans",
                                description: "Get custom nutrition plans tailored to your goals"
                            )

                            FeatureRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Advanced Analytics",
                                description: "Track your progress with detailed insights"
                            )

                            FeatureRow(
                                icon: "star.fill",
                                title: "Premium Features",
                                description: "Access all features with no limits"
                            )

                            FeatureRow(
                                icon: "icloud.fill",
                                title: "Cloud Sync",
                                description: "Your data synced across all devices"
                            )
                        }
                        .padding(.horizontal, 24)

                        // Pricing
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                                .padding(40)
                        } else if let offerings = offerings,
                                  let currentOffering = offerings.current {
                            VStack(spacing: 16) {
                                ForEach(currentOffering.availablePackages) { package in
                                    PackageButton(
                                        package: package,
                                        onPurchase: {
                                            purchase(package: package)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        // Restore Purchases Button - Prominent per Apple guidelines
                        Button(action: restorePurchases) {
                            HStack {
                                if isRestoring {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(1.2)
                                } else {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.title3)
                                    Text("Restore Purchases")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            )
                        }
                        .disabled(isRestoring)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        // Terms and Privacy
                        HStack(spacing: 20) {
                            Button("Terms of Service") {
                                if let url = URL(string: "https://sites.google.com/view/theworkinapp/terms-of-service") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))

                            Button("Privacy Policy") {
                                if let url = URL(string: "https://sites.google.com/view/theworkinapp/privacy-policy") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.title2)
                    }
                }
            }
        }
        .task {
            await loadOfferings()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }

    private func loadOfferings() async {
        isLoading = true
        do {
            offerings = try await subscriptionManager.fetchOfferings()
        } catch {
            print("❌ PaywallView: Failed to load offerings - \(error)")
            errorMessage = "Unable to load pricing information. Please check your internet connection and try again."
        }
        isLoading = false
    }

    private func purchase(package: Package) {
        Task {
            do {
                print("💳 PaywallView: Attempting purchase of \(package.storeProduct.productIdentifier)")
                _ = try await subscriptionManager.purchase(package: package)
                print("✅ PaywallView: Purchase successful")
                dismiss()
            } catch {
                print("❌ PaywallView: Purchase failed - \(error)")

                // Provide user-friendly error messages
                let userMessage: String
                let errorDescription = error.localizedDescription.lowercased()

                if errorDescription.contains("temporarily unavailable") {
                    userMessage = "This account is temporarily unavailable. If you're using a test account, please wait a few minutes and try again. This is a temporary Apple server issue."
                } else if errorDescription.contains("unable to complete") {
                    userMessage = "Unable to complete the purchase request. Please try again in a few moments. If the issue persists, please contact support."
                } else if errorDescription.contains("cancelled") || errorDescription.contains("canceled") {
                    userMessage = "Purchase was cancelled."
                } else if errorDescription.contains("network") || errorDescription.contains("internet") {
                    userMessage = "Network error. Please check your internet connection and try again."
                } else {
                    userMessage = "Purchase failed. Please try again or contact support if the issue persists.\n\nError: \(error.localizedDescription)"
                }

                errorMessage = userMessage
            }
        }
    }

    private func restorePurchases() {
        isRestoring = true
        Task {
            do {
                print("🔄 PaywallView: Attempting to restore purchases")
                try await subscriptionManager.restorePurchases()
                if subscriptionManager.isSubscribed {
                    print("✅ PaywallView: Restore successful - subscription found")
                    dismiss()
                } else {
                    print("ℹ️ PaywallView: Restore complete - no active subscriptions found")
                    errorMessage = "No previous purchases found. If you've already subscribed, please wait a few moments for Apple's servers to sync."
                }
            } catch {
                print("❌ PaywallView: Restore failed - \(error)")

                let userMessage: String
                let errorDescription = error.localizedDescription.lowercased()

                if errorDescription.contains("temporarily unavailable") {
                    userMessage = "Account temporarily unavailable. Please wait a few minutes and try again."
                } else if errorDescription.contains("network") || errorDescription.contains("internet") {
                    userMessage = "Network error. Please check your internet connection and try again."
                } else {
                    userMessage = "Unable to restore purchases. Please try again.\n\nError: \(error.localizedDescription)"
                }

                errorMessage = userMessage
            }
            isRestoring = false
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct PackageButton: View {
    let package: Package
    let onPurchase: () -> Void

    private var isPopular: Bool {
        package.storeProduct.subscriptionPeriod?.unit == .month
    }

    var body: some View {
        Button(action: onPurchase) {
            VStack(spacing: 12) {
                if isPopular {
                    Text("MOST POPULAR")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .cornerRadius(4)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.storeProduct.localizedTitle)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        if let intro = package.storeProduct.introductoryDiscount {
                            Text("Start with \(intro.localizedPriceString)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(package.storeProduct.localizedPriceString)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        if let period = package.storeProduct.subscriptionPeriod {
                            Text("per \(period.unit.description)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isPopular ? 0.25 : 0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isPopular ? Color.white : Color.white.opacity(0.3), lineWidth: isPopular ? 2 : 1)
            )
        }
    }
}

#Preview {
    PaywallView()
}
