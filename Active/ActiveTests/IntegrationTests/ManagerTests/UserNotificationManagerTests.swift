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

class UserNotificationManagerTests: IntegrationTestCase {
    
    // MARK: Properties
    
    /// The User notification center mock used to fake
    /// the authorization request.s
    var notificationCenterMock: UserNotificationCenterMock!
    
    /// The User notification manager used to schedule
    /// local user notifications.
    var notificationManager: UserNotificationManager!
    
    // MARK: Setup/Teardown
    
    override func setUp() {
        super.setUp()
        
        // Instantiate a notification center with authorization set
        // to return false (not granted).
        notificationCenterMock = UserNotificationCenterMock(withAuthorization: false)
        
        // Instantiate a new notification manager to be used by the current test.
        notificationManager = UserNotificationManager(notificationCenter: notificationCenterMock)
    }
    
    override func tearDown() {
        // Removes the previously created notificationManager.
        notificationManager = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testManagerAuthorizationRequestGranted() {
        // Declare the authorization request expectation.
        let authorizationExpectation = XCTestExpectation(description: "Ask the user to authorize the usage of local notifications.")

        // Configure the mock to authorize local notifications.
        notificationCenterMock.shouldAuthorize = true
        
        // Use manager to ask the user to use the local notifications.
        notificationManager.requestAuthorization() {
            granted in
            
            // Assert it was granted.
            XCTAssertTrue(granted, "The authorization to use Local notifications should be given by the user.")
            
            authorizationExpectation.fulfill()
        }
        
        wait(for: [authorizationExpectation], timeout: 0.1)
    }
    
    func testManagerAuthorizationRequestNotGranted() {
        // Declare the authrorization request expectation.
        let authorizationExpectation = XCTestExpectation(description: "Ask the user to authorize the usage of local notifications.")

        // Configure the mock so as not to grant local notifications.
        notificationCenterMock.shouldAuthorize = false
        
        // Ask for permission, the permission should be denied.
        notificationManager.requestAuthorization() {
            granted in
            
            // Assert it wasn't granted.
            XCTAssertFalse(granted, "The authorization to use Local notifications should be denied by the user.")
            
            authorizationExpectation.fulfill()
        }
        
        // Wait for the expectation.
        wait(for: [authorizationExpectation], timeout: 0.1)
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
    
    func testContentAndTriggerFactoriesWithFullAuthorization() {
        // Test the factories for the user notification's trigger and content
        // options when a Notification entity is passed and the authorization
        // was fully granted by the user.
        
        // Declare the habit and notification (associated with a Habit dummy)
        // that needs to be passed.
        guard let dummyHabit = factories.habit.makeDummy() as? Active.Habit else {
            XCTFail("Couldn't generate a dummy habit.")
            return
        }
        
        guard let dummyNotification = (dummyHabit.notifications as? Set<Active.Notification>)?.first else {
            XCTFail("Couldn't generate a dummy notification.")
            return
        }
        
        // Make the content and trigger options out of the passed habit.
        let userNotificationOptions = notificationManager.makeNotificationOptions(
            for: dummyHabit,
            and: dummyNotification
        )
        
        // Check on the content properties(texts).
        XCTAssertNotNil(
            userNotificationOptions.content,
            "The generated user notification should be set."
        )
        XCTAssertEqual(
            userNotificationOptions.content!.title,
            dummyHabit.getTitleText(),
            "The user notification content should have the correct title text."
        )
        XCTAssertEqual(
            userNotificationOptions.content!.subtitle,
            dummyHabit.getSubtitleText(),
            "The user notification content should have the correct subtitle text."
        )
        XCTAssertEqual(
            userNotificationOptions.content!.body,
            dummyHabit.getDescriptionText(),
            "The user notification content should have the correct description text."
        )
        
        // Declare the trigger as a UNTitmeIntervalNotificationTrigger.
        let dateTrigger = userNotificationOptions.trigger as? UNTimeIntervalNotificationTrigger
        
        // Check on the trigger properties(date).
        XCTAssertNotNil(
            dateTrigger,
            "The user notification trigger should be set."
        )
        XCTAssertEqual(
            dateTrigger!.nextTriggerDate(),
            dummyNotification.fireDate,
            "The user notification trigger should have the correct fire date."
        )
    }
    
    func testTriggerFactoryWithBadgeAndSoundAuthorizations() {
        // Test the factory for the user notification's trigger option when a
        // Notification entity is passed, and the authorization
        // is partially granted (no alerts, only badges and sounds).
        XCTFail("Not implemented.")
        
        // Declare the habit and notification (associated with a Habit dummy)
        // that needs to be passed.
        
        // Make the trigger out of the passed habit. The content options
        // must be nil (authorization to badges and icons only).
    }
    
    func testSchedulingUserNotificationPassingEntity() {
        // Schedule an user notification by passing a Notification entity.
        XCTFail("Not implemented.")
    }
    
    func testUserNotificationRemovalPassingEntity() {
        // Remove a given user notification by passing the Notification
        // entity.
        XCTFail("Not implemented.")
    }
    
    func testUserNotificationsRemovalPassingEntities() {
        // Test the removal of many user notifications by passing an array of
        // Notification entities.
        XCTFail("Not implemented.")
    }
    
    func testUserNotificationFetchByPassingEntity() {
        // Test the retrieval of an scheduled user notification by passing a
        // Notification entity.
        XCTFail("Not implemented.")
    }
}
