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
@testable import Habit_Calendar

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

        guard let habitDay = dummyHabit.getCurrentChallenge()?.getFutureDays()?.first else {
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

    func testFetchingNotificationsByDate() {
        // 1. Declare some dummy notifications.
        let dummyHabit = habitFactory.makeDummy()
        if let notificationsSet = dummyHabit.notifications as? Set<NotificationMO> {
            dummyHabit.removeFromNotifications(notificationsSet as NSSet)
        }

        let notifications = [
            notificationFactory.makeDummy(),
            notificationFactory.makeDummy(),
            notificationFactory.makeDummy()
        ]
        let fireDates = (0..<3).compactMap { Date().getBeginningOfDay().byAddingMinutes($0) }

        for notification in notifications {
            let index = notifications.index(of: notification)!
            let fireDate = fireDates[index]

            notification.habit = dummyHabit
            notification.fireDate = fireDate
        }

        // 2. Fetch them by using today's date.
        let fetchedNotifications = notificationStorage.notifications(
            from: context,
            habit: dummyHabit,
            andDay: Date()
        )

        // 3. Assert the notifications were correclty returned.
        XCTAssertEqual(notifications.count, fetchedNotifications.count)
        for notification in fetchedNotifications {
            XCTAssertNotNil(notifications.index(of: notification))
        }
    }

    func testNotificationCreationTwiceShouldThrow() {
        // 1. Declare a dummy habit with dummy notifications already created.
        // 1.1 Get its day and fire time.
        let dummyHabit = habitFactory.makeDummy()
        guard let habitDay = dummyHabit.getCurrentChallenge()?.getFutureDays()?.first else {
            XCTFail("Couldn't get the habit day to create a new notification.")
            return
        }
        guard let fireTime = (dummyHabit.fireTimes as? Set<FireTimeMO>)?.first else {
            XCTFail("Couldn't get the fire time to create a new notification.")
            return
        }

        // 2. Creating a notification from the day and fire time should throw an error,
        //    since there's already a dummy notification with those attributes.
        XCTAssertThrowsError(
            _ = try notificationStorage.create(
                using: context,
                habitDay: habitDay,
                andFireTime: fireTime.getFireTimeComponents()
            ), "Trying to create the same notification twice should throw an error."
        )
    }

    func testCreationWithPastHabitDay() {
        // 1. Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()
        // 1.1 Get its first day.
        guard let firstDay = dummyHabit.getCurrentChallenge()?.getDay(for: Date()) else {
            XCTFail("Couldn't get the day corresponding to today.")
            return
        }
        // 1.2 Declare a fire time at the beginning of the day.
        let fireTime = DateComponents(hour: 0, minute: 0)

        // 2. Try to create a notification, but it should return nil.
        do {
            let notification = try notificationStorage.create(
                using: context,
                habitDay: firstDay,
                andFireTime: fireTime
            )
            XCTAssertNil(notification)
        } catch {
            XCTFail("Exception when trying to create a notification.")
        }
    }

    func testCreationOfMultipleNotificationsWithoutToday() {
        // 1. Declare a dummy habit.
        let dummyHabit = HabitMO(context: context)

        // 1.1 Add a new challenge to it.
        let days = (0..<10).map {
            Date().byAddingDays($0)?.getBeginningOfDay()
        }.compactMap { $0 }

        let challenge = daysChallengeFactory.makeDummy(using: days)
        if let days = challenge.days as? Set<HabitDayMO> {
            for day in days {
                day.habit = dummyHabit
            }
        }

        dummyHabit.addToChallenges(challenge)

        // 1.2 Add a fire time to it.
        let fireTimeFactory = FireTimeFactory(context: context)
        let dummyFireTime = fireTimeFactory.makeDummy()
        // At the beginning of the day.
        dummyFireTime.hour = 0
        dummyFireTime.minute = 0

        dummyHabit.addToFireTimes(dummyFireTime)

        // 2. Create its notifications.
        let notifications = notificationStorage.createNotificationsFrom(habit: dummyHabit, using: context)

        // 3. Assert on the count.
        // Only notifications with fire dates in the future are scheduled. Since the
        // fire time is on midnight, today doesn't count.
        XCTAssertEqual(notifications.count, days.count - 1)
    }

    func testCreationOfMultipleNotificationsWithToday() {
        // 1. Declare a dummy habit.
        let dummyHabit = HabitMO(context: context)

        // 1.1 Add a new challenge to it.
        let days = (0..<10).map {
            Date().byAddingDays($0)?.getBeginningOfDay()
        }.compactMap { $0 }

        let challenge = daysChallengeFactory.makeDummy(using: days)
        if let days = challenge.days as? Set<HabitDayMO> {
            for day in days {
                day.habit = dummyHabit
            }
        }

        dummyHabit.addToChallenges(challenge)

        // 1.2 Add a fire time to it.
        let fireTimeFactory = FireTimeFactory(context: context)
        let dummyFireTime = fireTimeFactory.makeDummy()
        // At the beginning of the day.
        dummyFireTime.hour = 23
        dummyFireTime.minute = 59

        dummyHabit.addToFireTimes(dummyFireTime)

        // 2. Create its notifications.
        let notifications = notificationStorage.createNotificationsFrom(habit: dummyHabit, using: context)

        // 3. Assert on the count.
        // All days should have a notification, because the fire time is marked for the
        // last minute of the day.
        XCTAssertEqual(notifications.count, days.count)
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
