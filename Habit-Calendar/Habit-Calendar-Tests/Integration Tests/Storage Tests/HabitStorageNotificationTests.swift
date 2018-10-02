//
//  HabitStorageNotificationTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 01/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Habit_Calendar

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
        let dummy = habitFactory.makeDummy()

        // 2. Declare the fire times.
        let fireTimes = [
            DateComponents(hour: 15, minute: 30),
            DateComponents(hour: 11, minute: 15)
        ]

        // 3. Create the notifications by providing the components.
        _ = habitStorage.edit(
            dummy,
            using: context,
            and: fireTimes
        )

        // 4. Fetch the dummy's notifications and make assertions on it.
        // 4.1. Check if the count is the expected one.
        XCTAssertEqual(
            dummy.notifications?.count,
            getExpectedNotificationsCount(from: dummy),
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
        let days = (0...Int.random(2..<10)).compactMap {
            Date().byAddingDays($0)
        }
        let fireTimes = [
            DateComponents(hour: 23, minute: 59)
        ]

        // 2. Create the habit.
        let createdHabit = habitStorage.create(
            using: context,
            user: dummyUser,
            name: "Testing notifications",
            color: .systemBlue,
            days: days,
            and: fireTimes
        )

        // Use a timer to make the assertions on the scheduling of user
        // notifications. Scheduling notifications is an async operation.
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            // 3. Assert that the habit's notifications were scheduled:
            // - Assert on the count of notifications and user notifications.
            let notificationsCount = self.getExpectedNotificationsCount(from: createdHabit)
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
        let days = (0...Int.random(2..<10)).compactMap {
            Date().byAddingDays($0)
        }

        // 3. Edit the habit.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            days: days
        )

        // 4. Make the appropriated assertions:
        // - assert on the number of notification entities:
        XCTAssertEqual(
            dummyHabit.notifications?.count,
            getExpectedNotificationsCount(from: dummyHabit),
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
            getExpectedNotificationsCount(from: dummyHabit),
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
        let days = (0...Int.random(2..<10)).compactMap {
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
            getExpectedNotificationsCount(from: dummyHabit),
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

    func testNotificationsAreRemovedWhenDeletingHabit() {
        // 1. Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Delete the habit.
        habitStorage.delete(dummyHabit, from: context)
        try? context.save()

        // 3. Check if the notifications are also marked as removed.
        XCTAssertEqual(0, try? context.count(for: NotificationMO.fetchRequest()))
    }

    func testPendingRequestsAreRemovedWhenDeletingHabit() {
        let expectation = XCTestExpectation(description: "The habit's pending requests should be deleted as well.")

        // 1. Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Schedule its notifications.
        guard let set = dummyHabit.notifications as? Set<NotificationMO> else {
            XCTFail("Couldn't get the dummy habit's notifications.")
            return
        }

        let notifications = [NotificationMO](set)
        notificationCenterMock.shouldAuthorize = true
        notificationScheduler.schedule(notifications)

        // 3. Delete the habit.
        habitStorage.delete(dummyHabit, from: context)

        // 4. Assert its pending requests were removed as well.
        notificationCenterMock.getPendingNotificationRequests { requests in
            XCTAssertEqual(0, requests.count, "The pending notification requests should also have been removed.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)
    }

    func testEditingHabitNameShouldRescheduleUserNotifications() {
        let nameRescheduleExpectation = XCTestExpectation(
            description: "Reschedules the user notifications after changing the name."
        )

        // Enable the mock's authorization to schedule the notifications.
        notificationCenterMock.shouldAuthorize = true

        // 1. Declare the habit attributes needed for creation:
        let days = (0...Int.random(2..<10)).compactMap {
            Date().byAddingDays($0)
        }
        let fireTimes = [
            DateComponents(hour: 23, minute: 59)
        ]

        // 2. Create the habit.
        let createdHabit = habitStorage.create(
            using: context,
            user: userFactory.makeDummy(),
            name: "Testing notifications",
            color: .systemBlue,
            days: days,
            and: fireTimes
        )

        // 2. Check on its current notifications.
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            self.notificationCenterMock.getPendingNotificationRequests { requests in
                XCTAssertEqual(
                    requests.count,
                    createdHabit.notifications?.count,
                    "The user notifications weren't properly scheduled."
                )

                // 3. Edit it by changing its name.
                let newName = "Go skating"
                _ = self.habitStorage.edit(createdHabit, using: self.context, name: newName)

                // 4. Check if the notifications were properly scheduled and if the name was changed.
                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
                    self.notificationCenterMock.getPendingNotificationRequests { requests in
                        XCTAssertEqual(requests.count, createdHabit.notifications?.count)
                        XCTAssertFalse(
                            requests.filter({$0.content.title == createdHabit.getTitleText()}).isEmpty
                        )

                        nameRescheduleExpectation.fulfill()
                    }
                }
            }
        }

        wait(for: [nameRescheduleExpectation], timeout: 0.2)
    }

    // MARK: Imperatives

    /// Calculates the expected number of created notifications.
    /// - Note: Only notifications with future fire dates are created and scheduled.
    /// - Parameter habit: The habit used to calculate the amount of created notifications.
    /// - Returns: The count to be compared.
    private func getExpectedNotificationsCount(from habit: HabitMO) -> Int {
        // Get all days and check if their fire dates would be in the future and could be accounted.
        guard let days = habit.days as? Set<HabitDayMO> else {
            assertionFailure("Couldn't get the days to calculate the notifications count.")
            return 0
        }
        guard let fireTimes = habit.fireTimes as? Set<FireTimeMO> else {
            assertionFailure("Couldn't get the fireTimes to calculate the notifications count.")
            return 0
        }
        let notificationStorage = NotificationStorage()

        var expectedCount = 0

        for day in days {
            for fireTime in fireTimes {
                if let fireDate = notificationStorage.makeFireDate(
                    from: day,
                    and: fireTime.getFireTimeComponents()
                ), fireDate.isFuture {
                    expectedCount += 1
                }
            }
        }

        return expectedCount
    }
}
