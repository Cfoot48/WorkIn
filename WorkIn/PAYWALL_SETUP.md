# WorkIn - RevenueCat & Superwall Setup Guide

This guide will help you configure RevenueCat and Superwall for the WorkIn app paywall.

## Prerequisites

- Apple Developer Account
- RevenueCat Account (free tier available)
- Superwall Account (free tier available)
- App Store Connect access

---

## Step 1: Add SDK Dependencies in Xcode

### 1.1 Add RevenueCat SDK
1. Open `WorkIn.xcodeproj` in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter URL: `https://github.com/RevenueCat/purchases-ios`
4. Select version: **5.16.0** or "Up to Next Major Version"
5. Add these products to the WorkIn target:
   - ✅ **RevenueCat**
   - ✅ **RevenueCatUI**
6. Click **Add Package**

### 1.2 Add Superwall SDK
1. Go to **File → Add Package Dependencies** again
2. Enter URL: `https://github.com/superwall/Superwall-iOS`
3. Select version: **3.9.2** or "Up to Next Major Version"
4. Add product to WorkIn target:
   - ✅ **SuperwallKit**
5. Click **Add Package**

---

## Step 2: Configure App Store Connect

### 2.1 Create In-App Purchases
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app (WorkIn - `com.caidfoot.workin`)
3. Go to **Monetization → Subscriptions**
4. Click **+** to create a Subscription Group
   - Name: `WorkIn Premium`
   - Reference Name: `workin_premium_group`

5. Create your subscription products:

   **Monthly Subscription:**
   - Product ID: `workin_premium_monthly`
   - Reference Name: `WorkIn Premium Monthly`
   - Duration: 1 Month
   - Price: $9.99 (or your preferred price)

   **Yearly Subscription (Recommended):**
   - Product ID: `workin_premium_yearly`
   - Reference Name: `WorkIn Premium Yearly`
   - Duration: 1 Year
   - Price: $79.99 (save ~33%)

6. Add localized descriptions for each subscription

---

## Step 3: Set Up RevenueCat

### 3.1 Create RevenueCat Project
1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create a new project: **WorkIn**
3. Add an iOS app:
   - App Name: `WorkIn`
   - Bundle ID: `com.caidfoot.workin`

### 3.2 Get RevenueCat API Key
1. In RevenueCat Dashboard, go to your WorkIn project
2. Navigate to **API Keys** (left sidebar)
3. Copy your **Public SDK Key** (starts with `appl_...`)
4. Save this key - you'll need it in Step 5

### 3.3 Connect to App Store Connect
1. In RevenueCat, go to **App Settings → Apple App Store**
2. Download the **In-App Purchase Key** from App Store Connect:
   - Go to [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api/subs)
   - Under "In-App Purchase", click **+** to generate a key
   - Download the `.p8` file (you can only download it ONCE!)
   - Note the **Key ID** and **Issuer ID**

3. Upload to RevenueCat:
   - Paste the entire `.p8` file content (including BEGIN/END lines)
   - Enter the **Key ID**
   - Enter the **Issuer ID**
   - Click **Save**

### 3.4 Create Products in RevenueCat
1. Go to **Products** in RevenueCat
2. Click **+ New** to add products
3. Add your subscription products:
   - Enter Product ID: `workin_premium_monthly`
   - Enter Product ID: `workin_premium_yearly`
4. RevenueCat will auto-sync with App Store Connect

### 3.5 Create Entitlements
1. Go to **Entitlements** in RevenueCat
2. Create an entitlement:
   - Identifier: `premium`
   - Display Name: `Premium Features`
3. Attach your products to this entitlement

### 3.6 Create Offerings
1. Go to **Offerings** in RevenueCat
2. Create a default offering:
   - Identifier: `default`
   - Description: `WorkIn Premium Subscription`
3. Add packages:
   - Package: `$rc_monthly` → Product: `workin_premium_monthly`
   - Package: `$rc_annual` → Product: `workin_premium_yearly`
4. Make this offering **Current**

---

## Step 4: Set Up Superwall (REQUIRED for A/B Testing)

### 4.1 Create Superwall Account
1. Go to [Superwall Dashboard](https://superwall.com)
2. Create a new app: **WorkIn**
3. Select **iOS** platform

### 4.2 Get Superwall API Key
1. In Superwall Dashboard, go to **Settings → API Keys**
2. Copy your **Public Key** (starts with `pk_...`)
3. Save this key - you'll need it in Step 5

### 4.3 Connect Superwall to RevenueCat
1. In Superwall, go to **Settings → Integrations**
2. Click **RevenueCat**
3. Enter your RevenueCat Public Key (from Step 3.2)
4. Click **Connect**
5. ✅ This allows Superwall to handle purchases through RevenueCat

### 4.4 Design Your Paywall in Superwall Dashboard
1. Go to **Paywalls** in Superwall
2. Click **Create Paywall**
3. Choose a template or start from scratch
4. Customize your paywall:
   - Add your app name and benefits
   - Configure pricing (RevenueCat products will sync)
   - Add images, colors, copy
   - Preview on device

### 4.5 Create Paywall Campaign
1. Go to **Campaigns** in Superwall
2. Click **Create Campaign**
3. Set trigger event: `profile_upgrade_button`
4. Add your paywalls (you can add multiple for A/B testing!)
5. Set traffic split (e.g., 50% Paywall A, 50% Paywall B)
6. Click **Activate Campaign**

### 4.6 Additional Events to Configure
Create campaigns for these events:
- `onboarding_complete` - **PRIMARY**: Shown immediately after user completes onboarding
- `profile_upgrade_button` - When user taps upgrade in profile
- `ai_workout_limit` - When user hits AI workout generation limit
- `ai_nutrition_limit` - When user hits AI nutrition plan limit
- `show_paywall` - General paywall trigger

---

## Step 5: Add API Keys to Your App

### 5.1 Update SubscriptionManager.swift
1. Open `WorkIn/Models/SubscriptionManager.swift`
2. Replace placeholder API keys:

```swift
// Replace this line:
Purchases.configure(withAPIKey: "YOUR_REVENUECAT_API_KEY")

// With your actual RevenueCat Public Key:
Purchases.configure(withAPIKey: "appl_XxXxXxXxXxXxXxXxXx")

// Replace this line:
Superwall.configure(apiKey: "YOUR_SUPERWALL_API_KEY")

// With your actual Superwall Public Key:
Superwall.configure(apiKey: "pk_XxXxXxXxXxXxXxXxXx")
```

---

## Step 6: Test the Paywall

### 6.1 Create Sandbox Test Account
1. Go to [App Store Connect → Users and Access → Sandbox Testers](https://appstoreconnect.apple.com/access/testers)
2. Click **+** to create a test account
3. Fill in details (use a unique email - doesn't need to be real)
4. Note the credentials

### 6.2 Test on Device
1. On your iOS device, go to **Settings → App Store**
2. Sign out of your real Apple ID
3. Scroll down to **Sandbox Account**
4. Sign in with your sandbox test account
5. Run the WorkIn app from Xcode
6. Trigger the paywall (see Step 7 for trigger points)
7. Complete a test purchase (it won't charge you)

### 6.3 Verify Purchase in RevenueCat
1. Go to RevenueCat Dashboard → **Customers**
2. You should see your test user
3. Check that the entitlement is active

---

## Step 7: Trigger the Paywall in Your App

The paywall is already integrated! Here's where it will show:

### Option 1: Show Paywall on AI Features (Recommended)
Update `AIAssistantView.swift` to show paywall before generating:

```swift
// At the top of AIAssistantView
@StateObject private var subscriptionManager = SubscriptionManager.shared
@State private var showingPaywall = false

// In the generate button action:
Button("Generate Workout Plan") {
    if subscriptionManager.isSubscribed {
        // Generate workout
        generateWorkoutPlan()
    } else {
        // Show paywall
        showingPaywall = true
    }
}
.sheet(isPresented: $showingPaywall) {
    PaywallView()
}
```

### Option 2: Show on App Launch (Aggressive)
Add to `ContentView.swift` or `WorkInApp.swift`:

```swift
.onAppear {
    if !subscriptionManager.isSubscribed {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingPaywall = true
        }
    }
}
```

### Option 3: Add Premium Button to Settings
Add to `ProfileView.swift`:

```swift
Button(action: { showingPaywall = true }) {
    HStack {
        Image(systemName: "crown.fill")
            .foregroundColor(.yellow)
        Text("Upgrade to Premium")
            .fontWeight(.bold)
    }
}
.sheet(isPresented: $showingPaywall) {
    PaywallView()
}
```

---

## Step 8: Implement Subscription Checks

### Check if User is Subscribed
```swift
if SubscriptionManager.shared.isSubscribed {
    // Show premium feature
} else {
    // Show paywall or locked UI
}
```

### Observe Subscription Changes
```swift
@StateObject private var subscriptionManager = SubscriptionManager.shared

// In your view:
if subscriptionManager.isSubscribed {
    // Premium features unlocked
}
```

---

## Step 9: Production Checklist

Before going to production:

- [ ] Replace sandbox API keys with production keys
- [ ] Test with real App Store purchases (use promo codes)
- [ ] Add Terms of Service and Privacy Policy links
- [ ] Enable StoreKit receipt validation
- [ ] Set up webhooks in RevenueCat for backend integration
- [ ] Configure Superwall campaigns and triggers
- [ ] Test restore purchases flow
- [ ] Test subscription renewal
- [ ] Test subscription cancellation
- [ ] Add analytics tracking for paywall conversions

---

## Troubleshooting

### "Could not validate your Subscription Key" Error
**Solution:**
- Ensure Bundle ID matches: `com.caidfoot.workin`
- Verify you're using the In-App Purchase Key (not App Store Connect API key)
- Check that Key ID and Issuer ID are correct
- Make sure the `.p8` file content is complete (including BEGIN/END lines)

### Purchases Not Working
**Solution:**
- Sign out of real Apple ID on device
- Sign in with sandbox tester account
- Delete and reinstall the app
- Check RevenueCat logs in Xcode console

### Paywall Not Showing
**Solution:**
- Check that SDKs are added to target
- Verify API keys are correct (not placeholder values)
- Check Xcode console for RevenueCat/Superwall errors
- Ensure `SubscriptionManager.shared.configure()` is called in AppDelegate

---

## Support Resources

- **RevenueCat Docs:** https://www.revenuecat.com/docs
- **Superwall Docs:** https://docs.superwall.com
- **Apple In-App Purchase:** https://developer.apple.com/in-app-purchase/
- **RevenueCat Support:** support@revenuecat.com
- **Superwall Support:** support@superwall.com

---

## Next Steps

1. Complete Step 1-2 in Xcode (add SDKs and configure App Store Connect)
2. Set up RevenueCat account and get API key (Step 3)
3. (Optional) Set up Superwall account and get API key (Step 4)
4. Add your API keys to `SubscriptionManager.swift` (Step 5)
5. Test with sandbox account (Step 6)
6. Choose where to show the paywall (Step 7)
7. Go to production! (Step 9)

Good luck with your launch! 🚀
