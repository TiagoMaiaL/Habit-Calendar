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
    
    /// The persistent container used by the storage.
    private let container: NSPersistentContainer
    
    /// The Notification storage used to create Notification entities
    /// associated with a given habit.
    private let notificationStorage: NotificationStorage
    
    /// The HabitDayStorage used to create the habit days associated
    /// with the habits..
    private let habitDayStorage: HabitDayStorage
    
    // MARK: - Initializers
    
    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameter container: the persistent container used by the storage.
    /// - Parameter habitDayStorage: The storage used to manage habitDays.
    init(container: NSPersistentContainer,
         habitDayStorage: HabitDayStorage,
         notificationStorage: NotificationStorage) {
        self.container = container
        self.habitDayStorage = habitDayStorage
        self.notificationStorage = notificationStorage
    }
    
    // MARK: - Imperatives
    
    /// Creates a NSFetchedResultsController for fetching habit instances
    /// ordered by the creation date and score of each habit.
    /// - Returns: The created fetched results controller.
    func makeFetchedResultsController() -> NSFetchedResultsController<Habit> {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        // The request should order the habits by the creation date and score.
        request.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false),
            NSSortDescriptor(key: "score", ascending: true)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return controller
    }
    
    /// Creates and persists a new Habit instance with the provided info.
    /// - Returns: The created Habit entity object.
    func create(with name: String,
//                color: HabitColor,
                days: [Date]) -> Habit {
        // TODO: Is it better to use a second queue to add new instances?
        
        // Declare a new habit instance.
        let habit = Habit(context: container.viewContext)
        habit.id = UUID().uuidString
        habit.name = name
        habit.created = Date()
//        habit.color = color.getPersistenceIdentifier()
        
        // Create the HabitDay entities associated with the new habit.
        _ = habitDayStorage.createDays(
            with: days,
            habit: habit
        )
        
        return habit
    }
    
    /// Edits the passed habit instane with the provided info.
    func edit(habit: Habit,
              withName name: String? = nil,
//              color: HabitColor?,
              days: [Date]? = nil,
              notifications: [Date]? = nil) -> Habit {
        
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
            
            if let days = habit.days?.filtered(using: futurePredicate) as? Set<HabitDay> {
                // Remove the current days that are in the future.
                for habitDay in days {
                    container.viewContext.delete(habitDay)
                }
            }
            
            // Add the passed days to the entity.
            _ = habitDayStorage.createDays(
                with: days,
                habit: habit
            )
        }
        
        if let notifications = notifications {
            assert(!notifications.isEmpty, "HabitStorage -- edit: notifications argument shouldn't be empty.")
            
            if let notifications = habit.notifications as? Set<Notification> {
                // Remove the current notifications.
                for notification in notifications {
                    container.viewContext.delete(notification)
                }
            }
            
            // Iterate over the notifications' dates and:
            for fireDate in notifications {
                // Create a notification using the storage.
                _ = try? notificationStorage.create(
                    withFireDate: fireDate,
                    habit: habit
                )
            }
        }
        
        return habit
    }
    
    /// Removes the passed habit from the database.
    func delete(habit: Habit) {
        container.viewContext.delete(habit)
    }
}
