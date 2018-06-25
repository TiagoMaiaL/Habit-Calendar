//
//  UNUserNotificationCenterMock.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UserNotifications
@testable import Active

/// Mock used to fake the authorization requests.
/// - Note: The authorization requests prompt the user to authorize.
///         When testing, it halts the test and fails. This mock
///         solves this by faking the results.
class UserNotificationCenterMock: NotificationCenter {
    
    // MARK: Properties
    
    /// Configures the mock to grant the user's authorization.
    var shouldAuthorize = false
    
    /// Configures the mock to allow all kinds of notification settings.
    var shouldAuthorizeAlert = true
    
    /// The internal notification center used to implement all
    /// testable protocol methods.
    /// This mock implementation is partial.
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    // MARK: Initializers
    
    init(withAuthorization shouldAuthorize: Bool) {
        self.shouldAuthorize = shouldAuthorize
    }
    
    // MARK: Imperatives
    
    func requestAuthorization(options: UNAuthorizationOptions = [], completionHandler: @escaping (Bool, Error?) -> Void) {
        // Immediately call the completion handler
        // by passing the configured grant result.
        completionHandler(shouldAuthorize, nil)
    }
    
//    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Swift.Void) {
//        // Declare the notification settings instance.
//        let mockSettings = NotificationSettingsMock()
//
//        // Set it's properties according to the mock configuration.
//        if !shouldAuthorizeAlert {
//            mockSettings.alertSetting = .disabled
//        }
//
//        // Direclty return it by calling the completion handler.
//        completionHandler(mockSettings)
//    }
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        // Recall internal notification center.
        userNotificationCenter.add(request, withCompletionHandler: completionHandler)
    }
    
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
       // Recall internal notification center.
        userNotificationCenter.getPendingNotificationRequests(completionHandler: completionHandler)
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
       // Recall internal notification center.
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

/// Mock used to fake the settings for the delivery of user notifications.
class NotificationSettingsMock: NotificationSettings {
    
    var soundSetting: UNNotificationSetting = .enabled
    
    var badgeSetting: UNNotificationSetting = .enabled
    
    var alertSetting: UNNotificationSetting = .enabled
}
