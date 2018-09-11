//
//  NotificationStorage.swift
//  Active
//
//  Created by Tiago Maia Lopes on 19/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Class in charge of storing Notification entities.
class NotificationStorage {

    // MARK: Types

    enum NotificationStorageError: Error {
        case notificationAlreadyCreated
    }

    // MARK: Imperatives

    /// Creates and stores a new Notification entity.
    /// - Parameters:
    ///     - context: The context used to create the entity.
    ///     - habitDay: The habit day entity used to create the notification.
    ///     - fireTime: The date components (hour and minute) to fire the notification at the specified day.
    /// - Returns: a new Notification entity.
    func create(
        using context: NSManagedObjectContext,
        habitDay: HabitDayMO,
        andFireTime fireTimeComponents: DateComponents
    ) throws -> NotificationMO? {
        guard let habit = habitDay.habit,
            let challenge = habit.getCurrentChallenge() else {
            return nil
        }
        guard let order = challenge.getOrder(of: habitDay) else {
            assertionFailure("Error: the order should be correclty returned.")
            return nil
        }
        guard let fireDate = makeFireDate(from: habitDay, and: fireTimeComponents),
            fireDate.isFuture else {
            return nil
        }

        // Check if there's a notification with the same attributes already stored.
        if self.notification(from: context, habit: habit, and: fireDate) != nil {
            throw NotificationStorageError.notificationAlreadyCreated
        }

        // Declare a new Notification instance.
        let notification = NotificationMO(context: context)
        notification.id = UUID().uuidString
        notification.fireDate = fireDate
        notification.userNotificationId = UUID().uuidString
        notification.habit = habit
        notification.dayOrder = Int64(order)

        return notification
    }

    /// Creates the notification entities associated with the provided habit.
    /// - Parameters:
    ///     - habit: The habit to which the notifications are added.
    ///     - context: The managed object context.
    /// - Returns: The created notifications now associated with the habit.
    func createNotificationsFrom(
        habit: HabitMO,
        using context: NSManagedObjectContext
    ) -> [NotificationMO] {
        guard let challenge = habit.getCurrentChallenge() else {
            assertionFailure("The habit must have an active days' challenge.")
            return []
        }
        guard var days = challenge.getFutureDays() else {
            assertionFailure("The challenge must have future days.")
            return []
        }
        guard let fireTimes = habit.fireTimes as? Set<FireTimeMO>, !fireTimes.isEmpty else {
            return []
        }

        if let currentDay = challenge.getCurrentDay() {
            days.insert(currentDay)
        }

        var notifications = [NotificationMO?]()

        for habitDay in days {
            for fireTime in fireTimes {
                do {
                    let notification = try create(
                        using: context,
                        habitDay: habitDay,
                        andFireTime: fireTime.getFireTimeComponents()
                    )
                    notifications.append(notification)
                } catch {}
            }
        }

        return notifications.compactMap {$0}
    }

    /// Fetches the stored notification by using the provided habit and fireDate.
    /// - Parameters:
    ///     - context: The context used to fetch the entities from.
    ///     - forHabit: one of the habits associated with the notification entity to be searched.
    ///     - andDate: the scheduled fire date.
    /// - Returns: a notification entity matching the provided arguments,
    ///            if one is fetched.
    func notification(
        from context: NSManagedObjectContext,
        habit: HabitMO,
        and date: Date) -> NotificationMO? {
        // Declare the fetch request.
        // The predicate should search for the specific habit and date.
        let request: NSFetchRequest<NotificationMO> = NotificationMO.fetchRequest()
        let predicate = NSPredicate(
            format: "fireDate == %@ AND habit == %@",
            date as NSDate,
            habit
        )
        request.predicate = predicate

        let results = try? context.fetch(request)

        // The results shouldn't contain more than one notification.
        // Only one notification should be created for the passed date.
        assert(
            results?.count ?? 0 <= 1,
            "There's more than one notification for the passed arguments. Only one should be created and returned."
        )

        return results?.first
    }

    /// Fetches the stored notifications within the specific day's date.
    /// - Parameters:
    ///     - context: The context used to fetch the entities from.
    ///     - habit: one of the habits associated with the notification entity to be searched.
    ///     - day: the day's date to look for notifications.
    /// - Returns: the notifications within the passed day.
    func notifications(
        from context: NSManagedObjectContext,
        habit: HabitMO,
        andDay dayDate: Date
    ) -> [NotificationMO] {
        // Declare the day's filter predicate. The fire dates must be in between the day's begin and end.
        let dayPredicate = NSPredicate(
            format: "%@ <= fireDate AND fireDate <= %@",
            dayDate.getBeginningOfDay() as NSDate,
            dayDate.getEndOfDay() as NSDate
        )
        if let notificationsSet = habit.notifications?.filtered(using: dayPredicate) as? Set<NotificationMO> {
            return [NotificationMO](notificationsSet)
        } else {
            return []
        }
    }

    /// Deletes from storage the passed notification.
    /// - Parameters:
    ///     - context: The context used to delete the notification from.
    ///     - notification: the notification to be removed.
    func delete(_ notification: NotificationMO, from context: NSManagedObjectContext) {
        context.delete(notification)
    }

    /// Creates a fire date from the passed day entity and fire time.
    /// - Parameters:
    ///     - habitDay: The HabitDayMO entity to be used.
    ///     - fireTime: The fire time to be used.
    /// - Returns: The fire date.
    func makeFireDate(from habitDay: HabitDayMO, and fireTime: DateComponents) -> Date? {
        guard let dayDate = habitDay.day?.date else {
            assertionFailure("Couldn't get the passed day's date.")
            return nil
        }

        var components = dayDate.components
        components.hour = fireTime.hour
        components.minute = fireTime.minute

        return Calendar.current.date(from: components)
    }
}
