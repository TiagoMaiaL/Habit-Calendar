//
//  HabitStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 13/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Active

/// Class in charge of testing the HabitStorage methods.
class HabitStorageTests: IntegrationTestCase {

    // MARK: Properties

    var dayStorage: DayStorage!
    var habitDayStorage: HabitDayStorage!
    var daysChallengeStorage: DaysChallengeStorage!
    var notificationStorage: NotificationStorage!
    var notificationCenterMock: UserNotificationCenterMock!
    var notificationScheduler: NotificationScheduler!
    var habitStorage: HabitStorage!

    // MARK: setup/tearDown

    override func setUp() {
        super.setUp()

        // Initialize the DayStorage.
        dayStorage = DayStorage()

        // Initialize the HabitDayStorage.
        habitDayStorage = HabitDayStorage(
            calendarDayStorage: dayStorage
        )

        daysChallengeStorage = DaysChallengeStorage(
            habitDayStorage: habitDayStorage
        )

        // Initialize the notification manager used by the storage.
        notificationCenterMock = UserNotificationCenterMock(
            withAuthorization: false
        )
        notificationScheduler = NotificationScheduler(
            notificationManager: UserNotificationManager(
                notificationCenter: notificationCenterMock
            )
        )

        // Initialize the notification storage.
        notificationStorage = NotificationStorage()

        // Initialize dayStorage using the persistent container created for tests.
        habitStorage = HabitStorage(
            daysChallengeStorage: daysChallengeStorage,
            notificationStorage: notificationStorage,
            notificationScheduler: notificationScheduler,
            fireTimeStorage: FireTimeStorage()
        )
    }

    override func tearDown() {
        // Remove the initialized storages.
        dayStorage = nil
        habitDayStorage = nil
        daysChallengeStorage = nil
        notificationScheduler = nil
        notificationStorage = nil
        habitStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testHabitCreation() {
        let name = "Go jogging"
        let days = (0...7).compactMap { dayNumber in
            // Create and return a date by adding the number of days.
            Date().byAddingDays(dayNumber)
        }

        // If there are no days in the array, the test shouldn't proceed.
        guard !days.isEmpty else {
            XCTFail("FIX: The dates for the Habit creation can't be empty.")
            return
        }

        // Create the habit.
        let color = HabitMO.Color.alizarin
        let joggingHabit = habitStorage.create(
            using: context,
            user: userFactory.makeDummy(),
            name: name,
            color: color,
            days: days
        )

        // Check the habit's id property.
        XCTAssertNotNil(
            joggingHabit.id,
            "Created Habit entities should have an id."
        )

        // Check the habit's name.
        XCTAssertEqual(
            joggingHabit.name,
            name
        )
        // Check the habit's created property.
        XCTAssertNotNil(
            joggingHabit.createdAt,
            "Created habit should have the creation date."
        )
        // Check the habit's color property.
        XCTAssertEqual(
            joggingHabit.color,
            color.rawValue,
            "The created habit should have the expected color."
        )

        // Briefly check to see if there's the right amount of days in the created challenge:
        // Check if the challenge was created.
        XCTAssertEqual(
            joggingHabit.challenges?.count,
            1,
            "The habit should have a challenge containing all habit days."
        )

        // Check if the challenge has the right amount of days.
        guard let challenge = (joggingHabit.challenges as? Set<DaysChallengeMO>)?.first else {
            XCTFail("Couldn't get the generated days challenge.")
            return
        }
        XCTAssertEqual(challenge.days?.count, days.count, "The challenge should have the correct amount of days")
    }

    func testHabitCreationByPassingFireTimes() {
        // 1. Declare the fire times' components.
        let fireTimes = [
            DateComponents(
                hour: Int.random(0..<59),
                minute: Int.random(0..<59)
            ),
            DateComponents(
                hour: Int.random(0..<59),
                minute: Int.random(0..<59)
            ),
            DateComponents(
                hour: Int.random(0..<59),
                minute: Int.random(0..<59)
            )
        ]

        // 2. Create the habit.
        let habit = habitStorage.create(
            using: context,
            user: userFactory.makeDummy(),
            name: "exercise",
            color: .alizarin,
            days: [Date().byAddingDays(10)!, Date().byAddingDays(15)!],
            and: fireTimes
        )

        // 3. Make assertions on the habit's fire times.
        XCTAssertTrue(
            habit.fireTimes?.count == fireTimes.count,
            "The habit should have notifications created with it."
        )
    }

    func testHabitFetchedResultsControllerFactory() {
        // Get the fetched results controller.
        let fetchedResultsController = habitStorage.makeFetchedResultsController(context: context)

        // Assert on its fetch request.
        XCTAssertEqual(
            "Habit",
            fetchedResultsController.fetchRequest.entityName,
            "Only Habit entities should be fetched by the controller."
        )

        // Assert on its sort descriptors.
        guard let sortDescriptors = fetchedResultsController.fetchRequest.sortDescriptors else {
            XCTFail(
                "The fetched Habit entities should be sorted."
            )
            return
        }

        // The sort descriptors should sort in both
        // the created or score properties.
        XCTAssertEqual(
            1,
            sortDescriptors.count,
            "The Habits should be sorted by the created and score properties."
        )
        XCTAssertEqual(
            sortDescriptors[0].key,
            "createdAt",
            "Should sort by the Habit entity's created property."
        )
    }

    func testHabitEditionWithNameProperty() {
        // Declare the name to be set.
        let habitName = "Fight Muay-Thai"

        // Declare a habit dummy.
        let habitDummy = habitFactory.makeDummy()

        // Edit the Habit to change the name.
        let editedHabit = habitStorage.edit(
            habitDummy,
            using: context,
            name: habitName
        )

        // Assert that the edited habit and the dummy one are the same.
        XCTAssertEqual(
            editedHabit,
            habitDummy,
            "The edition routine should return the same habit instance but with the edited properties.."
        )

        // Assert on the name property.
        XCTAssertEqual(
            habitDummy.name,
            habitName,
            "The dummy habit should now have the edited name."
        )
    }

    func testHabitEditionWithColorProperty() {
        // 1. Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Edit it with the desired color.
        let colorToEdit = HabitMO.Color.amethyst
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            color: colorToEdit
        )

        // 3. Assert the habit entity now has the passed color.
        XCTAssertEqual(
            dummyHabit.color,
            colorToEdit.rawValue,
            "The editted habit should have the amethyst color."
        )
    }

    func testHabitEditionWithDaysPropertyShouldCreateNewChallenge() {
        // 1. Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Create a new array of days' dates.
        let daysDates = (1..<14).compactMap { dayIndex -> Date? in
            Date().byAddingDays(dayIndex)
        }

        // 3. Edit the days property.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            days: daysDates
        )

        // 4. Make assertions on the days and challenge:
        // 4.1. Assert on the days challenge.
        XCTAssertEqual(
            dummyHabit.challenges?.count,
            2,
            "A new challenge should have been created after the days edition."
        )

        guard let challenge = dummyHabit.getCurrentChallenge() else {
            XCTFail("Couldn't get the current challenge.")
            return
        }

        // 4.2. Assert on the days' count.
        XCTAssertEqual(
            challenge.days?.count,
            daysDates.count,
            "The Habit days should be correctly set and have the expected count."
        )

        // 4.3. Assert on the days' dates.
        guard let habitDays = challenge.days as? Set<HabitDayMO> else {
            XCTFail("Couldn't get the edited habit days.")
            return
        }
        for habitDay in habitDays {
            // 4.2.1. Check if the day's date is in the expected dates.
            XCTAssertTrue(
                daysDates.map { $0.getBeginningOfDay().description }.contains(
                    habitDay.day?.date?.description ?? ""
                ),
                "The new added day should have a correct day among the specified ones."
            )
        }
    }

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

    func testHabitDeletion() {
        // Create a new habit.
        let dummyHabit = habitFactory.makeDummy()

        // Delete the created habit.
        habitStorage.delete(dummyHabit, from: context)

        // Assert it was deleted.
        XCTAssertTrue(
            dummyHabit.isDeleted,
            "The habit entity should be marked as deleted."
        )
    }

    func testCreatingHabitShouldScheduleUserNotifications() {
        notificationCenterMock.shouldAuthorize = true
        let scheduleExpectation = XCTestExpectation(
            description: "Create a new habit and create and schedule the notifications."
        )

        // 1. Declare the habit attributes needed for creation:
        let dummyUser = userFactory.makeDummy()
        let days = (1..<Int.random(2..<50)).compactMap {
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
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            // 3. Assert that the habit's notifications were scheduled:
            // - Assert on the count of notifications and user notifications.
            XCTAssertEqual(
                createdHabit.notifications?.count,
                days.count * fireTimes.count
            )
            self.notificationCenterMock.getPendingNotificationRequests { requests in
                XCTAssertEqual(
                    requests.count,
                    days.count * fireTimes.count
                )

                // - Assert on the identifiers of each notificationMO and
                //   user notifications.
                let identifiers = requests.map { $0.identifier }
                guard let notificationsSet = createdHabit.notifications as? Set<NotificationMO> else {
                    XCTFail("The notifications weren't properly created.")
                    return
                }
                let notifications = Array(notificationsSet)

                XCTAssertTrue(
                    notifications.filter {
                        return !identifiers.contains( $0.userNotificationId! )
                    }.count == 0,
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
        let days = (1..<Int.random(2..<50)).compactMap {
            Date().byAddingDays($0)
        }

        // 3. Edit the habit.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            days: days
        )

        guard let challenge = dummyHabit.getCurrentChallenge() else {
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

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in

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

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in

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
        let days = (1..<Int.random(3..<50)).compactMap {
            Date().byAddingDays($0)
        }
        let fireTimes = [
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

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in

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
