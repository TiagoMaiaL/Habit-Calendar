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

    // MARK: Initializers
    
    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameter manager: the user notification manager used by the storage.
    init(manager: UserNotificationManager) {
        self.manager = manager
    }
    
    // MARK: Imperatives
    
    /// Creates and stores a new Notification entity
    /// with a scheduled UserNotification object.
    /// - Parameter context: The context used to create the notification.
    /// - Parameter fireDate: Date used to schedule an user notification.
    /// - Parameter habit: The habit entity associated with the notification.
    /// - Returns: a new Notification entity.
    func create(using context: NSManagedObjectContext,
                with fireDate: Date,
                and habit: HabitMO) throws -> NotificationMO {

        // Check if there's a notification with the same attributes already stored.
        if self.notification(from: context, habit: habit, and: fireDate) != nil {
            throw NotificationStorageError.notificationAlreadyCreated
        }
        
        // Declare a new Notification instance.
        let notification = NotificationMO(context: context)
        notification.id = UUID().uuidString
        notification.fireDate = fireDate
        notification.habit = habit
        
        // Schedule a new user notification for the created habit.
//        manager.schedule(notification)
        
        return notification
    }
    
    /// Fetches the stored notification by using the provided
    /// habit and fireDate.
    /// - Parameter context: The context used to fetch the entities from.
    /// - Parameter forHabit: one of the habits associated with
    ///                       the notification entity to be searched.
    /// - Parameter andDate: the scheduled fire date.
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
        assert(results?.count ?? 0 <= 1, "NotificationStorage -- notification: There's more than one notification for the passed arguments. Only one should be created and returned.")
        
        return results?.first
    }
    
    /// Deletes from storage the passed notification.
    /// - Parameter context: The context used to delete the notification from.
    /// - Parameter notification: the notification to be removed.
    func delete(_ notification: NotificationMO, from context: NSManagedObjectContext) {
        context.delete(notification)
    }
    
}
