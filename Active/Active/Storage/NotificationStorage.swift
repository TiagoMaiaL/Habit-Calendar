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
    
    // MARK: Properties
    
    /// The user notification manager used to schedule local notifications.
    let manager: UserNotificationManager
    
    /// The persistent container used by the storage.
    let container: NSPersistentContainer
    
    // MARK: Initializers
    
    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameter container: the persistent container used by the storage.
    /// - Parameter manager: the user notification manager used by the storage.
    init(container: NSPersistentContainer, manager: UserNotificationManager) {
        self.container = container
        self.manager = manager
    }
    
    // MARK: Imperatives
    
    /// Creates and stores a new Notification entity
    /// with a scheduled UserNotification object.
    /// - Parameter withFireDate: Date used to schedule an user notification.
    /// - Parameter habit: The habit entity associated with the notification.
    /// - Returns: a new Notification entity.
    func create(withFireDate fireDate: Date, habit: Habit) throws -> Notification {
        // Check if there's a notification with the same attributes already stored.
        if self.notification(forHabit: habit, andDate: fireDate) != nil {
            throw NotificationStorageError.notificationAlreadyCreated
        }
        
        // Declare a new Notification instance.
        let notification = Notification(context: container.viewContext)
        notification.id = UUID().uuidString
        notification.fireDate = fireDate
        notification.habit = habit
        
        // Schedule a new user notification for the created habit.
        manager.schedule(notification)
        
        return notification
    }
    
    /// Fetches the stored notification by using the provided
    /// habit and fireDate.
    /// - Parameter forHabit: one of the habits associated with
    ///                       the notification entity to be searched.
    /// - Parameter andDate: the scheduled fire date.
    /// - Returns: a notification entity matching the provided arguments,
    ///            if one is fetched.
    func notification(forHabit habit: Habit, andDate date: Date) -> Notification? {
        // Declare the fetch request.
        // The predicate should search for the specific habit and date.
        let request: NSFetchRequest<Notification> = Notification.fetchRequest()
        let predicate = NSPredicate(
            format: "fireDate == %@ AND habit == %@",
            date as NSDate,
            habit
        )
        request.predicate = predicate

        let results = try? container.viewContext.fetch(request)
        
        // The results shouldn't contain more than one notification.
        // Only one notification should be created for the passed date.
        assert(results?.count ?? 0 <= 1, "NotificationStorage -- notification: There's more than one notification for the passed arguments. Only one should be created and returned.")
        
        return results?.first
    }
    
    /// Deletes from storage the passed notification.
    /// - Parameter notification: the notification to be removed.
    func delete(_ notification: Notification) {
        container.viewContext.delete(notification)
    }
    
}
