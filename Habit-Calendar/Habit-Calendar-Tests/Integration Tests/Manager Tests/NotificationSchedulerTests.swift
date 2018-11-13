//
//  NotificationSchedulerTests.swift
//  JTAppleCalendar
//
//  Created by Tiago Maia Lopes on 19/07/18.
//

import XCTest
import UserNotifications
@testable import Habit_Calendar

/// Class in charge of testing the NotificationScheduler struct.
class NotificationSchedulerTests: IntegrationTestCase {

    // MARK: Properties

    /// The notification center mock used to test the scheduler.
    var notificationCenterMock: UserNotificationCenterMock!

    /// The scheduler being tested. It takes NotificationMO entities and
    /// schedules tbe user notifications related to each entity.
    var notificationScheduler: NotificationScheduler!

    // MARK: Setup/TearDown

    override func setUp() {
        super.setUp()

        // Instantiate the scheduler by using a notification center mock.
        notificationCenterMock = UserNotificationCenterMock(
            withAuthorization: true
        )
        notificationScheduler = NotificationScheduler(
            notificationManager: UserNotificationManager(notificationCenter: notificationCenterMock)
        )
    }

    override func tearDown() {
        super.tearDown()

        // Remove the instantiated entity.
        notificationCenterMock = nil
        notificationScheduler = nil
    }

    // MARK: Tests

    /// Test the factories for creating the trigger and content options of the pending requests.
    func testRequestContentAndTriggerFactory() {
        // Declare the dummy habit and fire tiem used to get the pending request values.
        let dummyHabit = habitFactory.makeDummy()
        guard let fireTime = (dummyHabit.fireTimes as? Set<FireTimeMO>)?.first else {
            XCTFail("To proceed the test needs a fire time.")
            return
        }

        // Make the content and trigger options out of the passed habit.
        let userNotificationOptions = notificationScheduler.makeNotificationOptions(
            from: fireTime
        )

        // Check on the content properties(texts).
        XCTAssertNotNil(
            userNotificationOptions.content,
            "The generated user notification should be set."
        )
        XCTAssertEqual(
            userNotificationOptions.content.title,
            dummyHabit.getTitleText(),
            "The user notification content should have the correct title text."
        )
        XCTAssertEqual(
            userNotificationOptions.content.subtitle,
            dummyHabit.getSubtitleText(),
            "The user notification content should have the correct subtitle text."
        )
        XCTAssertEqual(
            userNotificationOptions.content.body,
            dummyHabit.getBodyText(),
            "The user notification content should have the correct body text."
        )
        XCTAssertEqual(
            userNotificationOptions.content.userInfo["habitIdentifier"] as? String,
            dummyHabit.id,
            "The notification id should be passed within the user info."
        )
        XCTAssertEqual(
            userNotificationOptions.content.categoryIdentifier,
            UNNotificationCategory.Kind.dayPrompt(habitId: nil).identifier,
            "The category identifier should be informed."
        )
        XCTAssertNotNil(userNotificationOptions.content.sound)
        XCTAssertNotNil(userNotificationOptions.content.badge)

        // Declare the trigger as a UNTitmeIntervalNotificationTrigger.
        guard let calendarTrigger = userNotificationOptions.trigger as? UNCalendarNotificationTrigger else {
            XCTFail("The calendar trigger must be set.")
            return
        }

        // Assert on the date components, they need to be equal to the ones of the FireTimeMO.
        XCTAssertNotNil(calendarTrigger.nextTriggerDate())
        XCTAssertEqual(calendarTrigger.dateComponents.minute, fireTime.getFireTimeComponents().minute)
        XCTAssertEqual(calendarTrigger.dateComponents.hour, fireTime.getFireTimeComponents().hour)
    }

    /// Tests if the notification requests of the habit are scheduled.
    func testSchedulingNotificationsForTheHabit() {
        let scheduleExpectation = XCTestExpectation(
            description: "Schedules the user notifications for the dummy habit."
        )

        let dummyHabit = habitFactory.makeDummy()
        notificationScheduler.scheduleNotifications(for: dummyHabit)

        let expectedRequestIdentifiers = (dummyHabit.fireTimes as? Set<FireTimeMO>)?.compactMap {
            $0.notification?.userNotificationId
        } ?? []

        // Check if the pending notification requests were added.
        self.notificationCenterMock.getPendingNotificationRequests { requests in
            XCTAssertEqual(expectedRequestIdentifiers.count, requests.count)
            XCTAssertEqual(
                Set(expectedRequestIdentifiers),
                Set(requests.map { $0.identifier })
            )

            scheduleExpectation.fulfill()
        }

        wait(for: [scheduleExpectation], timeout: 0.1)
    }

    func testRemovingPendingNotificationRequestsFromAHabit() {
        let unscheduleExpectation = XCTestExpectation(
            description: "Unschedules the user notifications for a habit."
        )

        let firstHabit = habitFactory.makeDummy()
        guard let fireTimes = firstHabit.fireTimes as? Set<FireTimeMO> else {
            XCTFail("Couldn't get the fire times of the habit.")
            return
        }
        let firstHabitNotificationIdentifiers = fireTimes.compactMap { $0.notification?.userNotificationId }

        let secondHabit = habitFactory.makeDummy()

        notificationScheduler.scheduleNotifications(for: firstHabit)
        notificationScheduler.scheduleNotifications(for: secondHabit)

        notificationScheduler.unscheduleNotifications(from: firstHabit)
        notificationCenterMock.getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, secondHabit.fireTimes?.count)

            let requestIdentifiers = Set(requests.map { $0.identifier })

            XCTAssertFalse(
                Set(firstHabitNotificationIdentifiers).isSubset(of: requestIdentifiers)
            )

            unscheduleExpectation.fulfill()
        }

        wait(for: [unscheduleExpectation], timeout: 0.1)
    }
}
