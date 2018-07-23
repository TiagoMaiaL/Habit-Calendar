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
    
    /// The days sequence storage used to create new sequences.
    private let daysSequenceStorage: DaysSequenceStorage
    
    /// The user notifications scheduler.
    private let notificationScheduler: NotificationScheduler
    
    /// The fire time used to create and associate the FireTimeMO entities.
    private let fireTimeStorage: FireTimeStorage
    
    // MARK: - Initializers
    
    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameters:
    ///     - daysSequenceStorage: The storage used to manage the habit's
    ///                            sequences.
    ///     - notificationStorage: The notification storage used to edit
    ///                            the entities' notifications.
    ///     - notificationScheduler: The scheduler in charge of scheduling
    ///                              the user notifications for the habit.
    ///     - fireTimeStorage: The storage in charge of creating the fire time
    ///                        entities.
    init(daysSequenceStorage: DaysSequenceStorage,
         notificationStorage: NotificationStorage,
         notificationScheduler: NotificationScheduler,
         fireTimeStorage: FireTimeStorage
    ) {
        self.daysSequenceStorage = daysSequenceStorage
        self.notificationStorage = notificationStorage
        self.notificationScheduler = notificationScheduler
        self.fireTimeStorage = fireTimeStorage
    }
    
    // MARK: - Imperatives
    
    /// Creates a NSFetchedResultsController for fetching habit instances
    /// ordered by the creation date and score of each habit.
    /// - Parameter context: The context used to fetch the habits.
    /// - Returns: The created fetched results controller.
    func makeFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController<HabitMO> {
        let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
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
    /// - Parameter days: The dates of the days the habit will be tracked.
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
        habit.name = name
        habit.createdAt = Date()
        habit.color = color.rawValue
        
        // Associate its user.
        habit.user = user
        
        // Create the sequence.
        _ = daysSequenceStorage.create(
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
    
    /// Edits the passed habit instance with the provided info.
    /// - Parameter habit: The Habit entity to be changed.
    /// - Parameter context: The context used to change the habit and the associated entities.
    /// - Parameter name: The new name of the passed habit.
    /// - Parameter days: The new days' dates of the passed habit.
    /// - Parameter notifications: The new dates of each notification object
    ///                            to be added to the habit.
    func edit(_ habit: HabitMO,
              using context: NSManagedObjectContext,
              name: String? = nil,
              color: HabitMO.Color? = nil,
              days: [Date]? = nil,
              and notificationFireTimes: [DateComponents]? = nil) -> HabitMO {
        
        if let name = name {
            habit.name = name
        }
        
        if let color = color {
            habit.color = color.rawValue
        }
        
        if let days = days {
            assert(!days.isEmpty, "HabitStorage -- edit: days argument shouldn't be empty.")
            
            // Get the current sequence.
            if let currentSequence = habit.getCurrentSequence() {
                // Remove its future days.
                for day in habit.getFutureDays() {
                    if day.sequence === currentSequence {
                        currentSequence.removeFromDays(day)
                    }
                    habit.removeFromDays(day)
                    context.delete(day)
                }
                
                // Change its toDate to today.
                currentSequence.toDate = Date().getBeginningOfDay()
            }
            
            // Add a new sequence.
            _ = daysSequenceStorage.create(
                using: context,
                daysDates: days,
                and: habit
            )
        }
        
        if let fireTimes = notificationFireTimes {
            assert(!fireTimes.isEmpty, "HabitStorage -- edit: notifications argument shouldn't be empty.")
            
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
        
        if days != nil || notificationFireTimes != nil {
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
            
            // Create and schedule the notifications.
            _ = makeNotifications(
                context: context,
                habit: habit,
                fireTimes: notificationFireTimes
            )
        }
        
        return habit
    }
    
    /// Removes the passed habit from the database.
    /// - Parameter context: The context used to delete the habit from.
    func delete(_ habit: HabitMO, from context: NSManagedObjectContext) {
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
        // If the passed fire times are nil, try getting the habit's
        // current ones.
        guard let fireTimes = fireTimes ?? (habit.fireTimes as? Set<FireTimeMO>)?.map({
            $0.getFireTimeComponents()
        }) else {
            // The habit doesn't have any fire times associated with it.
            // This case is possible, since the user can deny the
            // usage of user notifications.
            return []
        }
        
        // Get the notification fire dates.
        let fireDates = notificationStorage.createNotificationFireDatesFrom(
            habit: habit,
            and: fireTimes
        )
        
        // Create the notification entities for the habit bein editted.
        let notifications = notificationStorage.createNotificationsFrom(
            habit: habit,
            using: context,
            and: fireDates
        )
        
        // Schedule the user notifications.
        notificationScheduler.schedule(notifications)
        
        return notifications
    }
}
