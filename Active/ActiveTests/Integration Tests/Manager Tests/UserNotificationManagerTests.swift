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
        XCTFail("Not implemented.") // TODO: Fix this test.
        
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
        notificationManager.schedule(
            with: UUID().uuidString,
            content: content,
            and: trigger
        ) {
            identifier in
            
            // Make assertions on the returned identifier.
            XCTAssertNotNil(identifier, "The NotificationRequest's id shouldn't be nil.")
            XCTAssertFalse(identifier!.isEmpty, "The NotificationRequest's id shouldn't be empty.")
            
            notificationExpectation.fulfill()
        }
        
        wait(for: [notificationExpectation], timeout: 0.1)
    }
    
    func testScheduledNotificationFetch() {
        XCTFail("Not implemented.") // TODO: Fix this test.
        
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
        notificationManager.schedule(
            with: UUID().uuidString,
            content: content,
            and: trigger
        ) {
            identifier in
            
            guard let identifier = identifier else {
                XCTFail("The identifier shouldn't be nil.")
                return
            }
            
            // Try to fetch it by using the manager.
            self.notificationManager.getRequest(with: identifier) {
                request in
                
                // Make assertions on the request properties.
                XCTAssertNotNil(request, "The previously scheduled UserNotificationRequest should be correclty fetched.")
                XCTAssertEqual(request?.identifier, identifier, "The fetched request should have the expected id.")
                XCTAssertEqual(request?.trigger, trigger, "The fetched request should have the correct trigger options.")
                
                notificationFetchExpectation.fulfill()
            }
        }
        
        wait(for: [notificationFetchExpectation], timeout: 0.2)
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
        notificationManager.schedule(
            with: UUID().uuidString,
            content: content,
            and: trigger
        ) {
            identifier in
            
            XCTAssertNotNil(identifier, "The UserNotificationRequest's identifier shouldn't be nil after creation.")
            
            // Remove the scheduled notification by it's id.
            self.notificationManager.remove(with: identifier!)
            
            // The fetch for the created notification shouldn't return it.
            self.notificationManager.getRequest(with: identifier!) {
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
    
    func testContentAndTriggerFactory() {
        // Test the factories for the user notification's trigger and content
        // options when a Notification entity is passed and the authorization
        // was fully granted by the user.
        
        // Declare the notification (associated with a Habit dummy)
        // that needs to be passed.
        let dummyNotification = makeNotification()
        
        // Make the content and trigger options out of the passed habit.
        let userNotificationOptions = notificationManager.makeNotificationOptions(
            for: dummyNotification
        )
        
        // Check on the content properties(texts).
        XCTAssertNotNil(
            userNotificationOptions.content,
            "The generated user notification should be set."
        )
        XCTAssertEqual(
            userNotificationOptions.content.title,
            dummyNotification.habit!.getTitleText(),
            "The user notification content should have the correct title text."
        )
        XCTAssertEqual(
            userNotificationOptions.content.subtitle,
            dummyNotification.habit!.getSubtitleText(),
            "The user notification content should have the correct subtitle text."
        )
        XCTAssertEqual(
            userNotificationOptions.content.body,
            dummyNotification.habit!.getDescriptionText(),
            "The user notification content should have the correct description text."
        )
        
        // Declare the trigger as a UNTitmeIntervalNotificationTrigger.
        guard let dateTrigger = userNotificationOptions.trigger as? UNTimeIntervalNotificationTrigger else {
            XCTFail("The generated notification's trigger is nil.")
            return
        }
        
        XCTAssertNotNil(dateTrigger.nextTriggerDate(), "The notification trigger should have a valid trigger date.")
        XCTAssertEqual(
            dateTrigger.nextTriggerDate()!.description,
            dummyNotification.getFireDate().description,
            "The user notification trigger should have the correct next trigger date."
        )
    }
    
    func testSchedulingUserNotificationPassingEntity() {
        // Schedule an user notification by passing a Notification entity.
        
        let expectation = XCTestExpectation(description: "Schedule an user notification by passing a Notification core data entity.")
        
        // Declare a dummy notification to be used.
        let dummyNotification = makeNotification()
        
        // Schedule it by passing the dummy entity.
        notificationManager.schedule(dummyNotification) { notification in
            // It should have an user notification identifier.
            XCTAssertNotNil(
                notification.userNotificationId,
                "The scheduled notification entity should have an associated  user notification request id."
            )
            
            // Check if the notification request can be fetched.
            self.notificationManager.getRequest(with: notification.userNotificationId!, { request in
                XCTAssertNotNil(request, "The scheduled notification entity should have an associated user notification request.")
                
                expectation.fulfill()
            })
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testUserNotificationFetchByPassingEntity() {
        // Test the retrieval of an scheduled user notification by passing a
        // Notification entity.
        
        let expectation = XCTestExpectation(description: "Try to fetch the user notification request associated with a dummy notification.")
        
        // Declare a dummy Notification entity.
        let dummyNotification = makeNotification()
        
        // Schedule it using the manager.
        notificationManager.schedule(dummyNotification) { notification in
            // Try to fetch the notification request by passing
            // the entity.
            self.notificationManager.getRequest(from: notification) { request in
                XCTAssertNotNil(request, "The scheduled user notification request should be correctly fetched.")
                XCTAssertEqual(
                    request!.identifier,
                    notification.userNotificationId,
                    "The user notification request and the notification entity should have the same identifier."
                )
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testUserNotificationRemovalPassingEntities() {
        // Remove a given user notification by passing the Notifications
        // entity.
        let expectation = XCTestExpectation(description: "Remove a schedule user notification request by passing a Notification entity.")
        
        // Declare a dummy Notification entity.
        let dummyNotification = makeNotification()
        
        // Schedule a notification request.
        notificationManager.schedule(dummyNotification) { notification in
            // Delete the scheduled notification request.
            self.notificationManager.remove([notification])
            
            // Try fetching it, the request shouldn't be fetched.
            self.notificationManager.getRequest(from: notification, completionHandler: { request in
                XCTAssertNil(
                    request,
                    "The fetched request was deleted and shouldn't be fetched."
                )
                
                expectation.fulfill()
            })
        }
        
        wait(for: [expectation], timeout: 0.1)
    }    
}
