//
//  UserNotificationManagerTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 21/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import XCTest
import UserNotifications
@testable import Active

class UserNotificationManagerTests: XCTestCase {
    
    // MARK: Properties
    
    /// The User notification manager used to schedule
    /// local user notifications.
    var notificationManager: UserNotificationManager!
    
    // MARK: Setup/Teardown
    
    override func setUp() {
        super.setUp()
        
        // Instantiate a new notification manager to be used by the current test.
        notificationManager = UserNotificationManager(notificationCenter: UNUserNotificationCenter.current())
    }
    
    override func tearDown() {
        // Removes the previously created notificationManager.
        notificationManager = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    // Ask permissions to use the framework (check how to test this).
    // TODO:
    
    // Schedule a notification.
    func testNotificationSchedule() {
        // Prepare the user notification's content and trigger
        // options to schedule a notification.
        
        // Declare the notification content.
        let content = UNMutableNotificationContent()
        content.title = "Scheduling a notification."
        content.body = "Notification's body text."
        
        // Declare the trigger options.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Date().timeIntervalSinceNow * 1.01,
            repeats: false
        )
        
        // Schedule the notification.
        let notificationId = notificationManager.schedule(with: content, and: trigger)
        
        // Try to fetch it by using the notification center.
    notificationManager.notificationCenter.getPendingNotificationRequests { requests in
            // Assert on the array length and request's id.
            XCTAssertFalse(requests.isEmpty, "Notification wasn't correclty scheduled.")
            XCTAssertEqual(requests.first?.identifier, notificationId)
        }
    }
    
    // Remove an scheduled notification.
    func testScheduledNotificationRemoval() {
        
    }
    
}

extension UserNotificationManagerTests {
    // MARK: Tests
    
    // Test the factory method for notifications.
    // Test the schedule of by passing a given notification entity.
    // Test the removal of a given notification by passing the entity.
    // Test the removal of many notifications by passing an array of entities.
    // Test the retrieval of an scheduled notification by passing an entity.
}
