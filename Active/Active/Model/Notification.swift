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
class Notification: NSManagedObject {

    // MARK: Properties
    
    /// The associated and scheduled request for a user notification.
    var request: UNNotificationRequest?
    
}
