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
        // 1. Create a dummy habit.
        let dummyHabit = habitFactory.makeDummy()
        // 1.1 Remove its notifications.
        if let notifications = dummyHabit.notifications {
            dummyHabit.removeFromNotifications(notifications)
        }

        guard let daysSet = dummyHabit.days as? Set<HabitDayMO>,
            let habitDay = Array(daysSet).last else {
            XCTFail("Couldn't get a habit day to create the notification.")
            return
        }
        guard let fireTime = (dummyHabit.fireTimes as? Set<FireTimeMO>)?.first else {
            XCTFail("Couldn't get a fire time to create the notification.")
            return
        }

        // 2. Create the notification.
        guard let notification = try? notificationStorage.create(
            using: context,
            habitDay: habitDay,
            andFireTime: fireTime.getFireTimeComponents()
        ) else {
            XCTFail("The storage's creation should return a valid Notification entity.")
            return
        }

        // 3. Assert on the notification values.
        XCTAssertNotNil(notification, "The Notification entity shouldn't be nil.")
        XCTAssertNotNil(notification?.id)
        XCTAssertNotNil(notification?.fireDate)
        XCTAssertNotNil(notification?.userNotificationId)
        XCTAssertTrue((notification?.dayOrder ?? 0) > 0)
        XCTAssertFalse(notification?.wasScheduled ?? true)
        XCTAssertEqual(dummyHabit, notification?.habit)
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
        XCTAssertNotNil(
            fetchedNotification,
            "Created notification should be fetched by using the notification method in the storage class."
        )
        // Check if notification's id matches.
        XCTAssertEqual(
            dummyNotification.id,
            fetchedNotification?.id,
            "Created notification should have the correct attributes."
        )
    }

    func testNotificationCreationTwiceShouldThrow() {
        XCTMarkNotImplemented()

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
        XCTMarkNotImplemented()

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

    func testFireDateFactory() {
        // 1. Create a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Get its current challenge and current day.
        guard let currentDay = dummyHabit.getCurrentChallenge()?.getCurrentDay() else {
            XCTFail("Couldn't get the current challenge's day.")
            return
        }
        guard let dayDate = currentDay.day?.date else {
            XCTFail("Couldn't get the day's date.")
            return
        }
        guard let fireTime = (dummyHabit.fireTimes as? Set<FireTimeMO>)?.first else {
            XCTFail("Couldn't get the challenge's fire time.")
            return
        }

        // 3. Make the fire date by using a fire time and the day entity.
        let fireDate = notificationStorage.makeFireDate(from: currentDay, and: fireTime.getFireTimeComponents())

        // 4. Assert it was correclty created.
        XCTAssertNotNil(fireDate)
        XCTAssertEqual(fireDate?.components.year, dayDate.components.year)
        XCTAssertEqual(fireDate?.components.month, dayDate.components.month)
        XCTAssertEqual(fireDate?.components.day, dayDate.components.day)
        XCTAssertEqual(fireDate?.components.hour, Int(fireTime.hour))
        XCTAssertEqual(fireDate?.components.minute, Int(fireTime.minute))
    }
}
