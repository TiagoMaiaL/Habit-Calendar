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
    func requestAuthorization(_ completionHandler: @escaping (Bool) -> Void) {
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
    func unschedule(withIdentifiers identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }

    /// Fetches the scheduled user notification request and returns it in
    /// the provided completionHandler.
    /// - Parameter identifier: The notification's identifier.
    /// - Parameter completionHandler: The async block called with the
    ///                                found notification as it's
    ///                                parameter.
    func getRequest(
        with identifier: String,
        _ completionHandler: @escaping (UNNotificationRequest?) -> Void
    ) {
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

/// Protocol used to fake the authorization requests while testing.
/// - Note: The authorization requests prompt the user to authorize.
///         When testing, it halts the test and fails.
protocol UserNotificationCenter {

    func getNotificationSettings(
        completionHandler: @escaping (UNNotificationSettings) -> Swift.Void
    )

    func getAuthorizationStatus(
        completionHandler: @escaping (Bool) -> Swift.Void
    )

    func requestAuthorization(
        options: UNAuthorizationOptions,
        completionHandler: @escaping (Bool, Error?) -> Swift.Void
    )

    func add(
        _ request: UNNotificationRequest,
        withCompletionHandler completionHandler: ((Error?) -> Swift.Void)?
    )

    func getPendingNotificationRequests(
        completionHandler: @escaping ([UNNotificationRequest]) -> Swift.Void
    )

    func removePendingNotificationRequests(
        withIdentifiers identifiers: [String]
    )
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
