import Foundation
import UserNotifications
import RevenueCat

class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private let freeTrialReminderIdentifier = "free_trial_reminder"
    private let trialReminderUserDefaultsKey = "trial_reminder_scheduled"

    private override init() {
        super.init()
    }

    // MARK: - Request Notification Permission

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("🔔 Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("⚠️ Notification permission denied by user")
            }
        }
    }

    // MARK: - Schedule Free Trial Reminder

    /// Schedules a notification to remind the user 2 days after their free trial starts
    /// This gives them a 5-day warning before a typical 7-day trial ends
    func scheduleFreeTrialReminder(customerInfo: CustomerInfo) {
        // Check if we've already scheduled a reminder for this user
        if UserDefaults.standard.bool(forKey: trialReminderUserDefaultsKey) {
            print("📅 Free trial reminder already scheduled, skipping")
            return
        }

        // Check if user has an active entitlement with a free trial
        guard let activeEntitlement = customerInfo.entitlements.active.first?.value else {
            print("⚠️ No active entitlement found, cannot schedule reminder")
            return
        }

        // Check if this is a free trial (has expiration date and will renew)
        guard let expirationDate = activeEntitlement.expirationDate else {
            print("⚠️ No expiration date found, likely not a trial")
            return
        }

        // Calculate if this is likely a free trial
        // Trials typically have an expiration date and originalPurchaseDate close together
        let now = Date()
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: now, to: expirationDate).day ?? 0

        // If subscription expires in 3-14 days from now, assume it's a free trial
        // (giving some flexibility for different trial lengths)
        guard daysUntilExpiration >= 3 && daysUntilExpiration <= 14 else {
            print("ℹ️ Subscription doesn't appear to be a free trial (expires in \(daysUntilExpiration) days)")
            return
        }

        print("📅 Detected free trial subscription expiring in \(daysUntilExpiration) days")

        // Schedule notification for 2 days from now
        let triggerDate = Calendar.current.date(byAdding: .day, value: 2, to: now)!

        let content = UNMutableNotificationContent()
        content.title = "Free Trial Reminder"
        content.body = "Your free trial will end in \(daysUntilExpiration - 2) days. Your subscription will automatically renew unless you cancel."
        content.sound = .default
        content.badge = 1

        // Create date components for the trigger
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        // Create the request
        let request = UNNotificationRequest(
            identifier: freeTrialReminderIdentifier,
            content: content,
            trigger: trigger
        )

        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule free trial reminder: \(error.localizedDescription)")
            } else {
                print("✅ Free trial reminder scheduled for \(triggerDate)")
                // Mark as scheduled
                UserDefaults.standard.set(true, forKey: self.trialReminderUserDefaultsKey)
            }
        }
    }

    // MARK: - Cancel Free Trial Reminder

    func cancelFreeTrialReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [freeTrialReminderIdentifier])
        UserDefaults.standard.set(false, forKey: trialReminderUserDefaultsKey)
        print("🗑️ Free trial reminder cancelled")
    }

    // MARK: - Reset on Sign Out

    func resetNotificationState() {
        cancelFreeTrialReminder()
        UserDefaults.standard.removeObject(forKey: trialReminderUserDefaultsKey)
        print("🔄 Notification state reset")
    }
}
