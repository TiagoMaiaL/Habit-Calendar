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
    
    func testManagerPermissionsRequest() {
        // Ask permissions to use the framework (check how to test this).
        // TODO:
        XCTFail("Not implemented.")
    }
    
    func testNotificationSchedule() {
        // Schedule a notification.
        
        let notificationExpectation = XCTestExpectation(description: "Schedule a UserNotificationRequest.")
        
        // Declare the notification's content.
        let content = UNMutableNotificationContent()
        content.title = "Scheduling a notification."
        content.body = "Notification's body text."
        
        // Declare the trigger options.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Date().timeIntervalSinceNow + 60,
            repeats: false
        )
        
        // Schedule the notification.
        notificationManager.schedule(with: content, and: trigger) {
            identifier in
            
            // Make assertions on the returned identifier.
            XCTAssertNotNil(identifier, "The NotificationRequest's id shouldn't be nil.")
            XCTAssertFalse(identifier!.isEmpty, "The NotificationRequest's id shouldn't be empty.")
            
            notificationExpectation.fulfill()
        }
        
        wait(for: [notificationExpectation], timeout: 0.1)
    }
    
    func testScheduledNotificationFetch() {
        // Declare the fetch expectation.
        let notificationFetchExpectation = XCTestExpectation(description: "Fetch a scheduled notification request.")
        
        // Declare the notification's content.
        let content = UNMutableNotificationContent()
        content.title = "Scheduling a notification."
        content.body = "Notification's body text."
        
        // Declare the notification's trigger.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Date().timeIntervalSinceNow + 60,
            repeats: false
        )
        
        // Schedule the notification.
        notificationManager.schedule(with: content, and: trigger) {
            identifier in
            
            XCTAssertNotNil(identifier, "The identifier of the UserNotificationRequest shouldn't be nil.")
            
            // Try to fetch it by using the manager.
            self.notificationManager.notification(with: identifier!) {
                request in
                
                // Make assertions on the request properties.
                XCTAssertNotNil(request, "The previously scheduled UserNotificationRequest should be correclty fetched.")
                XCTAssertEqual(request?.identifier, identifier, "The fetched request should have the expected id.")
                XCTAssertEqual(request?.trigger, trigger, "The fetched request should have the correct trigger options.")
                
                notificationFetchExpectation.fulfill()
            }
        }
        
        wait(for: [notificationFetchExpectation], timeout: 0.1)
    }
    
    // TODO: Test scheduling with errors.
    
    func testScheduledNotificationRemoval() {
        // Remove an scheduled notification.
        
        let notificationRemovalExpectation = XCTestExpectation(description: "Delete a scheduled UserNotificationRequest.")
        
        // Declare the notification content.
        let content = UNMutableNotificationContent()
        content.title = "Testing removal of a notification."
        content.body = "Notification's body text."
        
        // Declare the trigger options.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Date().timeIntervalSinceNow + 60,
            repeats: false
        )
        
        // Schedule a new notification.
        notificationManager.schedule(with: content, and: trigger) {
            identifier in
            
            XCTAssertNotNil(identifier, "The UserNotificationRequest's identifier shouldn't be nil after creation.")
            
            // Remove the scheduled notification by it's id.
            self.notificationManager.remove(with: identifier!)
            
            // The fetch for the created notification shouldn't return it.
            self.notificationManager.notification(with: identifier!) {
                request in
                
                // Because the request was deleted, it shouldn't be returned.
                XCTAssertNil(request, "After fetching for a deleted UserNotificationRequest, the result should be nil.")
                
                notificationRemovalExpectation.fulfill()
            }
        }
        
        wait(for: [notificationRemovalExpectation], timeout: 0.1)
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
