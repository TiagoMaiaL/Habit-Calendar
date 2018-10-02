//
//  HabitStorage.swift
//  Active
//
//  Created by Tiago Maia Lopes on 06/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Class in charge of managing the storage of Habit entities.
class HabitStorage {

    // MARK: - Properties

    /// The Notification storage used to create Notification entities
    /// associated with a given habit.
    private let notificationStorage: NotificationStorage

    /// The days challenge storage used to create new challenges.
    private let daysChallengeStorage: DaysChallengeStorage

    /// The user notifications scheduler.
    private let notificationScheduler: NotificationScheduler

    /// The fire time used to create and associate the FireTimeMO entities.
    private let fireTimeStorage: FireTimeStorage

    // MARK: - Initializers

    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameters:
    ///     - daysChallengeStorage: The storage used to manage the habit's challenges.
    ///     - notificationStorage: The notification storage used to edit the entities' notifications.
    ///     - notificationScheduler: The scheduler in charge of scheduling the user notifications for the habit.
    ///     - fireTimeStorage: The storage in charge of creating the fire time entities.
    init(daysChallengeStorage: DaysChallengeStorage,
         notificationStorage: NotificationStorage,
         notificationScheduler: NotificationScheduler,
         fireTimeStorage: FireTimeStorage
    ) {
        self.daysChallengeStorage = daysChallengeStorage
        self.notificationStorage = notificationStorage
        self.notificationScheduler = notificationScheduler
        self.fireTimeStorage = fireTimeStorage
    }

    // MARK: - Imperatives

    /// Creates a NSFetchedResultsController for fetching completed habit instances
    /// ordered by the creation date and score of each habit.
    /// - Note: Completed habits are habits that don't have any active days' challenge. All challenges were completed.
    /// - Parameter context: The context used to fetch the habits.
    /// - Returns: The created fetched results controller.
    func makeCompletedFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController<HabitMO> {
        // Filter for habits that don't have an active days' challenge
        // (aren't closed yet or date is not in between the challenge).
        let completedPredicate = NSPredicate(
            format: """
SUBQUERY(challenges, $challenge,
    $challenge.isClosed == false AND $challenge.fromDate <= %@ AND %@ <= $challenge.toDate
).@count == 0
""",
            Date().getBeginningOfDay() as NSDate,
            Date().getBeginningOfDay() as NSDate
        )
        let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
        request.predicate = completedPredicate
        // The request should order the habits by the creation date and score.
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        return controller
    }

    /// Creates a NSFetchedResultsController for fetching in progress habit instances
    /// ordered by the creation date and score of each habit.
    /// - Note: Habits in progress are habits that have an active days' challenge.
    /// - Parameter context: The context used to fetch the habits.
    /// - Returns: The created fetched results controller.
    func makeFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController<HabitMO> {
        // Filter for habits that have an active days' challenge.
        let inProgressPredicate = NSPredicate(
            format: """
SUBQUERY(challenges, $challenge,
    $challenge.isClosed == false AND $challenge.fromDate <= %@ AND %@ <= $challenge.toDate
).@count > 0
""",
            Date().getBeginningOfDay() as NSDate,
            Date().getBeginningOfDay() as NSDate
        )
        let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
        request.predicate = inProgressPredicate
        // The request should order the habits by the creation date and score.
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        return controller
    }

    /// Creates and persists a new Habit instance with the provided info.
    /// - Parameter context: The context used to write the new habit into.
    /// - Parameter name: The name of the habit entity.
    /// - Parameter days: The dates for the DaysChallenge associated with the habit being created.
    /// - Parameter notifications: The fire dates of each notification object
    ///                            to be added to the habit.
    /// - Returns: The created Habit entity object.
    func create(using context: NSManagedObjectContext,
                user: UserMO,
                name: String,
                color: HabitMO.Color,
                days: [Date],
                and notificationFireTimes: [DateComponents]? = nil) -> HabitMO {
        // Declare a new habit instance.
        let habit = HabitMO(context: context)
        habit.id = UUID().uuidString
        habit.name = treatName(name)
        habit.createdAt = Date()
        habit.color = color.rawValue

        // Associate its user.
        habit.user = user

        // Create the challenge.
        _ = daysChallengeStorage.create(
            using: context,
            daysDates: days,
            and: habit
        )

        // Create and associate the notifications to the habit being created.
        if let fireTimes = notificationFireTimes {
            // Create and associate the FireTimeMO entities with the habit.
            for fireTime in fireTimes {
                _ = fireTimeStorage.create(
                    using: context,
                    components: fireTime,
                    andHabit: habit
                )
            }

            // Create and schedule the notifications.
            _ = makeNotifications(
                context: context,
                habit: habit,
                fireTimes: fireTimes
            )
        }

        return habit
    }

    /// Fetches the habit with the passed id, if it exists.
    /// - Parameters:
    ///     - context: NSManagedObjectContext executing the fetch.
    ///     - identifier: The id of the habit to be fetched.
    /// - Returns: The habitMO with the provided id, if found.
    func habit(using context: NSManagedObjectContext, and identifier: String) -> HabitMO? {
        // Declare the filter predicate and the request.
        let filterPredicate = NSPredicate(format: "id = %@", identifier)
        let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
        request.predicate = filterPredicate

        let result = try? context.fetch(request)

        return result?.first
    }

    /// Edits the passed habit instance with the provided info.
    /// - Parameter habit: The Habit entity to be changed.
    /// - Parameter context: The context used to change the habit and the associated entities.
    /// - Parameter name: The new name of the passed habit.
    /// - Parameter days: The dates of the new DaysChallenge to be added to the entity.
    /// - Parameter notifications: The new dates of each notification object
    ///                            to be added to the habit.
    func edit(
        _ habit: HabitMO,
        using context: NSManagedObjectContext,
        name: String? = nil,
        color: HabitMO.Color? = nil,
        days: [Date]? = nil,
        and notificationFireTimes: [DateComponents]? = nil
    ) -> HabitMO {
        if let name = name {
            habit.name = treatName(name)
        }

        if let color = color {
            habit.color = color.rawValue
        }

        if let days = days {
            editDaysChallenge(days, ofHabit: habit)
        }

        if let fireTimes = notificationFireTimes {
            editFireTimes(fireTimes, ofHabit: habit)
        }

        // If the days or fire times were editted, the habit's notifications become invalid, so it's necessary
        // to create and schedule new ones.
        if name != nil || days != nil || notificationFireTimes != nil {
            if let notifications = habit.notifications as? Set<NotificationMO> {
                // Unschedule all user notifications associated with
                // the entities.
                notificationScheduler.unschedule(Array(notifications))

                // Remove the current notifications.
                for notification in notifications {
                    habit.removeFromNotifications(notification)
                    context.delete(notification)
                }
            }

            // Create and schedule the new notifications.
            _ = makeNotifications(
                context: context,
                habit: habit,
                fireTimes: notificationFireTimes
            )
        }

        return habit
    }

    /// Edits the habit's daysChallenge by closing the current and adding a new one.
    /// - Parameters:
    ///     - days: The days to be added.
    ///     - habit: The habit to be edited.
    private func editDaysChallenge(_ days: [Date], ofHabit habit: HabitMO) {
        assert(!days.isEmpty, "HabitStorage -- edit: days argument shouldn't be empty.")

        guard let context = habit.managedObjectContext else {
            assertionFailure("The habit being edited must have a context.")
            return
        }

        // Close the current habit's days' challenge:
        if let currentChallenge = habit.getCurrentChallenge() {
            currentChallenge.close()
        }

        // Add a new challenge.
        _ = daysChallengeStorage.create(
            using: context,
            daysDates: days,
            and: habit
        )
    }

    /// Edits the habit's fire times by removing the old entities and adding the new ones.
    /// - Parameters:
    ///     - fireTimes: The fire times to be added.
    ///     - habit: The habit to be edited.
    private func editFireTimes(_ fireTimes: [DateComponents], ofHabit habit: HabitMO) {
        guard let context = habit.managedObjectContext else {
            assertionFailure("The habit being edited must have a context.")
            return
        }

        // Remove the current fire time entities associated with the habit.
        if let currentFireTimes = habit.fireTimes as? Set<FireTimeMO> {
            for fireTime in currentFireTimes {
                habit.removeFromFireTimes(fireTime)
                context.delete(fireTime)
            }
        }

        // Create and associate the FireTimeMO entities with the habit.
        for fireTime in fireTimes {
            _ = fireTimeStorage.create(
                using: context,
                components: fireTime,
                andHabit: habit
            )
        }
    }

    /// Removes the passed habit from the database.
    /// - Parameter context: The context used to delete the habit from.
    func delete(_ habit: HabitMO, from context: NSManagedObjectContext) {
        if let notifications = habit.notifications as? Set<NotificationMO> {
            notificationScheduler.unschedule([NotificationMO](notifications))
        }

        context.delete(habit)
    }

    /// Creates a bunch of notification entities and schedule all of its
    /// related user notifications, if authorized to do so.
    /// - Parameters:
    ///     - context: The NSManagedObject context to be used.
    ///     - habit: The habit to add the notifications to.
    ///     - fireTimes: The notifications' fire times.
    /// - Returns: The notification entities.
    private func makeNotifications(
        context: NSManagedObjectContext,
        habit: HabitMO,
        fireTimes: [DateComponents]?
    ) -> [NotificationMO] {
        // If the passed fire times are nil, try getting the habit's current ones.
        guard let fireTimes = fireTimes ?? (habit.fireTimes as? Set<FireTimeMO>)?.map({
            $0.getFireTimeComponents()
        }) else {
            // The habit doesn't have any fire times associated with it. This case is possible,
            // since the user can deny the usage of user notifications.
            return []
        }
        guard !fireTimes.isEmpty else {
            // If the fire times are empty, just return nil because no notifications should be scheduled.
            return []
        }

        let notifications = notificationStorage.createNotificationsFrom(habit: habit, using: context)

        if !notifications.isEmpty {
            // Schedule the user notifications.
            notificationScheduler.schedule(notifications)
        }

        return notifications
     }

    /// Returns the treated name string.
    /// - Parameter name: The name to be treated.
    /// - Returns: The treated name.
    private func treatName(_ name: String) -> String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    }
}
