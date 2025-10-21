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

                        // Restore Button
                        Button(action: restorePurchases) {
                            HStack {
                                if isRestoring {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Restore Purchases")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .disabled(isRestoring)

                        // Terms and Privacy
                        HStack(spacing: 20) {
                            Button("Terms of Service") {
                                // Open terms
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))

                            Button("Privacy Policy") {
                                // Open privacy
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
            errorMessage = "Failed to load pricing: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func purchase(package: Package) {
        Task {
            do {
                _ = try await subscriptionManager.purchase(package: package)
                dismiss()
            } catch {
                errorMessage = "Purchase failed: \(error.localizedDescription)"
            }
        }
    }

    private func restorePurchases() {
        isRestoring = true
        Task {
            do {
                try await subscriptionManager.restorePurchases()
                if subscriptionManager.isSubscribed {
                    dismiss()
                } else {
                    errorMessage = "No previous purchases found"
                }
            } catch {
                errorMessage = "Restore failed: \(error.localizedDescription)"
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
