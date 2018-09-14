//
//  NotificationAvailabilityDisplayable.swift
//  Active
//
//  Created by Tiago Maia Lopes on 28/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// Adds the interface for displaying whether user notifications aren't allowed by the user.
protocol NotificationAvailabilityDisplayable {

    // MARK: Imperatives

    /// The notification manager used to get the authorization status.
    var notificationManager: UserNotificationManager! { get set }

    // MARK: Imperatives

    /// Registers an observer for the UIApplicationDidBecomeActive event.
    /// - Note: This observer is used to make sure the view always displays the correct
    ///         UserNotification auth status (The user goes to Settings app and comes back).
    func observeForegroundEvent()

    /// Unregisters any observer.
    func removeObserver()

    /// Displays information about the local user notifications authorization status.
    func displayNotificationAvailability(_ notification: NSNotification?)
}

/// Adds default implementations to some of the protocol's methods.
extension NotificationAvailabilityDisplayable {

    // MARK: Imperatives

    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}
