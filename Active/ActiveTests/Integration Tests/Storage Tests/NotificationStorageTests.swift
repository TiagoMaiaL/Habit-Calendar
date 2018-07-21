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
    
    var notificationStorage: NotificationStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize notificationStorage using the persistent container created for tests.
        notificationStorage = NotificationStorage()
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
        let fireDate = Date().byAddingMinutes(20)!
        guard let notification = try? notificationStorage.create(
            using: context,
            with: fireDate,
            and: dummyHabit
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
        // Check for the userNotificationId.
        XCTAssertNotNil(
            notification.userNotificationId,
            "The user notification id must be set in advance."
        )
        // Check for the wasScheduled property.
        XCTAssertFalse(
            notification.wasScheduled,
            "The user notification wasn't scheduled yet."
        )
        // Check for the habits property
        XCTAssertEqual(
            dummyHabit,
            notification.habit,
            "The created notification has an invalid habit."
        )
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            // Check if the entity has a user notification request
            // associated with it.
            XCTAssertNotNil(
                notification.userNotificationId,
                "The created notification should have an associated and scheduled user notification id."
            )
            RequestExpectation.fulfill()
        }
        
        wait(for: [RequestExpectation], timeout: 0.5)
    }
    
    func testNotificationFetch() {
        // Create a dummy notification.
        let dummyNotification = makeNotification()
        
        // Try to fetch the created notification
        let fetchedNotification = notificationStorage.notification(
            from: context,
            habit: dummyNotification.habit!,
            and: dummyNotification.fireDate!
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
                using: context,
                with: dummyNotification.fireDate!,
                and: dummyNotification.habit!
            ), "Trying to create the same notification twice should throw an error.")
    }
    
    func testNotificationDeletion() {
        // Declare a dummy notification
        let dummyNotification = makeNotification()

        // The dummy notification should be correctly fetched.
        XCTAssertNotNil(notificationStorage.notification(
            from: context,
            habit: dummyNotification.habit!,
            and: dummyNotification.fireDate!
        ), "The previously created notification should be fetched.")
        
        // Delete the dummy notification
        notificationStorage.delete(dummyNotification, from: context)
        
        // Try to fetch the deleted dummy notification.
        // The method shouldn't fetch nothing.
        XCTAssertNil(notificationStorage.notification(
            from: context,
            habit: dummyNotification.habit!,
            and: dummyNotification.fireDate!
        ), "The deleted notification shouldn't be fetched.")
    }
    
    func testFireDatesFactory() {
        // Create a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // Declare the fire times to be used.
        let fireTime = DateComponents(hour: 12, minute: 55)
        
        // Create the fire dates by calling the factory.
        let fireDates = notificationStorage.createNotificationFireDatesFrom(
            habit: dummyHabit,
            and: [fireTime]
        )
        
        // Assert on the generated fire dates:
        // The amount of dates -> days.count * fireTimes.count
        
        XCTAssertEqual(
            dummyHabit.getFutureDays().count,
            fireDates.count,
            "The fire dates don't have the expected count -> days.count * fireTimes.Count."
        )
        
        // Assert on the days:
        // Each fire date needs to have the same minutes and hours as the fire
        // time, and it also needs to have a corresponding day, with the month
        // and year.
        for fireDate in fireDates {
            // Assert on the time components (minute and hours).
            XCTAssertEqual(
                fireDate.components.minute,
                fireTime.minute,
                "The generated fire date doesn't have the correct minutes."
            )
            XCTAssertEqual(
                fireDate.components.hour,
                fireTime.hour,
                "The generated fire date doesn't have the correct hours."
            )
            
            // Get the corresponding day by using the day, month and
            // year components. There should be a unique corresponding
            // date.
            guard let days = (dummyHabit.days as? Set<HabitDayMO>) else {
                XCTFail("Couldn't get the dummy days.")
                return
            }
            
            XCTAssertEqual(
                1, // The number of days corresponding to the fire date.
                days.compactMap { $0.day?.date }.filter {
                    $0.components.day == fireDate.components.day &&
                    $0.components.month == fireDate.components.month &&
                    $0.components.year == fireDate.components.year
                }.count
            )
        }
    }
    
    func testNotificationsCreationFromFireDates() {
        // Create a dummy Habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // Declare the fireTime to be used.
        let fireTime = DateComponents(hour: 07, minute: 45)
        
        // Create the fire dates for the habit.
        let fireDates = notificationStorage.createNotificationFireDatesFrom(
            habit: dummyHabit,
            and: [fireTime]
        )
        
        // Create the notifications.
        let notifications = notificationStorage.createNotificationsFrom(
            habit: dummyHabit,
            using: context,
            and: fireDates
        )
        
        // Assert on the count.
        XCTAssertEqual(
            notifications.count,
            fireDates.count,
            "The number of created notifications isn't correct."
        )
        // Assert on the fire dates.
        for notification in notifications {
            XCTAssertTrue(
                fireDates.contains(notification.fireDate!),
                "The notification doesn't have a corresponding fire date."
            )
        }
    }
}
