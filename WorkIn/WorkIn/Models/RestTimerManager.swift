import Foundation
import UIKit
import UserNotifications
import Combine

/// Manager for rest timers that works in background and sends notifications
class RestTimerManager: ObservableObject {
    static let shared = RestTimerManager()

    @Published var timeRemaining: Double = 0
    @Published var isActive: Bool = false
    @Published var totalTime: Double = 0

    private var timerEndDate: Date?
    private var cancellables = Set<AnyCancellable>()
    private var displayTimer: Timer?

    private init() {
        // Set up observer to update UI when app returns from background
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.updateTimeRemaining()
            }
            .store(in: &cancellables)
    }

    // MARK: - Timer Control

    func startTimer(duration: Double) {
        print("⏱️ RestTimer: Starting timer for \(Int(duration)) seconds")

        // Stop any existing timer
        stopTimer(silent: true)

        // Set timer end date
        timerEndDate = Date().addingTimeInterval(duration)
        totalTime = duration
        timeRemaining = duration
        isActive = true

        // Schedule local notification
        scheduleNotification(duration: duration)

        // Start display timer for UI updates
        startDisplayTimer()
    }

    func stopTimer(silent: Bool = false) {
        if !silent {
            print("⏱️ RestTimer: Stopping timer")
        }

        displayTimer?.invalidate()
        displayTimer = nil
        timerEndDate = nil
        isActive = false
        timeRemaining = 0

        // Cancel pending notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["rest-timer"])
    }

    func skipTimer() {
        print("⏱️ RestTimer: Skipping timer")
        stopTimer()
    }

    // MARK: - Private Methods

    private func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimeRemaining()
        }
        RunLoop.current.add(displayTimer!, forMode: .common)
    }

    private func updateTimeRemaining() {
        guard let endDate = timerEndDate, isActive else {
            return
        }

        let remaining = endDate.timeIntervalSinceNow

        if remaining <= 0 {
            // Timer finished
            print("⏱️ RestTimer: Timer completed!")
            timeRemaining = 0
            stopTimer()
        } else {
            timeRemaining = remaining
        }
    }

    // MARK: - Notifications

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("⚠️ Notification permission denied")
            }
        }
    }

    private func scheduleNotification(duration: Double) {
        // Remove any existing notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["rest-timer"])

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Rest Time Complete"
        content.body = "Time to start your next set!"
        content.sound = .defaultCritical
        content.categoryIdentifier = "REST_TIMER"

        // Create trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)

        // Create request
        let request = UNNotificationRequest(identifier: "rest-timer", content: content, trigger: trigger)

        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled for \(Int(duration)) seconds")
            }
        }
    }
}
