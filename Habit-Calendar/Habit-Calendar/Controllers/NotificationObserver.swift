//
//  NotificationObserver.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 15/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation

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
