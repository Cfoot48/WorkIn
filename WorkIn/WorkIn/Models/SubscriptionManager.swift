import Foundation
import RevenueCat
import SuperwallKit
import StoreKit

class SubscriptionManager: NSObject, ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isSubscribed: Bool = false
    @Published var currentOffering: Offering?
    @Published var customerInfo: CustomerInfo?

    private override init() {
        // Initialize in configure()
        super.init()
    }

    // MARK: - Configuration

    func configure() {
        // Configure RevenueCat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_qhYDaDuCpmWIFlePeHHOtWPuXJy")

        // Configure Superwall with options
        let options = SuperwallOptions()
        options.logging.level = .debug
        Superwall.configure(apiKey: "pk_R2s0Tvy_62RLYN-hVK4SM", options: options)

        // Set up delegates
        Purchases.shared.delegate = self

        // Check initial subscription status
        checkSubscriptionStatus()

        // Configure Superwall with RevenueCat
        configureSuperwallWithRevenueCat()

        // Preload Superwall config to ensure dashboard settings are synced
        print("🔄 Superwall: Preloading config for placements...")
        // In Superwall 4.x, preloadPaywalls is synchronous
        Superwall.shared.preloadPaywalls(forPlacements: ["onboarding_complete", "show_paywall"])
        print("✅ Superwall: Config preload initiated")
    }

    private func configureSuperwallWithRevenueCat() {
        // Set up Superwall to use RevenueCat for purchases
        // In Superwall 4.x, the integration happens through the delegate pattern
        Superwall.shared.delegate = self

        print("🔗 Superwall: Connected to RevenueCat via delegate")

        // IMPORTANT: Sync products from RevenueCat to Superwall
        // This makes product pricing available in Superwall paywalls
        Task {
            await syncProductsToSuperwall()
            await updateSuperwallUserAttributes()
        }
    }

    private func syncProductsToSuperwall() async {
        do {
            print("🔄 Syncing RevenueCat products to Superwall...")

            // Fetch offerings from RevenueCat
            let offerings = try await Purchases.shared.offerings()

            guard let currentOffering = offerings.current else {
                print("⚠️ No current offering found in RevenueCat")
                return
            }

            // Get all product identifiers
            let productIds = currentOffering.availablePackages.map { $0.storeProduct.productIdentifier }

            print("📦 Found \(productIds.count) products: \(productIds.joined(separator: ", "))")

            // Superwall will automatically fetch these products from StoreKit
            // when configured with the same product IDs in the dashboard

        } catch {
            print("❌ Failed to sync products: \(error.localizedDescription)")
        }
    }

    // MARK: - Subscription Status

    func checkSubscriptionStatus() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                await MainActor.run {
                    self.customerInfo = customerInfo
                    self.isSubscribed = !customerInfo.entitlements.active.isEmpty
                }

                // Also fetch offerings to ensure products are loaded for Superwall
                await fetchAndCacheOfferings()
            } catch {
                print("❌ Error fetching customer info: \(error.localizedDescription)")
            }
        }
    }

    private func fetchAndCacheOfferings() async {
        do {
            print("🛍️ RevenueCat: Fetching offerings...")
            let offerings = try await Purchases.shared.offerings()

            await MainActor.run {
                self.currentOffering = offerings.current
            }

            if let current = offerings.current {
                print("✅ RevenueCat: Loaded offering '\(current.identifier)' with \(current.availablePackages.count) packages")

                // Log each package for debugging
                for package in current.availablePackages {
                    let product = package.storeProduct
                    print("   📦 Package: \(package.identifier)")
                    print("      Product ID: \(product.productIdentifier)")
                    print("      Price: \(product.localizedPriceString)")
                }
            } else {
                print("⚠️ RevenueCat: No current offering found")

                // Log all available offerings
                print("📋 Available offerings: \(offerings.all.keys.joined(separator: ", "))")
            }
        } catch {
            print("❌ RevenueCat: Failed to fetch offerings: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch Offerings

    func fetchOfferings() async throws -> Offerings {
        return try await Purchases.shared.offerings()
    }

    // MARK: - Purchase

    func purchase(package: Package) async throws -> CustomerInfo {
        let result = try await Purchases.shared.purchase(package: package)
        await MainActor.run {
            self.customerInfo = result.customerInfo
            self.isSubscribed = !result.customerInfo.entitlements.active.isEmpty
        }
        return result.customerInfo
    }

    // MARK: - Restore Purchases

    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        await MainActor.run {
            self.customerInfo = customerInfo
            self.isSubscribed = !customerInfo.entitlements.active.isEmpty
        }
    }

    // MARK: - Superwall Integration

    /// Present Superwall paywall with A/B testing support
    /// This will show the paywall configured in Superwall dashboard
    func presentPaywall(event: String = "show_paywall") {
        // Register placement - Superwall will show the paywall if configured for this placement
        print("🎯 Superwall: About to register placement '\(event)'")
        print("📊 Superwall: Current subscription status: \(isSubscribed)")

        // Log current offerings before showing paywall
        Task {
            await logCurrentProducts()
        }

        // In Superwall 4.x, register is synchronous and returns Void
        // The SDK will automatically show the paywall if configured
        Superwall.shared.register(placement: event)

        print("💰 Superwall: Registered placement '\(event)'")
        print("ℹ️  Check Superwall logs above to see if paywall was presented")
    }

    private func logCurrentProducts() async {
        do {
            let offerings = try await Purchases.shared.offerings()

            print("\n========================================")
            print("📱 PRODUCT IDs FROM REVENUCAT:")
            print("========================================")

            if let current = offerings.current {
                print("✅ Current Offering: '\(current.identifier)'")
                for package in current.availablePackages {
                    print("   📦 \(package.identifier): \(package.storeProduct.productIdentifier)")
                    print("      Price: \(package.storeProduct.localizedPriceString)")
                }
            } else {
                print("⚠️  No current offering found!")
                print("Available offerings: \(offerings.all.keys.joined(separator: ", "))")
            }

            print("========================================\n")
        } catch {
            print("❌ Failed to fetch products: \(error)")
        }
    }

    /// Present paywall for a specific feature
    func presentPaywallForFeature(_ feature: String) {
        presentPaywall(event: "feature_\(feature)")
    }

    private func updateSuperwallUserAttributes() async {
        var attributes: [String: Any] = [:]

        if let customerInfo = customerInfo {
            attributes["is_subscribed"] = !customerInfo.entitlements.active.isEmpty
            attributes["customer_id"] = customerInfo.originalAppUserId

            // Add more attributes for better targeting
            if let activeEntitlements = customerInfo.entitlements.active.first {
                attributes["subscription_status"] = "active"
                attributes["entitlement_id"] = activeEntitlements.key
            } else {
                attributes["subscription_status"] = "free"
            }
        }

        Superwall.shared.setUserAttributes(attributes)
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        DispatchQueue.main.async {
            self.customerInfo = customerInfo
            self.isSubscribed = !customerInfo.entitlements.active.isEmpty
        }

        // Update Superwall attributes
        Task {
            await updateSuperwallUserAttributes()
        }
    }
}

// MARK: - SuperwallDelegate (Handles purchases via RevenueCat)

extension SubscriptionManager: SuperwallDelegate {
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        // Log Superwall events for debugging
        switch eventInfo.event {
        case .paywallOpen:
            print("📱 Superwall: Paywall opened")
        case .paywallClose:
            print("📱 Superwall: Paywall closed")
        case .transactionComplete:
            print("✅ Superwall: Transaction completed")
        case .subscriptionStart:
            print("🎉 Superwall: Subscription started")
        default:
            break
        }
    }

    func handleCustomPaywallAction(withName name: String) {
        print("🔧 Superwall: Custom action triggered: \(name)")
    }
}
