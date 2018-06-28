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
    var dayStorage: DayStorage!
    var habitDayStorage: HabitDayStorage!
    var habitStorage: HabitStorage!
    var notificationStorage: NotificationStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize day storage.
        dayStorage = DayStorage(container: memoryPersistentContainer)
        
        // Initialize habitDay storage.
        habitDayStorage = HabitDayStorage(
            container: memoryPersistentContainer,
            calendarDayStorage: dayStorage
        )
        
        // Initialize habit storage.
        habitStorage = HabitStorage(
            container: memoryPersistentContainer,
            habitDayStorage: habitDayStorage
        )
        
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
        
        // Create a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // Create the notification.
        let fireDate = Date(timeInterval: 10, since: Date())
        guard let notification = try? notificationStorage.create(
            withFireDate: fireDate,
            habit: dummyHabit
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
            dummyHabit,
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
        // Create a dummy notification.
        let dummyNotification = makeNotification()
        
        // Try to fetch the created notification
        let fetchedNotification = notificationStorage.notification(
            forHabit: dummyNotification.habit!,
            andDate: dummyNotification.fireDate!
        )
        
        // Check if method fetches the created notification.
        XCTAssertNotNil(fetchedNotification, "Created notification should be fetched by using the notification method in the storage class.")
        // Check if notification's id matches.
        XCTAssertEqual(dummyNotification.id, fetchedNotification?.id, "Created notification should have the correct attributes.")
    }
    
    func testNotificationCreationTwiceShouldThrow() {
        // Trying to create the same notification entity should throw an error.
        let dummyNotification = makeNotification()
        
        // Try to create another notification with the same data
        // and check to see if it throws the expected exception.
        XCTAssertThrowsError(
            _ = try notificationStorage.create(
                withFireDate: dummyNotification.fireDate!,
                habit: dummyNotification.habit!
            ), "Trying to create the same notification twice should throw an error.")
    }
    
    func testNotificationDeletion() {
        // Declare a dummy notification
        let dummyNotification = makeNotification()

        // The dummy notification should be correctly fetched.
        XCTAssertNotNil(notificationStorage.notification(
            forHabit: dummyNotification.habit!,
            andDate: dummyNotification.fireDate!
        ), "The previously created notification should be fetched.")
        
        // Delete the dummy notification
        notificationStorage.delete(dummyNotification)
        
        // Try to fetch the deleted dummy notification.
        // The method shouldn't fetch nothing.
        XCTAssertNil(notificationStorage.notification(
            forHabit: dummyNotification.habit!,
            andDate: dummyNotification.fireDate!
        ), "The deleted notification shouldn't be fetched.")
    }
}
