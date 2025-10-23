# Paywall Integration Status

**Date:** October 22, 2025
**Status:** ⚠️ ISSUE - User Stuck in Onboarding After Subscribing

## Current Issue

**Problem:** After completing the paywall and subscribing, user gets stuck on the onboarding screen and cannot access the main app.

**What Was Changed:**
- Added subscription requirement to `AuthenticationView.swift` (line 31)
- Changed condition from `!profileStore.hasCompletedOnboarding` to `!profileStore.hasCompletedOnboarding || !subscriptionManager.isSubscribed`
- Added `.onAppear` handler to `OnboardingView.swift` (lines 143-149) that resets to page 6 if onboarding complete but not subscribed

**Expected Behavior:**
1. User completes onboarding → `hasCompletedOnboarding = true`
2. Paywall shows
3. User subscribes → `isSubscribed = true`
4. User should access main app (ContentView)

**Actual Behavior:**
1. User completes onboarding → `hasCompletedOnboarding = true`
2. Paywall shows
3. User subscribes → `isSubscribed = true` (presumably)
4. **User gets stuck in onboarding screen**

**Likely Root Cause:**
- The subscription status update from RevenueCat/Superwall may not be propagating to `SubscriptionManager.isSubscribed` immediately after purchase
- OR there's a timing issue where the view re-renders before `isSubscribed` updates
- OR the `PurchasesDelegate` callback isn't firing to update the subscription status

## Previous Resolution (Cached Subscription Issue)

**Previous Root Cause:** Cached subscription data on the device was causing the paywall to not display. The device still thought it had an active subscription from a previous test.

**Previous Solution:** Manually remove the subscription from the device settings:
- Settings → App Store → [Your Apple ID] → Subscriptions → Cancel subscription
- Note: Resetting subscription data through Apple Connect may not always clear the device cache properly

---

## Current Situation

The paywall is **not displaying** when users complete onboarding, even though the code is working correctly. The issue is a **configuration problem in the Superwall dashboard**, not a code problem.

---

## What's Happening in the Code

### 1. User Flow
1. User authenticates with Firebase (email/password, Google, or Apple)
2. User goes through onboarding (`OnboardingView.swift`)
3. User fills out profile information (name, height, weight, goals, etc.)
4. User clicks "Complete" button
5. Profile is saved to Firestore with `hasCompletedOnboarding = true`
6. Code calls `SubscriptionManager.shared.presentPaywall(event: "onboarding_complete")`
7. **Paywall should show but doesn't**

### 2. Current Code State

**File: `OnboardingView.swift`**
```swift
private func completeOnboarding() async {
    // ... validation and moderation code ...

    // Update profile
    await MainActor.run {
        profileStore.profile.displayName = displayName
        profileStore.profile.height = heightValue
        profileStore.profile.currentWeight = currentWeightValue
        profileStore.profile.goalWeight = goalWeightValue
        profileStore.profile.dailyCalories = calculatedCalories
        profileStore.profile.dailyProtein = proteinValue
        profileStore.profile.weeklyWorkoutGoal = weeklyWorkoutsValue

        // Mark onboarding as complete
        isCompleted = true  // ← Sets hasCompletedOnboarding = true
    }

    // Save to Firestore
    await profileStore.saveProfileExplicitly()

    // Show paywall
    SubscriptionManager.shared.presentPaywall(event: "onboarding_complete")  // ← This is called
}
```

**File: `AuthenticationView.swift`**
```swift
var body: some View {
    Group {
        if authManager.isAuthenticated {
            if profileStore.isLoadingProfile {
                // Show loading spinner
                ProgressView()
            } else if !profileStore.hasCompletedOnboarding {
                // Show onboarding (includes paywall at the end)
                OnboardingView(
                    profileStore: profileStore,
                    isCompleted: $profileStore.hasCompletedOnboarding
                )
            } else {
                // User has completed onboarding → show main app
                ContentView()
            }
        } else {
            // Show sign in/sign up
        }
    }
}
```

**Key Point:** The condition checks **ONLY** `hasCompletedOnboarding`, **NOT** subscription status. This means:
- ✅ Once `hasCompletedOnboarding = true`, user can access the app
- ❌ Subscription status is NOT blocking app access
- ⚠️ User can dismiss the paywall and still access the app

---

## What's Happening in Superwall SDK

### Debug Logs Show:

```
🔄 Superwall: Preloading config for placements...
✅ Superwall: Config preload initiated
🎯 Superwall: About to register placement 'onboarding_complete'
📊 Superwall: Current subscription status: false
💰 Superwall: Registered placement 'onboarding_complete'
🎭 Superwall Event: paywallResponseLoad_start
🔄 Superwall: Loading paywall response...
```

**What this means:**
1. ✅ Superwall SDK is configured correctly
2. ✅ Superwall receives the `register(placement:)` call
3. ✅ Superwall fires the `paywallResponseLoad_start` event
4. ❌ **No paywall UI appears**

### Why No Paywall Appears

The logs show `paywallResponseLoad_start` but never show `paywallOpen` or `paywallResponseLoad_complete`. This indicates:

**The "onboarding_complete" placement is NOT configured in the Superwall dashboard.**

---

## The Problem: Superwall Dashboard Configuration

### What's Missing:
1. **Placement Setup:** The "onboarding_complete" placement exists in code but not in the Superwall dashboard
2. **Paywall Assignment:** No paywall design is attached to this placement
3. **Rules Configuration:** No rules are set up to determine when to show the paywall

### What Needs to Be Done:
1. Log in to [Superwall Dashboard](https://superwall.com/dashboard)
2. Navigate to **Placements** section
3. Create a new placement called **"onboarding_complete"**
4. Attach a paywall design to this placement
5. Set rules (recommended: show to all users when placement is triggered)
6. Publish the changes

---

## Detailed Technical Analysis

### Superwall Configuration in Code

**File: `SubscriptionManager.swift:21-45`**
```swift
func configure() {
    // Configure RevenueCat
    Purchases.logLevel = .debug
    Purchases.configure(withAPIKey: "appl_qhYDaDuCpmWIFlePeHHOtWPuXJy")

    // Configure Superwall with options
    let options = SuperwallOptions()
    options.logging.level = .debug  // ← Debug logging enabled
    Superwall.configure(apiKey: "pk_R2s0Tvy_62RLYN-hVK4SM", options: options)

    // Set up delegates
    Purchases.shared.delegate = self

    // Check initial subscription status
    checkSubscriptionStatus()

    // Configure Superwall with RevenueCat
    configureSuperwallWithRevenueCat()

    // Preload Superwall config
    Superwall.shared.preloadPaywalls(forPlacements: ["onboarding_complete", "show_paywall"])
}
```

**File: `SubscriptionManager.swift:173-189`**
```swift
func presentPaywall(event: String = "show_paywall") {
    print("🎯 Superwall: About to register placement '\(event)'")
    print("📊 Superwall: Current subscription status: \(isSubscribed)")

    // Log current offerings before showing paywall
    Task {
        await logCurrentProducts()
    }

    // Register placement - Superwall SDK handles the rest
    Superwall.shared.register(placement: event)

    print("💰 Superwall: Registered placement '\(event)'")
    print("ℹ️  Check Superwall logs above to see if paywall was presented")
}
```

### RevenueCat Configuration

**API Keys:**
- RevenueCat API Key: `appl_qhYDaDuCpmWIFlePeHHOtWPuXJy`
- Superwall API Key: `pk_R2s0Tvy_62RLYN-hVK4SM`

**Integration:**
- ✅ RevenueCat is configured
- ✅ Superwall is configured with RevenueCat delegate
- ✅ Products are being synced from RevenueCat to Superwall
- ✅ Subscription status is being tracked

---

## Current User Experience

### What Users See:
1. Sign up/Sign in screen ✅
2. Onboarding screens (4 pages) ✅
3. Profile information entry ✅
4. Click "Complete" button ✅
5. **Brief pause (paywall is supposed to show but doesn't)** ❌
6. Main app screen appears ✅

### What Users Should See:
1. Sign up/Sign in screen ✅
2. Onboarding screens (4 pages) ✅
3. Profile information entry ✅
4. Click "Complete" button ✅
5. **Paywall appears with subscription options** ❌ (NOT HAPPENING)
6. User subscribes or dismisses paywall
7. Main app screen appears

---

## Issues with Current Implementation

### Issue 1: App Access Without Subscription
**Problem:** `AuthenticationView` only checks `hasCompletedOnboarding`, not subscription status.

**Current Code:**
```swift
else if !profileStore.hasCompletedOnboarding {
    OnboardingView(...)
} else {
    ContentView()  // ← User can access app without subscribing
}
```

**Impact:**
- User can complete onboarding
- Paywall shows (once configured)
- User can dismiss paywall without subscribing
- User still accesses the app

**To Require Subscription:**
```swift
else if !profileStore.hasCompletedOnboarding || !subscriptionManager.isSubscribed {
    // Show onboarding or paywall
} else {
    ContentView()  // ← Only accessible with subscription
}
```

⚠️ **WARNING:** Previous attempts to implement this check broke the paywall presentation. The issue was view lifecycle conflicts with `@ObservedObject` and `onChange` listeners.

### Issue 2: Paywall Back Button Behavior
**Current Behavior:** If user taps back button on paywall, it dismisses and user enters app.

**Desired Behavior:** Back button should return to onboarding final page.

**Status:** Not implemented (would require Superwall dashboard configuration or custom paywall handler)

---

## History of Changes (Last Session)

### Attempt 1: Add Subscription Check to AuthenticationView
- **Change:** Added `@ObservedObject var subscriptionManager` and checked `!subscriptionManager.isSubscribed`
- **Result:** Paywall stopped showing entirely
- **Reason:** View lifecycle issues

### Attempt 2: Add onChange Listener
- **Change:** Added `.onChange(of: subscriptionManager.isSubscribed)` to trigger navigation
- **Result:** Paywall still didn't show
- **Reason:** Race condition with subscription checking

### Attempt 3: Set isCompleted After Paywall
- **Change:** Moved `isCompleted = true` to AFTER paywall presentation
- **Result:** User stuck in onboarding, couldn't progress
- **Reason:** Paywall never showed, so flag never set

### Attempt 4: Multiple Variations
- Tried various combinations of checks, listeners, and timing
- All attempts either broke paywall or broke navigation

### Final Action: Reverted to Git Commit 36238d6
- **Result:** Paywall shows correctly (when configured in dashboard)
- **Current State:**
  - ✅ Onboarding works
  - ✅ Profile saves
  - ✅ Paywall is triggered (but not configured in dashboard)
  - ❌ No subscription requirement to access app

---

## Next Steps

### Immediate Actions Required:

1. **Configure Superwall Dashboard**
   - Create "onboarding_complete" placement
   - Attach paywall design
   - Set up display rules
   - Publish changes

2. **Test Paywall Display**
   - Run app in simulator
   - Complete onboarding
   - Verify paywall appears
   - Test subscription flow

3. **Add Subscription Requirement (Optional)**
   - Only if you want to force users to subscribe
   - Requires careful implementation to avoid breaking paywall
   - Alternative: Use "soft paywall" (show but don't enforce)

### Alternative Solutions:

**Option A: Soft Paywall (Current)**
- ✅ User sees paywall after onboarding
- ✅ User can dismiss and use app
- ❌ No subscription required

**Option B: Hard Paywall**
- ✅ User sees paywall after onboarding
- ❌ User cannot access app without subscribing
- ⚠️ Requires complex implementation (previous attempts failed)

**Option C: Feature Gating**
- ✅ User can access basic features without subscription
- ✅ Premium features require subscription
- ✅ Check `subscriptionManager.isSubscribed` before showing premium features
- ✅ Easier to implement than hard paywall

---

## Code References

### Key Files:
- **`SubscriptionManager.swift`** - RevenueCat & Superwall configuration
- **`OnboardingView.swift`** - Triggers paywall on completion
- **`AuthenticationView.swift`** - Navigation logic
- **`UserProfileStore.swift`** - Profile data and Firestore sync

### Important Line Numbers:
- `SubscriptionManager.swift:21-45` - SDK configuration
- `SubscriptionManager.swift:173-189` - Paywall presentation
- `OnboardingView.swift` (completeOnboarding function) - Triggers paywall
- `AuthenticationView.swift:14-42` - Navigation conditions

---

## Superwall SDK Events (From Debug Logs)

### Events That Fire:
1. ✅ `app_install` - App first launch
2. ✅ `app_open` - App opened
3. ✅ `config_refresh` - Superwall config downloaded
4. ✅ `session_start` - User session started
5. ✅ `enrichment_complete` - User data enriched
6. ✅ `subscriptionStatus_didChange` - Status: INACTIVE
7. ✅ `paywallResponseLoad_start` - Attempting to load paywall
8. ❌ `paywallResponseLoad_complete` - Never fires (paywall not configured)
9. ❌ `paywallOpen` - Never fires (paywall not configured)

### What This Means:
The Superwall SDK is working correctly and attempting to show the paywall, but there's no paywall configured in the dashboard for the "onboarding_complete" placement.

---

## Summary

**Root Cause:** ~~The "onboarding_complete" placement is not configured in the Superwall dashboard.~~ ~~Cached subscription data on the device.~~ **CURRENT ISSUE:** Subscription status not updating after purchase, causing user to be stuck in onboarding.

**Code Status:** ⚠️ Subscription requirement added but not working correctly

**Dashboard Status:** ✅ Configured correctly

**Subscription Cache:** ✅ Resolved by manually removing from device settings

**User Impact:** User completes onboarding and subscribes via paywall but gets stuck on onboarding screen instead of accessing the app

**Solution Needed:** Fix subscription status propagation after purchase. Possible approaches:
1. Debug why `PurchasesDelegate.purchases(_:receivedUpdated:)` isn't firing
2. Check if RevenueCat transaction is completing successfully
3. Add explicit subscription refresh after paywall dismisses
4. Verify Superwall is properly integrated with RevenueCat purchases

**Additional Consideration:** The subscription requirement IS now enforced in code (AuthenticationView line 31), but the status update after purchase isn't working.

---

## Important Note for Testing

When testing subscription flows, remember:

1. **Apple Connect subscription reset may not fully clear device cache**
2. **Always manually check device subscription settings:**
   - Settings → App Store → [Your Apple ID] → Subscriptions
3. **For simulator testing:** Delete and reinstall the app to clear all data
4. **For device testing:** Manually cancel subscriptions from Settings app

This is a common issue with StoreKit testing and can cause confusion when the paywall logic is actually working correctly.

---

## Contact & Resources

- **Superwall Documentation:** https://docs.superwall.com
- **RevenueCat Documentation:** https://docs.revenuecat.com
- **Superwall Dashboard:** https://superwall.com/dashboard
- **RevenueCat Dashboard:** https://app.revenuecat.com

---

## Code Changes Made (October 22, 2025)

### AuthenticationView.swift
```swift
// BEFORE (line 26):
} else if !profileStore.hasCompletedOnboarding {

// AFTER (line 31):
} else if !profileStore.hasCompletedOnboarding || !subscriptionManager.isSubscribed {
```

This change enforces subscription requirement. ContentView only shows when BOTH conditions are true:
- `hasCompletedOnboarding = true`
- `isSubscribed = true`

### OnboardingView.swift
Added `.onAppear` handler (lines 143-149):
```swift
.onAppear {
    // If onboarding is marked complete but user isn't subscribed,
    // they dismissed the paywall - show them the final page again
    if isCompleted && !SubscriptionManager.shared.isSubscribed {
        currentPage = 6
    }
}
```

This ensures that if a user dismisses the paywall without subscribing, they're returned to page 6 to try again.

**Issue:** These changes work to enforce subscription requirement, but the subscription status doesn't update after purchase, leaving user stuck in onboarding.

---

**Last Updated:** October 22, 2025
**Git Commit:** Changes made but not committed (subscription requirement added)
