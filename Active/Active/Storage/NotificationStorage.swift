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
    func create(withFireDate fireDate: Date, habit: Habit) -> Notification {
        // Declare a new Notification instance.
        let notification = Notification(context: container.viewContext)
        notification.id = UUID().uuidString
        notification.fireDate = fireDate
        notification.addToHabits(habit)
        
        // Schedule a new user notification for the created habit.
        
        return notification
    }
}
