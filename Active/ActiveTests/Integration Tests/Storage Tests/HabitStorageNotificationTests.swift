//
//  HabitStorageNotificationTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 01/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Active

class HabitStorageNotificationTests: IntegrationTestCase {

    // MARK: Properties

    var notificationCenterMock: UserNotificationCenterMock!
    var notificationScheduler: NotificationScheduler!
    var habitStorage: HabitStorage!

    // MARK: Setup / Teardown

    override func setUp() {
        super.setUp()

        // Initialize the notification manager used by the storage.
        notificationCenterMock = UserNotificationCenterMock(
            withAuthorization: false
        )
        notificationScheduler = NotificationScheduler(
            notificationManager: UserNotificationManager(
                notificationCenter: notificationCenterMock
            )
        )

        // Initialize dayStorage using the persistent container created for tests.
        habitStorage = HabitStorage(
            daysChallengeStorage: DaysChallengeStorage(
                habitDayStorage: HabitDayStorage(
                    calendarDayStorage: DayStorage()
                )
            ),
            notificationStorage: NotificationStorage(),
            notificationScheduler: notificationScheduler,
            fireTimeStorage: FireTimeStorage()
        )
    }

    override func tearDown() {
        // Remove the initialized storages.
        notificationScheduler = nil
        habitStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testHabitEditionWithFireTimesPropertyShouldCreateFireTimeEntities() {
        // 1. Create a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Declare the fire times.
        let fireTimes = [
            DateComponents(hour: 02, minute: 30),
            DateComponents(hour: 12, minute: 15),
            DateComponents(hour: 15, minute: 45)
        ]

        // 3. Edit the habit by passing the fire times.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            and: fireTimes
        )

        // 4. Check if FireTimeMO entities were created.
        XCTAssertEqual(
            dummyHabit.fireTimes?.count,
            fireTimes.count,
            "The habit's edition should have created FireTimeMO entities."
        )
    }

    func testHabitEditionWithFireTimesPropertyShouldCreateNotifications() {
        // 1. Create a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Declare the fire times.
        let fireTimes = [
            DateComponents(hour: 15, minute: 30),
            DateComponents(hour: 11, minute: 15)
        ]

        // 3. Create the notifications by providing the components.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            and: fireTimes
        )

        // 4. Fetch the dummy's notifications and make assertions on it.
        // 4.1. Check if the count is the expected one.

        // Get only the future days for counting.
        guard let futureDays = (dummyHabit.days as? Set<HabitDayMO>)?.filter({ $0.day?.date?.isFuture ?? false }) else {
            XCTFail("Couldn't get the dummy habit's future days for comparision.")
            return
        }

        XCTAssertEqual(
            dummyHabit.notifications?.count,
            futureDays.count * fireTimes.count,
            "The added notifications should have the expected count of the passed fire times * days."
        )
    }

    func testCreatingHabitShouldScheduleUserNotifications() {
        notificationCenterMock.shouldAuthorize = true
        let scheduleExpectation = XCTestExpectation(
            description: "Create a new habit and create and schedule the notifications."
        )

        // 1. Declare the habit attributes needed for creation:
        let dummyUser = userFactory.makeDummy()
        let days = (1...Int.random(2..<50)).compactMap {
            Date().byAddingDays($0)
        }
        let fireTimes = [
            DateComponents(hour: 18, minute: 30),
            DateComponents(hour: 12, minute: 15)
        ]

        // 2. Create the habit.
        let createdHabit = habitStorage.create(
            using: context,
            user: dummyUser,
            name: "Testing notifications",
            color: .blue,
            days: days,
            and: fireTimes
        )

        // Use a timer to make the assertions on the scheduling of user
        // notifications. Scheduling notifications is an async operation.
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            // 3. Assert that the habit's notifications were scheduled:
            // - Assert on the count of notifications and user notifications.
            let notificationsCount = days.count * fireTimes.count
            XCTAssertEqual(createdHabit.notifications?.count, notificationsCount)

            self.notificationCenterMock.getPendingNotificationRequests { requests in
                XCTAssertEqual(requests.count, notificationsCount)

                // - Assert on the identifiers of each notificationMO and user notifications.
                let identifiers = requests.map { $0.identifier }
                guard let notificationsSet = createdHabit.notifications as? Set<NotificationMO> else {
                    XCTFail("The notifications weren't properly created.")
                    return
                }
                let notifications = Array(notificationsSet)

                XCTAssertTrue(
                    notifications.filter { !identifiers.contains( $0.userNotificationId! ) }.count == 0,
                    "All notifications should have been properly scheduled."
                )

                // - Assert on the notifications' wasScheduled property.
                XCTAssertTrue(
                    notifications.filter { !$0.wasScheduled }.count == 0,
                    "All notifications should have been scheduled."
                )

                scheduleExpectation.fulfill()
            }
        }
        wait(for: [scheduleExpectation], timeout: 0.2)
    }

    func testEditingHabitDaysShouldRescheduleUserNotifications() {
        let rescheduleExpectation = XCTestExpectation(
            description: "Reschedules the user notifications after changing the days dates."
        )

        // Enable the mock's authorization to schedule the notifications.
        notificationCenterMock.shouldAuthorize = true

        // 1. Declare the dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Declare the new days dates.
        let days = (1...Int.random(2..<50)).compactMap {
            Date().byAddingDays($0)
        }

        // 3. Edit the habit.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            days: days
        )

        // Get the habit's added challenge.
        let challengePredicate = NSPredicate(
            format: "fromDate >= %@ AND fromDate <= %@",
            days.first!.getBeginningOfDay() as NSDate,
            days.first!.getEndOfDay() as NSDate
        )
        guard let challenge = dummyHabit.challenges?.filtered(
            using: challengePredicate
            ).first as? DaysChallengeMO else {
                XCTFail("Couldn't get the added days' challenge.")
                return
        }

        // 4. Make the appropriated assertions:
        // - assert on the number of notification entities:
        XCTAssertEqual(
            dummyHabit.notifications?.count,
            challenge.days!.count * dummyHabit.fireTimes!.count,
            "The amount of notifications should be the number of future days * the fire times."
        )

        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in

            // - assert on the number of user notifications
            self.notificationCenterMock.getPendingNotificationRequests { requests in

                XCTAssertEqual(
                    requests.count,
                    dummyHabit.notifications?.count,
                    "The user notifications weren't properly scheduled."
                )

                // - assert that all notifications were properly scheduled.
                XCTAssertTrue(
                    (dummyHabit.notifications as? Set<NotificationMO>)?.filter { !$0.wasScheduled }.count == 0,
                    "The notifications weren't properly scheduled."
                )

                rescheduleExpectation.fulfill()
            }
        }

        wait(for: [rescheduleExpectation], timeout: 0.2)
    }

    func testEditingHabitFireDatesShouldRescheduleUserNotifications() {
        let rescheduleExpectation = XCTestExpectation(
            description: "Reschedules the user notifications after changing the notifications fire times."
        )

        // Enable the mock's authorization to schedule the notifications.
        notificationCenterMock.shouldAuthorize = true

        // 1. Declare the dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Declare the new fire tiems.
        let fireTimes = [
            DateComponents(
                hour: Int.random(0..<23),
                minute: Int.random(0..<59)
            ),
            DateComponents(
                hour: Int.random(0..<23),
                minute: Int.random(0..<59)
            ),
            DateComponents(
                hour: Int.random(0..<23),
                minute: Int.random(0..<59)
            )
        ]

        // 3. Edit the habit.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            and: fireTimes
        )

        // 4. Make the appropriated assertions:
        // - assert on the number of notification entities:
        XCTAssertEqual(
            dummyHabit.notifications?.count,
            dummyHabit.getFutureDays().count * fireTimes.count,
            "The amount of notifications should be the number of future days * the fire times."
        )

        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in

            // - assert on the number of user notifications
            self.notificationCenterMock.getPendingNotificationRequests { requests in

                XCTAssertEqual(
                    requests.count,
                    dummyHabit.notifications?.count,
                    "The user notifications weren't properly scheduled."
                )

                // - assert that all notifications were properly scheduled.
                XCTAssertTrue(
                    (dummyHabit.notifications as? Set<NotificationMO>)?.filter { !$0.wasScheduled }.count == 0,
                    "The notifications weren't properly scheduled."
                )

                rescheduleExpectation.fulfill()
            }
        }

        wait(for: [rescheduleExpectation], timeout: 0.2)
    }

    func testEditingDaysAndFireDatesShouldRescheduleUserNotifications() {
        let rescheduleExpectation = XCTestExpectation(
            description: "Reschedules the user notifications after changing the days and the notifications fire times."
        )

        // Enable the mock's authorization to schedule the notifications.
        notificationCenterMock.shouldAuthorize = true

        // 1. Declare the dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Declare the new days and fire tiems.
        let days = (1...Int.random(2..<50)).compactMap {
            Date().byAddingDays($0)
        }
        let fireTimeFactory = FireTimeFactory(context: context)
        let firstFireTime = fireTimeFactory.makeDummy()
        let secondFireTime = fireTimeFactory.makeDummy()
        // In order to avoid equal fire times, always switch the minutes.
        secondFireTime.minute = firstFireTime.minute == 30 ? 0 : 30

        let fireTimes = [firstFireTime, secondFireTime].map { $0.getFireTimeComponents() }

        // 3. Edit the habit.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            days: days,
            and: fireTimes
        )

        // 4. Make the appropriated assertions:
        // - assert on the number of notification entities:
        XCTAssertEqual(
            dummyHabit.notifications?.count,
            dummyHabit.getFutureDays().count * fireTimes.count,
            "The amount of notifications should be the number of future days * the fire times."
        )

        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in

            // - assert on the number of user notifications
            self.notificationCenterMock.getPendingNotificationRequests { requests in

                XCTAssertEqual(
                    requests.count,
                    dummyHabit.notifications?.count,
                    "The user notifications weren't properly scheduled."
                )

                // - assert that all notifications were properly scheduled.
                XCTAssertTrue(
                    (dummyHabit.notifications as? Set<NotificationMO>)?.filter { !$0.wasScheduled }.count == 0,
                    "The notifications weren't properly scheduled."
                )

                rescheduleExpectation.fulfill()
            }
        }

        wait(for: [rescheduleExpectation], timeout: 0.2)
    }
}
