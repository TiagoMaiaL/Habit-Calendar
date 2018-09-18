//
//  HabitStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 13/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Habit_Calendar

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
        let name = "Go Jogging"
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
        let color = HabitMO.Color.systemBlue
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
            color: .systemPink,
            days: [Date(), Date().byAddingDays(10)!, Date().byAddingDays(15)!],
            and: fireTimes
        )

        // 3. Make assertions on the habit's fire times.
        XCTAssertTrue(
            habit.fireTimes?.count == fireTimes.count,
            "The habit should have notifications created with it."
        )
    }

    func testHabitNameTreatmentInCreation() {
        // 1. Declare the dependencies to create a habit.
        let user = userFactory.makeDummy()
        let days = [Date().byAddingDays(-1), Date()].compactMap { $0 }

        // 2. Create the new habit.
        let habit = habitStorage.create(
            using: context,
            user: user,
            name: " testing        ",
            color: .systemPink,
            days: days
        )

        // 3. Assert the returned habit has the expected name.
        XCTAssertEqual("Testing", habit.name)
    }

    func testHabitNameTreatmentInEdition() {
        // 1. Declare a dummy habit.
        let habit = habitFactory.makeDummy()

        // 2. Edit the habit.
        _ = habitStorage.edit(habit, using: context, name: "   testing again      ")

        // 3. Assert the name is correct.
        XCTAssertEqual("Testing Again", habit.name)
    }

    func testInProgressFetchedResultsController() {
        // 1. Get the fetched results controller.
        let fetchedResultsController = habitStorage.makeFetchedResultsController(context: context)

        // 2. Add some dummy habits.
        let dummyHabits = [habitFactory.makeDummy(), habitFactory.makeDummy(), habitFactory.makeDummy()]

        // 3. Perform the fetch.
        try? fetchedResultsController.performFetch()

        // 4. Assert that the count of fetched habits is the same as the declared one.
        XCTAssertEqual(dummyHabits.count, fetchedResultsController.fetchedObjects?.count)
    }

    func testCompletedFetchedResultsController() {
        // 1. Get the fetched results controller.
        let fetchedResultsController = habitStorage.makeCompletedFetchedResultsController(context: context)

        // 2. Add some completed dummy habits.
        let dummyHabits = [habitFactory.makeDummy(), habitFactory.makeDummy(), habitFactory.makeDummy()]

        for habit in dummyHabits {
            if let challenge = habit.getCurrentChallenge() {
                habit.removeFromChallenges(challenge)
                context.delete(challenge)
                habit.addToChallenges(daysChallengeFactory.makeCompletedDummy())
            }
        }

        // 3. Perform the fetch.
        try? fetchedResultsController.performFetch()

        // 4. Assert that the count of fetched habits is the same as the declared one.
        XCTAssertEqual(dummyHabits.count, fetchedResultsController.fetchedObjects?.count)
    }

    func testHabitFetch() {
        // 1. Make a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Try to fetch.
        let fetchedHabit = habitStorage.habit(using: context, and: dummyHabit.id!)

        // 3. Assert it isn't nil and has the same id.
        XCTAssertNotNil(fetchedHabit)
        XCTAssertEqual(dummyHabit.id, fetchedHabit?.id)
    }

    func testHabitFetchShouldReturnNil() {
        // 1. Try to fetch by using an arbitrary id.
        let fetchAttempt = habitStorage.habit(using: context, and: "invalid id")

        // 2. Assert it's nil.
        XCTAssertNil(fetchAttempt)
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
        let colorToEdit = HabitMO.Color.systemTeal
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
        let daysDates = (0..<14).compactMap { dayIndex -> Date? in
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
}
