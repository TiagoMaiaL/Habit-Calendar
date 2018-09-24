//
//  NotificationObserver.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 15/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension Notification.Name {

    /// Name for the notification sent when the user selects the
    /// user notification reminding about a specific habit.
    static var didSelectHabitReminder: Notification.Name {
        return Notification.Name("REMINDER_SELECTED")
    }
}

/// The interface to register/unregister to notifications from the NotificationCenter api.
@objc protocol NotificationObserver {

    /// Starts observing notifications from the NotificationCenter.
    func startObserving()

    /// Stops observing notifications from the NotificationCenter.
    func stopObserving()
}

/// Observer for the UIApplicationDidBecomeActive notification.
@objc protocol AppActiveObserver: NotificationObserver {

    /// Handles the UIApplicationDidBecomeActive notification.
    @objc func handleActivationEvent(_ notification: Notification)
}

/// Observer for the NSManagedObjectContextDidSave notification.
@objc protocol ManagedContextChangeObserver: NotificationObserver {

    /// Handles the context changes notification.
    @objc func handleContextChanges(_ notification: Notification)
}

/// Observer for the didSelectHabitReminder notification, which is sent when the user
/// selects the user notification reminding about a habit.
@objc protocol HabitReminderSelectionObserver: NotificationObserver {

    /// Handles the didSelectHabitReminder notification.
    @objc func handleHabitReminderSelection(_ notification: Notification)
}
