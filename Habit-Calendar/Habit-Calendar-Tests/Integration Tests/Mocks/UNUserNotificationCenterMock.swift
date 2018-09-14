//
//  UNUserNotificationCenterMock.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UserNotifications
@testable import Habit_Calendar

/// Mock used to fake the authorization requests.
/// - Note: The authorization requests prompt the user to authorize.
///         When testing, it halts the test and fails. This mock
///         solves this by faking the results.
class UserNotificationCenterMock: UserNotificationCenter {

    // MARK: Properties

    /// Configures the mock to grant the user's authorization.
    var shouldAuthorize = false

    /// The internal notification center used to implement all
    /// testable protocol methods.
    /// This mock implementation is partial.
    private let userNotificationCenter = UNUserNotificationCenter.current()

    /// The internal notification requests kept in memory for
    /// mock implementations.
    private var requests = [UNNotificationRequest]()

    // MARK: Initializers

    init(withAuthorization shouldAuthorize: Bool) {
        self.shouldAuthorize = shouldAuthorize
    }

    // MARK: Imperatives

    func requestAuthorization(
        options: UNAuthorizationOptions = [],
        completionHandler: @escaping (Bool, Error?) -> Void
    ) {
        // Immediately call the completion handler
        // by passing the configured grant result.
        completionHandler(shouldAuthorize, nil)
    }

    func add(
        _ request: UNNotificationRequest,
        withCompletionHandler completionHandler: ((Error?) -> Void)?
    ) {
        // Add the request to the internal requests array.
        requests.append(request)
        completionHandler?(nil)
    }

    func getPendingNotificationRequests(
        completionHandler: @escaping ([UNNotificationRequest]) -> Void
    ) {
        // Return the internal requests.
        completionHandler(requests)
    }

    func removePendingNotificationRequests(
        withIdentifiers identifiers: [String]
    ) {
        // Remove all requests with the passed identifiers from the internal
        // array.
        var temporaryRequests = self.requests

        for request in self.requests {
            if identifiers.contains(request.identifier),
                let index = temporaryRequests.index(of: request) {
                temporaryRequests.remove(at: index)
            }
        }

        self.requests = temporaryRequests
    }

    func getNotificationSettings(
        completionHandler: @escaping (UNNotificationSettings) -> Swift.Void
    ) {
        // Recall internal notification center.
        userNotificationCenter.getNotificationSettings(completionHandler: completionHandler)
    }

    /// Checks if the usage of local notifications is allowed.
    /// - Parameter completionHandler: The block called with the result.
    func getAuthorizationStatus(completionHandler: @escaping (Bool) -> Swift.Void) {
        completionHandler(shouldAuthorize)
    }

}
