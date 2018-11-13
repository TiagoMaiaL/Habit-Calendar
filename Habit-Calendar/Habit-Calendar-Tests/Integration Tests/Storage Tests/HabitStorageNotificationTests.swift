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
        let fireTimeComponents = [
            DateComponents(hour: 23, minute: 59)
        ]

        // 2. Create the habit.
        let createdHabit = habitStorage.create(
            using: context,
            user: dummyUser,
            name: "Testing notifications",
            color: .systemBlue,
            days: days,
            and: fireTimeComponents
        )
        guard let fireTimes = createdHabit.fireTimes as? Set<FireTimeMO> else {
            XCTFail("Couldn't get the fire times from the created habit.")
            return
        }

        // 3 Assert that the fire times have a notification entiity associated with them.
        XCTAssertTrue(fireTimes.filter({ $0.notification == nil }).isEmpty)

        // Use a timer to make the assertions on the scheduling of user
        // notifications. Scheduling notifications is an async operation.
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            // 4. Assert that the notifications of the habit were scheduled.
            self.notificationCenterMock.getPendingNotificationRequests { requests in
                XCTAssertEqual(requests.count, fireTimes.count)

                // 4.1. Assert on the identifiers of each notificationMO and user notifications.
                let identifiers = Set(requests.map { $0.identifier })
                let notificationIdentifiers = Set(fireTimes.compactMap({ $0.notification?.userNotificationId }))

                XCTAssertEqual(identifiers, notificationIdentifiers)

                scheduleExpectation.fulfill()
            }
        }
        wait(for: [scheduleExpectation], timeout: 0.2)
    }

    func testHabitEditionWithFireTimesPropertyShouldCreateFireTimeEntities() {
        // 1. Create a dummy habit.
        let dummyHabit = habitFactory.makeDummy()
        dummyHabit.removeFromFireTimes(dummyHabit.fireTimes ?? [])

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
            andFireTimes: fireTimes
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
        if let fireTimesToDelete = dummy.fireTimes {
            dummy.removeFromFireTimes(fireTimesToDelete)
        }

        // 2. Declare the fire times.
        let fireTimeComponents = [
            DateComponents(hour: 15, minute: 30),
            DateComponents(hour: 11, minute: 15)
        ]

        // 3. Create the notifications by providing the components.
        _ = habitStorage.edit(
            dummy,
            using: context,
            andFireTimes: fireTimeComponents
        )

        // 4. Fetch the dummy's notifications and make assertions on it.
        // 4.1. Check if the count is the expected one.
        guard let fireTimes = dummy.fireTimes as? Set<FireTimeMO> else {
            XCTFail("The fire times weren't properly created.")
            return
        }

        XCTAssertTrue(fireTimes.filter({ $0.notification == nil }).isEmpty)
    }

    func testEditingHabitFireTimesShouldRescheduleUserNotifications() {
        let rescheduleExpectation = XCTestExpectation(
            description: "Reschedules the user notifications after changing the notifications fire times."
        )

        // Enable the mock's authorization to schedule the notifications.
        notificationCenterMock.shouldAuthorize = true

        // 1. Declare the dummy habit.
        let dummyHabit = habitFactory.makeDummy()
        if let fireTimesToDelete = dummyHabit.fireTimes {
            dummyHabit.removeFromFireTimes(fireTimesToDelete)
        }

        // 2. Declare the new fire tiems.
        let fireTimeComponents = [
            DateComponents(
                hour: 23,
                minute: 0
            ),
            DateComponents(
                hour: 22,
                minute: 30
            ),
            DateComponents(
                hour: 20,
                minute: 0
            )
        ]

        // 3. Edit the habit.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            andFireTimes: fireTimeComponents
        )

        // 4. Assert on the fire times and scheduled notifications.
        XCTAssertEqual(fireTimeComponents.count, dummyHabit.fireTimes?.count)

        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            self.notificationCenterMock.getPendingNotificationRequests { requests in
                XCTAssertEqual(requests.count, fireTimeComponents.count)

                if let newFireTimes = dummyHabit.fireTimes as? Set<FireTimeMO> {
                    let newFireTimeIdentifiers = Set(newFireTimes.compactMap { $0.notification?.userNotificationId })
                    let requestIdentifiers = Set(requests.map { $0.identifier })

                    XCTAssertEqual(requestIdentifiers, newFireTimeIdentifiers)
                } else {
                    XCTFail("The fire times should have been added.")
                }

                rescheduleExpectation.fulfill()
            }
        }

        wait(for: [rescheduleExpectation], timeout: 0.2)
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
        let fireTimeComponents = [
            DateComponents(hour: 23, minute: 59)
        ]

        // 2. Create the habit.
        let createdHabit = habitStorage.create(
            using: context,
            user: userFactory.makeDummy(),
            name: "Testing notifications",
            color: .systemBlue,
            days: days,
            and: fireTimeComponents
        )

        // 2. Check on its current notifications.
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            self.notificationCenterMock.getPendingNotificationRequests { requests in
                XCTAssertEqual(fireTimeComponents.count, requests.count)

                // 3. Edit it by changing its name.
                let newName = "Go skating"
                _ = self.habitStorage.edit(createdHabit, using: self.context, name: newName)

                // 4. Check if the notifications were properly scheduled and if the name was changed.
                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
                    self.notificationCenterMock.getPendingNotificationRequests { requests in
                        XCTAssertEqual(requests.count, createdHabit.fireTimes?.count)
                        XCTAssertFalse(requests.filter { $0.content.title == createdHabit.getTitleText() }.isEmpty)

                        nameRescheduleExpectation.fulfill()
                    }
                }
            }
        }

        wait(for: [nameRescheduleExpectation], timeout: 0.2)
    }

    func testRemovingFireTimesFromHabitShouldUnscheduleNotifications() {
        notificationCenterMock.shouldAuthorize = true
        let expectation = XCTestExpectation(description: "Unschedule notifications and remove fire times.")

        // 1. Declare a dummy habit.
        let dummy = habitFactory.makeDummy()
        notificationScheduler.scheduleNotifications(for: dummy)

        // 2. Remove its fire times using the storage (empty fire times array).
        _ = habitStorage.edit(dummy, using: context, andFireTimes: [])

        // 3. Make assertions on the number of fire times and pending requests.
        XCTAssertEqual(dummy.fireTimes?.count, 0)
        notificationCenterMock.getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testPendingRequestsAreRemovedWhenDeletingHabit() {
        let expectation = XCTestExpectation(description: "The habit's pending requests should be deleted as well.")

        // 1. Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Schedule its notifications.
        guard (dummyHabit.fireTimes?.count ?? 0) > 0 else {
            XCTFail("The dummy habit must have fire times to continue with the test.")
            return
        }

        notificationCenterMock.shouldAuthorize = true
        notificationScheduler.scheduleNotifications(for: dummyHabit)

        notificationCenterMock.getPendingNotificationRequests { requests in
            XCTAssertEqual(dummyHabit.fireTimes?.count, requests.count)

            // 3. Delete the habit.
            self.habitStorage.delete(dummyHabit, from: self.context)

            // 4. Assert its pending requests were removed as well.
            self.notificationCenterMock.getPendingNotificationRequests { requests in
                XCTAssertEqual(0, requests.count, "The pending notification requests should also have been removed.")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.2)
    }
}
