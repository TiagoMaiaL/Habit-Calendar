//
//  NotificationScheduler.swift
//  Active
//
//  Created by Tiago Maia Lopes on 19/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationScheduler {
    
    // MARK: Types
    
    typealias UserNotificationOptions = (content: UNNotificationContent, trigger: UNNotificationTrigger)
    
    // MARK: Properties
    
    /// The manager used to schedule the user notifications
    /// related to the NotificationMO entity.
    let notificationManager: UserNotificationManager
    
    // MARK: Imperatives
    
    /// Creates the user notification options (content and trigger)
    /// from the passed habit and notification entities.
    /// - Parameter notification: The notification from which the user
    ///                           notification will be generated.
    func makeNotificationOptions(for notification: NotificationMO) -> UserNotificationOptions {
        // Declare the notification contents with the correct attributes.
        let content = UNMutableNotificationContent()
        
        if let habit = notification.habit {
            content.title = habit.getTitleText()
            content.subtitle = habit.getSubtitleText()
            content.body = habit.getDescriptionText()
            content.badge = 1
        } else {
            assertionFailure("The passed notification must have a valid habit entity.")
        }
        
        // Declare the time interval used to schedule the notification.
        let fireDateTimeInterval = notification.getFireDate().timeIntervalSinceNow
        // Assert that the fire date is in the future.
        assert(fireDateTimeInterval > 0, "Inconsistency: the notification's fire date must be in the future.")
        
        // Declare the notification trigger with the correct date.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: fireDateTimeInterval,
            repeats: false
        )
        
        return (content: content, trigger: trigger)
    }
    
}
