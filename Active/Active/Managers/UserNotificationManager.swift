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
    
    /// Schedules a new user notification by using the
    /// provided content and trigger.
    /// - Parameter content: The UNUserNotificationContent used in
    ///                      the notification.
    /// - Parameter trigger: The NotificatoinTrigger used to fire
    ///                      the notification.
    /// - Parameter completionHandler: The async block of code called
    ///                                after the notification gets
    ///                                scheduled.
    /// - Returns: The notification identifier of the scheduled user
    ///            notification.
    // TODO: Document the throws section.
    func schedule(with content: UNNotificationContent,
                  and trigger: UNNotificationTrigger,
                  _ completionHandler: @escaping (String?) -> ()) {
        // Declare the request's identifier
        let identifier = UUID().uuidString
        
        // Declare the user notification request
        // to be scheduled.
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Call the internal notification center and schedule it.
        notificationCenter.add(request) { error in
            if error == nil {
                // TODO: Understand what's @escaping
                completionHandler(identifier)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    /// Fetches the scheduled notification and returns it in
    /// the provided completionHandler.
    /// - Parameter identifier: The notification's identifier.
    /// - Parameter completionHandler: The async block called with the
    ///                                found notification as it's
    ///                                parameter.
    func notification(with identifier: String,
                      _ completionHandler: @escaping (UNNotificationRequest?) -> ()) {
        notificationCenter.getPendingNotificationRequests { requests in
            // Filter for the specified UNUserNotificationRequest.
            let request = requests.filter { request in
                return request.identifier == identifier
            }.first
            
            completionHandler(request)
        }
    }
    
    /// Removes a scheduled notification by passing it's identifier.
    /// - Parameter identifier: The notification's identifier.
    func remove(with identifier: String) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }
}
