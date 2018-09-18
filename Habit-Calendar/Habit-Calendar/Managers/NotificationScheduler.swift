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
            content.body = makeBodyText(from: notification)
            content.categoryIdentifier = UNNotificationCategory.Kind.dayPrompt(
                habitId: nil
            ).identifier
            content.userInfo["habitIdentifier"] = habit.id
            content.sound = UNNotificationSound.default()
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

    /// Creates the notification body text by using the dayOrder property of the notification entity.
    /// - Parameter notification: The NotificationMO entity.
    /// - Returns: The body text.
    func makeBodyText(from notification: NotificationMO) -> String {
        assert(notification.dayOrder > 0, "The dayOrder must be set and be greater than 0.")

        let dayOrder = Int(notification.dayOrder)
        var dayOrderText = String(dayOrder)

        switch dayOrder {
        case 1:
            dayOrderText += "st"
        case 2:
            dayOrderText += "nd"
        case 3:
            dayOrderText += "rd"
        default:
            dayOrderText += "th"
        }

        return "Today is your \(dayOrderText) day."
    }

    /// Schedules an user notification associated with the passed entity.
    /// - Parameters:
    ///     - notification: The core data entity to be scheduled.
    ///     - completionHandler: The handler called after the schedule
    ///                          finishes.
    func schedule(
        _ notification: NotificationMO,
        completionHandler: ((NotificationMO) -> Void)? = nil) {

        // Declare the options used to schedule a new request.
        let options = makeNotificationOptions(for: notification)

        // Associate the user notification's identifier.
        notification.userNotificationId = UUID().uuidString

        // Schedule the new request.
        notificationManager.schedule(
            with: notification.userNotificationId!,
            content: options.content,
            and: options.trigger
        ) { error in
            if error == nil {
                // Set the notification's scheduled flag.
                notification.managedObjectContext?.perform {
                    notification.wasScheduled = true
                    completionHandler?(notification)
                }
            } else {
                completionHandler?(notification)
            }
        }
    }

    /// Schedules an user notification associated with the passed entity.
    /// - Parameters:
    ///     - notification: The core data entity to be scheduled.
    func schedule(
        _ notifications: [NotificationMO]) {
        for notification in notifications {
            schedule(notification)
        }
    }

    /// Unschedules the notification requests associated with
    /// the passed entities.
    /// - Parameter notifications: The Notification entities.
    func unschedule(_ notifications: [NotificationMO]) {
        // Remove the requests.
        notificationManager.unschedule(
            withIdentifiers: notifications.compactMap { $0.userNotificationId }
        )
    }

}
