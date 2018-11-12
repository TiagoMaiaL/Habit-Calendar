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
    ///     - habit: the habit related to the pending notification requests to be scheduled.
    func scheduleNotifications(for habit: HabitMO) {
        guard let fireTimes = habit.fireTimes as? Set<FireTimeMO> else {
            assertionFailure("The habit must have a valid fire times set.")
            return
        }

        // Add the pending notification requests for each fire time.
        for fireTime in fireTimes {
            let options = makeNotificationOptions(from: fireTime)
            notificationManager.schedule(
                using: fireTime.notification!.userNotificationId!,
                content: options.content,
                and: options.trigger
            )
        }
    }

    /// Unschedules the notification requests associated with the passed habit.
    /// - Parameter habit: The habit entity.
    func unscheduleNotifications(from habit: HabitMO) {
        guard let fireTimes = habit.fireTimes as? Set<FireTimeMO> else {
            assertionFailure("The habit must have fire times")
            return
        }
        notificationManager.unschedule(
            withIdentifiers: fireTimes.compactMap { $0.notification?.userNotificationId }
        )
    }

}
