//
//  NotificationStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 19/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import XCTest
import CoreData
import UserNotifications
@testable import Active

/// Class in charge of testing the HabitStorage methods.
class NotificationStorageTests: IntegrationTestCase {
    
    // MARK: Properties
    
    var notificationManager: UserNotificationManager!
    var habitStorage: HabitStorage!
    var notificationStorage: NotificationStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize habit storage.
        habitStorage = HabitStorage(container: memoryPersistentContainer)
        
        // Initialize notification manager.
        notificationManager = UserNotificationManager(notificationCenter: UserNotificationCenterMock(withAuthorization: true))
        
        // Initialize notificationStorage using the persistent container created for tests.
        notificationStorage = NotificationStorage(
            container: memoryPersistentContainer,
            manager: notificationManager
        )
    }
    
    override func tearDown() {
        // Remove the initialized storage class.
        notificationStorage = nil
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testNotificationCreation() {
        let RequestExpectation = XCTestExpectation(
            description: "The created notification needs to have a scheduled user notification request associated with it."
        )
        
        // Create a habit.
        let swimmingHabit = habitStorage.create(
            with: "Go swimming",
            days: [Date()]
        )
        
        // Create the notification.
        let fireDate = Date(timeInterval: 10, since: Date())
        guard let notification = try? notificationStorage.create(
            withFireDate: fireDate,
            habit: swimmingHabit
            ) else {
                XCTFail("The storage's creation should return a valid Notification entity.")
                return
        }
        
        XCTAssertNotNil(
            notification,
            "The Notification entity shouldn't be nil."
        )
        // Check for id
        XCTAssertNotNil(
            notification.id,
            "Notification id shouldn't be nil."
        )
        // Check for the correct fire date.
        XCTAssertEqual(
            fireDate,
            notification.fireDate,
            "Notification should have the correct fire date."
        )
        // Check for the habits property
        XCTAssertEqual(
            swimmingHabit,
            notification.habit,
            "The created notification has an invalid habit."
        )
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            // Check if the entity has a user notification request
            // associated with it.
            XCTAssertNotNil(
                notification.userNotificationId,
                "The created notification should have an associated and scheduled user notification id."
            )
            RequestExpectation.fulfill()
        }
        
        wait(for: [RequestExpectation], timeout: 0.2)
    }
    
    func testNotificationFetch() {
        // Create a new habit
        let habit = habitStorage.create(
            with: "walk every day",
            days: [Date()]
        )
        
        // Create a new notification
        let fireDate = Date(timeInterval: 10, since: Date())
        let notification = try? notificationStorage.create(
            withFireDate: fireDate,
            habit: habit
        )
        
        // Try to fetch the created notification
        let fetchedNotification = notificationStorage.notification(
            forHabit: habit,
            andDate: fireDate
        )
        
        XCTAssertNotNil(notification, "The Notification entity shouldn't be nil.")
        // Check if method fetches the created notification.
        XCTAssertNotNil(fetchedNotification, "Created notification should be fetched by using the notification method in the storage class.")
        // Check if notification's id matches.
        XCTAssertEqual(notification!.id, fetchedNotification?.id, "Created notification should have the correct attributes.")
    }
    
    func testNotificationCreationTwiceShouldThrow() {
        // Trying to create the same notification entity should throw an error.
        
        // Create a new habit.
        let habit = habitStorage.create(
            with: "Play the guitar",
            days: [Date()]
        )
        
        // Create a new notification
        let fireDate = Date(timeInterval: 10, since: Date())
        _ = try? notificationStorage.create(
            withFireDate: fireDate,
            habit: habit
        )
        
        // Try to create another notification with the same data
        // and check to see if it throws the expected exception.
        XCTAssertThrowsError(
            _ = try notificationStorage.create(
                withFireDate: fireDate,
                habit: habit
            ), "Trying to create the same notification twice should throw an error.")
    }
    
    func testNotificationDeletion() {
        // Create a new habit
        let habit = habitStorage.create(
            with: "walk every day",
            days: [Date()]
        )
        
        // Create a new notification
        let fireDate = Date(timeInterval: 10, since: Date())
        let notification = try? notificationStorage.create(
            withFireDate: fireDate,
            habit: habit
        )
        
        XCTAssertNotNil(notification, "The Notification entity shouldn't be nil.")
        // The new notification should be correctly fetched.
        XCTAssertNotNil(notificationStorage.notification(
            forHabit: habit,
            andDate: fireDate
        ), "The previously created notification should be fetched.")
        
        // Delete the created notification
        notificationStorage.delete(notification!)
        
        // Try to fetch the previously created notification.
        // Method shouldn't fetch any notification.
        XCTAssertNil(notificationStorage.notification(
            forHabit: habit,
            andDate: fireDate
        ), "The deleted notification shouldn't be fetched.")
    }
}
