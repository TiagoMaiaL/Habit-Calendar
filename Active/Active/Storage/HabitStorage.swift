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
    
    /// The HabitDayStorage used to create the habit days associated
    /// with the habits.
    private let habitDayStorage: HabitDayStorage
    
    // MARK: - Initializers
    
    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameter habitDayStorage: The storage used to manage habitDays.
    /// - Parameter notificationStorage: The notification storage used to edit the entities' notifications.
    init(habitDayStorage: HabitDayStorage,
         notificationStorage: NotificationStorage) {
        self.habitDayStorage = habitDayStorage
        self.notificationStorage = notificationStorage
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
            NSSortDescriptor(key: "created", ascending: false),
            NSSortDescriptor(key: "score", ascending: true)
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
//                color: HabitColor,
                days: [Date],
                and notificationFireTimes: [Date]? = nil) -> HabitMO {
        // Declare a new habit instance.
        let habit = HabitMO(context: context)
        habit.id = UUID().uuidString
        habit.name = name
        habit.created = Date()
//        habit.color = color.getPersistenceIdentifier()
        
        // Associate its user.
        habit.user = user
        
        // Create the HabitDay entities associated with the new habit.
        _ = habitDayStorage.createDays(
            using: context,
            dates: days,
            and: habit
        )
        
        // Create and associate the notifications to the habit being created.
        if let fireTimes = notificationFireTimes {
            // Get the notification fire dates.
            let fireDates = notificationStorage.createNotificationFireDatesFrom(
                habit: habit,
                and: fireTimes
            )
            
            // Create the notification entities for the habit being editted.
            _ = notificationStorage.createNotificationsFrom(
                habit: habit,
                using: context,
                and: fireDates
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
//              color: HabitColor?,
              days: [Date]? = nil,
              and notificationFireTimes: [Date]? = nil) -> HabitMO {
        
        if let name = name {
            habit.name = name
        }
        
//        if let color = color {
//            habit.color = color.getPersistenceIdentifier()
//        }
        
        if let days = days {
            assert(!days.isEmpty, "HabitStorage -- edit: days argument shouldn't be empty.")
            
            // Declare the predicate to filter for days greater
            // than today (future days).
            let futurePredicate = NSPredicate(
                format: "day.date >= %@", Date().getBeginningOfDay() as NSDate
            )
            
            if let days = habit.days?.filtered(using: futurePredicate) as? Set<HabitDayMO> {
                // Remove the current days that are in the future.
                for habitDay in days {
                    context.delete(habitDay)
                }
            }
            
            // Add the passed days to the entity.
            _ = habitDayStorage.createDays(
                using: context,
                dates: days,
                and: habit
            )
        }
        
        if let fireTimes = notificationFireTimes {
            assert(!fireTimes.isEmpty, "HabitStorage -- edit: notifications argument shouldn't be empty.")
            
            if let notifications = habit.notifications as? Set<NotificationMO> {
                // Remove the current notifications.
                for notification in notifications {
                    habit.removeFromNotifications(notification)
                    context.delete(notification)
                }
            }
            
            // Get the notification fire dates.
            let fireDates = notificationStorage.createNotificationFireDatesFrom(
                habit: habit,
                and: fireTimes
            )
            
            // Create the notification entities for the habit bein editted.
            _ = notificationStorage.createNotificationsFrom(
                habit: habit,
                using: context,
                and: fireDates
            )
        }
        
        return habit
    }
    
    /// Removes the passed habit from the database.
    /// - Parameter context: The context used to delete the habit from.
    func delete(_ habit: HabitMO, from context: NSManagedObjectContext) {
        context.delete(habit)
    }
}
