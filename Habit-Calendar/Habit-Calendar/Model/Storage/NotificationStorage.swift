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
    ///     - fireTime: The fire time to be associated with the new notification instance.
    /// - Returns: a new Notification entity.
    func create(using context: NSManagedObjectContext, andFireTime fireTime: FireTimeMO) -> NotificationMO? {
        precondition(fireTime.notification == nil, "The passed fire time mustn't have a notification entity.")

        let notification = NotificationMO(context: context)
        notification.id = UUID().uuidString
        notification.userNotificationId = UUID().uuidString
        notification.fireTime = fireTime
        return notification
    }

    /// Creates the notification entities associated with the provided habit.
    /// - Parameters:
    ///     - habit: The habit to which the notifications are created for.
    ///     - context: The managed object context.
    /// - Returns: The created notifications now associated with the habit.
    func createNotificationsFrom(
        habit: HabitMO,
        using context: NSManagedObjectContext
    ) -> [NotificationMO] {
        guard let fireTimes = habit.fireTimes as? Set<FireTimeMO>, !fireTimes.isEmpty else {
            return []
        }
        var notifications = [NotificationMO]()

        for fireTime in fireTimes {
            if let notification = create(using: context, andFireTime: fireTime) {
                notifications.append(notification)
            }
        }

        return notifications
    }

    /// Deletes from storage the passed notification.
    /// - Parameters:
    ///     - context: The context used to delete the notification from.
    ///     - notification: the notification to be removed.
    func delete(_ notification: NotificationMO, from context: NSManagedObjectContext) {
        if let fireTime = notification.fireTime {
            fireTime.notification = nil
        }
        context.delete(notification)
    }
}
