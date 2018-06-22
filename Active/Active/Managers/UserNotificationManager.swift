//
//  UserNotificationManager.swift
//  Active
//
//  Created by Tiago Maia Lopes on 19/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UserNotifications

/// Struct in charge of managing the creation, retrieval,
/// and deletion of local user notification instances associated
/// with the entity ones (Notification).
struct UserNotificationManager {
    
    // MARK: Properties
    
    /// The notification center used to manage the local notifications
    let notificationCenter: UNUserNotificationCenter
    
    // MARK: Initializers
    
    init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
    }
    
    // MARK: Imperatives
    
    /// Asks for permission to
    
    /// Schedules a new user notification by using the
    /// provided content and trigger.
    /// - Parameter content: The UNUserNotificationContent used in
    ///                      the notification.
    /// - Parameter trigger: The NotificatoinTrigger used to fire
    ///                      the notification.
    /// - Returns: The notification id of the scheduled user notification.
    func schedule(with content: UNNotificationContent,
                  and trigger: UNNotificationTrigger) -> String {
        // TODO: Implement.
        return ""
    }
    
    /// Fetches the scheduled notification and returns it in
    /// the provided completionHandler.
    /// - Parameter id: The notification's identifier.
    /// - Parameter completionHandler: The async block called with the
    ///                                found notification as it's parameter.
    func notification(with id: String,
                      completionHandler: (UNNotificationRequest?) -> ()) {
        // TODO: Implement.
    }
    
    /// Removes a scheduled notification by passing it's identifier.
    /// - Parameter id: The notification's identifier.
    func remove(with id: String) {
        // TODO: Implement.
    }
}
