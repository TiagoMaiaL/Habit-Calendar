//
//  UserNotificationManagerTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 21/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import UserNotifications
@testable import Habit_Calendar

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
        let authorizationExpectation = XCTestExpectation(
            description: "Ask the user to authorize the usage of local notifications."
        )

        // Configure the mock to authorize local notifications.
        notificationCenterMock.shouldAuthorize = true

        // Use manager to ask the user to use the local notifications.
        notificationManager.requestAuthorization { granted in

            // Assert it was granted.
            XCTAssertTrue(
                granted,
                "The authorization to use Local notifications should be given by the user."
            )

            authorizationExpectation.fulfill()
        }

        wait(for: [authorizationExpectation], timeout: 0.1)
    }

    func testManagerAuthorizationRequestNotGranted() {
        // Declare the authrorization request expectation.
        let authorizationExpectation = XCTestExpectation(
            description: "Ask the user to authorize the usage of local notifications."
        )

        // Configure the mock so as not to grant local notifications.
        notificationCenterMock.shouldAuthorize = false

        // Ask for permission, the permission should be denied.
        notificationManager.requestAuthorization { granted in

            // Assert it wasn't granted.
            XCTAssertFalse(granted, "The authorization to use Local notifications should be denied by the user.")

            authorizationExpectation.fulfill()
        }

        // Wait for the expectation.
        wait(for: [authorizationExpectation], timeout: 0.1)
    }

    func testNotificationSchedule() {
        notificationCenterMock.shouldAuthorize = true

        // Schedule a notification.
        let notificationExpectation = XCTestExpectation(description: "Schedule a UserNotificationRequest.")

        // Declare the notification's content.
        let identifier = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = "Scheduling a notification."
        content.body = "Notification's body text."

        // Declare the trigger options.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Date().byAddingDays(1)!.timeIntervalSinceNow,
            repeats: false
        )

        // Schedule the notification.
        notificationManager.schedule(
            with: identifier,
            content: content,
            and: trigger
        ) { error in

            // Assert that there's no errors.
            XCTAssertNil(
                error,
                "Scheduling a notification shouldn't cause any errors."
            )

            // Try fetching the created notification from the mock.
            self.notificationCenterMock.getPendingNotificationRequests { requests in
                XCTAssertEqual(
                    1,
                    requests.count,
                    "There should be one scheduled notification request."
                )
                XCTAssertEqual(
                    identifier,
                    requests.first?.identifier,
                    "The request should have the right identifier."
                )

                notificationExpectation.fulfill()
            }
        }

        wait(for: [notificationExpectation], timeout: 0.1)
    }
//
    func testScheduledNotificationFetch() {
        notificationCenterMock.shouldAuthorize = true

        // Declare the fetch expectation.
        let notificationFetchExpectation = XCTestExpectation(description: "Fetch a scheduled notification request.")

        // Declare the notification's content.
        let identifier = UUID().uuidString
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
            with: identifier,
            content: content,
            and: trigger
        ) { _ in

            // Try to fetch it by using the manager.
            self.notificationManager.getRequest(with: identifier) { request in

                guard let request = request else {
                    XCTFail(
                        "The previously scheduled UserNotificationRequest should be correclty fetched."
                    )
                    return
                }

                // Make assertions on the request properties.
                XCTAssertEqual(
                    request.identifier,
                    identifier,
                    "The fetched request should have the expected id."
                )
                XCTAssertEqual(
                    request.trigger,
                    trigger,
                    "The fetched request should have the correct trigger options."
                )
                notificationFetchExpectation.fulfill()
            }
        }

        wait(for: [notificationFetchExpectation], timeout: 0.1)
    }

    func testUnschedulingNotification() {
        notificationCenterMock.shouldAuthorize = true

        // Remove an scheduled notification.
        let notificationRemovalExpectation = XCTestExpectation(
            description: "Delete a scheduled UserNotificationRequest."
        )

        // Declare the notification content.
        let identifier = UUID().uuidString
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
            with: identifier,
            content: content,
            and: trigger
        ) { _ in
            // Remove the scheduled notification by it's id.
            self.notificationManager.unschedule(
                withIdentifiers: [identifier]
            )

            // The fetch for the created notification shouldn't return it.
            self.notificationManager.getRequest(with: identifier) { request in

                // Because the request was deleted, it shouldn't be returned.
                XCTAssertNil(
                    request,
                    "After fetching for a deleted UserNotificationRequest, the result should be nil."
                )

                notificationRemovalExpectation.fulfill()
            }
        }

        wait(for: [notificationRemovalExpectation], timeout: 0.1)
    }
}
