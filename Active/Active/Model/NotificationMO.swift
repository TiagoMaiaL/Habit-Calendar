//
//  Notification.swift
//  Active
//
//  Created by Tiago Maia Lopes on 01/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import UserNotifications

/// The Notification model entity.
/// - Note: Alongside with the entity, an specific UserNotification is scheduled.
class NotificationMO: NSManagedObject {

    // MARK: Properties

    /// The associated and scheduled request for a user notification.
    var request: UNNotificationRequest?

    // MARK: Imperatives

    /// Returns the notification's fireDate.
    func getFireDate() -> Date {
        assert(fireDate != nil, "Notification's fire date must be set.")
        return fireDate!
    }
}
