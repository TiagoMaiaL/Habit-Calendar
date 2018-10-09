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
    static var didChooseHabitToDisplay: Notification.Name {
        return Notification.Name("REMINDER_SELECTED")
    }

    /// Name for the notification sent when the user selects the "New habit" quick action.
    static var didSelectNewHabitQuickAction: Notification.Name {
        return Notification.Name("NEW_HABIT_ACTION")
    }

    /// Name for the notification sent when an error happened while the
    /// data controller was being loaded.
    static var didFailLoadingData: Notification.Name {
        return Notification.Name("FAILED_LOADING_DATA")
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

/// Observer for the didChooseHabitToDisplay notification, which is sent when the user
/// selects the user notification reminding about a habit, or the shortcut for a specific habit.
@objc protocol HabitToBeDisplayedObserver: NotificationObserver {

    /// Handles the didChooseHabitToDisplay notification.
    @objc func handleHabitToDisplayNotification(_ notification: Notification)
}

/// Observer for the didSelectNewHabitQuickAction notification, which is sent when the user
/// selects the "New habit" quick action.
@objc protocol NewHabitQuickActionObserver: NotificationObserver {

    /// Handles the didSelectNewHabitQuickAction notification.
    @objc func handleNewHabitQuickAction(_ notification: Notification)
}

/// Observer for the didFailLoadingData notification, which is sent when
/// Core Data stack can't be initialized.
@objc protocol DataLoadingErrorObserver: NotificationObserver {

    /// Handles the didFailLoadingData notification.
    @objc func handleDataLoadingError(_ notification: Notification)
}
