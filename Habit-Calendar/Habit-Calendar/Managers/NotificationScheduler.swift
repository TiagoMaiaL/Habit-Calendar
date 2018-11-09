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

    /// Creates the options (content and trigger) for the pending request associated to the FireTimeMO.
    /// - Parameter fireTime: The FireTimeMO from which contents are generated.
    func makeNotificationOptions(from fireTime: FireTimeMO) -> UserNotificationOptions {
        precondition(fireTime.habit != nil, "The fire time must have a habit.")
        precondition(fireTime.notification != nil, "The fire time must have a notification.")

        let habit = fireTime.habit!

        // Declare the notification contents.
        let content = UNMutableNotificationContent()
        content.title = habit.getTitleText()
        content.subtitle = habit.getSubtitleText()
        content.body = habit.getBodyText()
        content.categoryIdentifier = UNNotificationCategory.Kind.dayPrompt(
            habitId: nil
        ).identifier
        content.userInfo["habitIdentifier"] = habit.id
        content.sound = UNNotificationSound.default
        content.badge = 1

        // Declare the calendar trigger.
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireTime.getFireTimeComponents(), repeats: true)

        return (content: content, trigger: trigger)
    }

    /// Schedules an user notification associated with the passed entity.
    /// - Parameters:
    ///     - notification: The core data entity to be scheduled.
    ///     - completionHandler: The handler called after the schedule finishes.
    // TODO: Correct this method.
    func schedule(
        _ notification: NotificationMO,
        completionHandler: ((NotificationMO) -> Void)? = nil) {

//        precondition(
//            notification.userNotificationId != nil,
//            "The notification id must be set to schedule the notification."
//        )
//
//        // Declare the options used to schedule a new request.
//        let options = makeNotificationOptions(for: notification)
//
//        // Schedule the new request.
//        notificationManager.schedule(
//            with: notification.userNotificationId!,
//            content: options.content,
//            and: options.trigger
//        ) { _ in
//            completionHandler?(notification)
//        }
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
