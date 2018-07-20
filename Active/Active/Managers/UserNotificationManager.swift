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
    private let notificationCenter: UserNotificationCenter
    
    // MARK: Initializers
    
    init(notificationCenter: UserNotificationCenter) {
        self.notificationCenter = notificationCenter
    }
    
    // MARK: Imperatives
    
    /// Requests the user authorization to schedule local notifications.
    /// - Parameter completionHandler: A block called with the result of
    ///                                the authrorization prompt.
    func requestAuthorization(_ completionHandler: @escaping (Bool) -> ()) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error == nil {
                completionHandler(granted)
            } else {
                completionHandler(false)
            }
        }
    }
    
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
    func schedule(with identifier: String,
                  content: UNNotificationContent,
                  and trigger: UNNotificationTrigger,
                  _ completionHandler: @escaping (Error?) -> Void) {
        getAuthorizationStatus { isAuthorized in
            // Check to see if the notification is allowed.
            // If it is, schedule the request.
            if isAuthorized {
                // Declare the user notification request
                // to be scheduled.
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )
                
                // Call the internal notification center and schedule it.
                self.notificationCenter.add(request) { error in
                    completionHandler(error)
                }
            }
        }
    }
    
    /// Removes a scheduled notification by passing it's identifier.
    /// - Parameter identifier: The notification's identifier.
    func unschedule(with identifier: String) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }
    
    /// Fetches the scheduled user notification request and returns it in
    /// the provided completionHandler.
    /// - Parameter identifier: The notification's identifier.
    /// - Parameter completionHandler: The async block called with the
    ///                                found notification as it's
    ///                                parameter.
    func getRequest(with identifier: String,
                      _ completionHandler: @escaping (UNNotificationRequest?) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            // Filter for the specified UNUserNotificationRequest.
            let request = requests.filter { request in
                return request.identifier == identifier
            }.first
            
            completionHandler(request)
        }
    }
    
    /// Returns if the local notifications are authorized or not.
    /// - Parameter completionHandler: The block called with the results.
    func getAuthorizationStatus(_ completionHandler: @escaping (Bool) -> Void) {
        // Get the notification settings and return if it's authorized or not.
        notificationCenter.getAuthorizationStatus(
            completionHandler: completionHandler
        )
    }
}

/// Extension in charge of adding facility methods to deal with Notification
/// and Habit entities.
extension UserNotificationManager {
    
    // MARK: Types
    
    typealias UserNotificationOptions = (content: UNNotificationContent, trigger: UNNotificationTrigger)
    
    // MARK: Imperatives
    
    /// Creates the user notification options (content and trigger)
    /// from the passed habit and notification entities.
    /// - Parameter notification: The notification from which the user
    ///                           notification will be generated.
    func makeNotificationOptions(for notification: NotificationMO) -> UserNotificationOptions {
        // Declare the notification contents with the correct attributes.
        let content = UNMutableNotificationContent()
        
        if let habit = notification.habit {
            content.title = habit.getTitleText()
            content.subtitle = habit.getSubtitleText()
            content.body = habit.getDescriptionText()
            content.badge = 1
        } else {
            assertionFailure("The passed notification must have a valid habit entity.")
        }
        
        // Declare the time interval used to schedule the notification.
        let fireDateTimeInterval = notification.getFireDate().timeIntervalSinceNow
        // Assert that the fire date is in the future.
        assert(fireDateTimeInterval > 0, "Inconsistency: the notification's fire date must be in the future.")
        
        // Declare the notification trigger with the correct date.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: fireDateTimeInterval,
            repeats: false
        )
        
        return (content: content, trigger: trigger)
    }
    
    /// Schedules an user notification associated with the passed entity.
    /// - Parameter notification: The core data entity to be scheduled.
    /// - Parameter completionHandler: The handler called after the schedule
    ///                                finishes.
    func schedule(
        _ notification: NotificationMO,
        completionHandler: Optional<(NotificationMO) -> Void> = nil) {
        
        // Declare the options used to schedule a new request.
        let options = makeNotificationOptions(for: notification)
        
        // Associate the user notification's identifier.
        notification.userNotificationId = UUID().uuidString
        
        // Schedule the new request.
        schedule(
            with: notification.userNotificationId!,
            content: options.content,
            and: options.trigger
        ) { identifier in
            // Associate the returned request id to the Notification entity.
            completionHandler?(notification)
        }
    }
    
    /// Fetches an user notification request associated with the passed
    /// Notification entity.
    /// - Parameter notification: The Notification entity.
    /// - Parameter completionHandler: The completion called after the fetch.
    func getRequest(from notification: NotificationMO, completionHandler: @escaping (UNNotificationRequest?) -> Void) {
        guard let identifier = notification.userNotificationId else {
            assertionFailure(
                "The passed notification entity should have an identifier."
            )
            return
        }
        
        // Fetch it by passing the notification's identifier.
        getRequest(with: identifier, completionHandler)
    }
    
    /// Removes the notification requests associated with
    /// the passed entities.
    /// - Parameter notifications: The Notification entities.
    func remove(_ notifications: [NotificationMO]) {
        // Declare the requests identifiers from the notifications.
        let identifiers = notifications.compactMap { notification in
            return notification.userNotificationId
        }
        
        // Remove the requests.
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }
}

/// Protocol used to fake the authorization requests while testing.
/// - Note: The authorization requests prompt the user to authorize.
///         When testing, it halts the test and fails.
protocol UserNotificationCenter {
    
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Swift.Void)
    
    func getAuthorizationStatus(completionHandler: @escaping (Bool) -> Swift.Void)
    
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Swift.Void)
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Swift.Void)?)
    
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Swift.Void)
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

/// Extension used only to declare the protocol implementation in the
/// UNUserNotificationCenter implementation.
extension UNUserNotificationCenter: UserNotificationCenter {
    
    /// Checks if the usage of local notifications is allowed.
    /// - Parameter completionHandler: The block called with the result.
    func getAuthorizationStatus(completionHandler: @escaping (Bool) -> Swift.Void) {
        getNotificationSettings { settings in
            completionHandler(settings.authorizationStatus == .authorized)
        }
    }
}
