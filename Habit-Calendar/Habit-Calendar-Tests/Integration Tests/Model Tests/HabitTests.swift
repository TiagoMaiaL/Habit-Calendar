//
//  HabitTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 25/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import XCTest
@testable import Habit_Calendar

/// Class in charge of testing the Habit core data entity methods.
class HabitTests: IntegrationTestCase {

    // MARK: Properties

    var habitDayStorage: HabitDayStorage!

    // MARK: setup/tearDown

    override func setUp() {
        super.setUp()

        // Initialize the habitDayStorage.
        habitDayStorage = HabitDayStorage(calendarDayStorage: DayStorage())
    }

    override func tearDown() {
        // Remove the HabitDayStorage.
        habitDayStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testTitleText() {
        // Declare the expected habit name which should be presented as the title.
        let habitName = "Read more"

        // Create a dummy Habit.
        let dummyHabit = habitFactory.makeDummy()
        dummyHabit.name = habitName

        // Get the title text.
        let title = dummyHabit.getTitleText()

        // Assert it's the expected title.
        XCTAssertEqual(title, habitName)
    }

    func testSubtitleText() {
        // Declare the expected subtitle message.
        let expectedSubtitle = "Did you practice this activity today?"

        // Create a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // Assert the habit's subtitle is the expected one.
        XCTAssertEqual(dummyHabit.getSubtitleText(), expectedSubtitle)
    }

    func testFetchForExecutedDays() {
        // 1. Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Declare the habitDays to be added to the habit.
        let dates = (1...63).compactMap { dayIndex -> Date? in
            Date().byAddingDays(dayIndex)
        }

        XCTAssert(
            dates.count == 63,
            "Couldn't correctly generate the dates."
        )

        let habitDays = habitDayStorage.createDays(
            using: context,
            dates: dates,
            and: dummyHabit
        )

        // 3. Mark some of them as executed and add them
        //    to a set.
        var executedDays = Set<HabitDayMO>()

        for index in 0..<37 {
            let habitDay = habitDays[index]
            habitDay.markAsExecuted()
            executedDays.insert(habitDay)
        }

        // 4. Check to see if the fetch returns the correct
        //    amount of habitDays.
        XCTAssertEqual(
            dummyHabit.executedCount,
            executedDays.count,
            "The habit's count of the executed days is incorrect."
        )
    }

    func testPercentageExecutionProperty() {
        // 1. Declare the number of days.
        let numberOfDays = Int.random(2..<26)
        // 1.1. Declare the number of executed days.
        let numberOfExecutedDays = Int.random(0..<numberOfDays)
        // 1.2. Declare the expected percentage.
        let executionPercentage = (Double(numberOfExecutedDays) / Double(numberOfDays)) * 100

        // 2. Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()
        // 2.1. Clear the dummy days that come with the habit.
        if let days = dummyHabit.days as? Set<HabitDayMO> {
            for habitDay in days {
                dummyHabit.removeFromDays(habitDay)
            }
        }

        // 3. Declare the habitDays to be added to the habit.
        let dates = (1...numberOfDays).compactMap { dayIndex -> Date? in
            Date().byAddingDays(dayIndex)
        }
        XCTAssert(
            dates.count == numberOfDays,
            "Couldn't correctly generate the dates."
        )

        let habitDays = habitDayStorage.createDays(
            using: context,
            dates: dates,
            and: dummyHabit
        )

        // 3.1. Declare 10 of the habit Days as executed.
        for index in 0..<numberOfExecutedDays {
            let habitDay = habitDays[index]
            habitDay.markAsExecuted()
        }

        // 4. Assert the returned percentage from the
        //    model is correct.
        XCTAssertEqual(
            executionPercentage,
            dummyHabit.executionPercentage,
            "The execution percentage is not the expected one."
        )
    }

    func testGettingCurrentHabitDay() {
        // Create an empty dummy habit.
        let dummyHabit = makeEmptyDummy()

        // Add a habit day to it.
        let dummyDay = dayFactory.makeDummy()
        let dummyHabitDay = habitDayFactory.makeDummy()

        dummyHabitDay.day = dummyDay
        dummyHabitDay.habit = dummyHabit

        // Check if it returns the current habit day (corresponding to today).
        XCTAssertNotNil(
            dummyHabit.getCurrentDay(),
            "There should be a current habit day being tracked."
        )
    }

    func testGettingCurrentHabitDayShouldReturnNil() {
        // Create an empty dummy habit.
        let dummyHabit = makeEmptyDummy()

        // Check if it returns the current habit day (corresponding to today).
        XCTAssertNil(
            dummyHabit.getCurrentDay(),
            "There shouldn't be a current habit day being tracked."
        )
    }

    func testFetchingFutureDays() {
        // Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // Get its future days by filtering through them.
        guard let futureDays = (dummyHabit.days as? Set<HabitDayMO>)?.filter({ $0.day?.date?.isFuture ?? false }) else {
            XCTFail("Couldn't get the future days only.")
            return
        }

        // Compare the count with the one returned by
        // the entity's method (getFutureDays).
        XCTAssertEqual(
            futureDays.count,
            dummyHabit.getFutureDays().count,
            "The method should return the correct amount of future habit day entities."
        )
    }

    func testGettingCurrentChallengeShouldReturnNil() {
        // 1. Declare an empty habit.
        let emptyHabit = makeEmptyDummy()

        // 2. Assert is current challenge is nil.
        XCTAssertNil(
            emptyHabit.getCurrentChallenge(),
            "An empty habit shouldn't return any current challenge."
        )
    }

    func testGettingTheOnlyCurrentChallenge() {
        // 1. Declare an empty habit.
        let emptyHabit = makeEmptyDummy()

        // 2. Add a DaysChallenge to it.
        let daysChallenge = DaysChallengeFactory(context: context)
        let challenge = daysChallenge.makeDummy()
        emptyHabit.addToChallenges(challenge)

        // 3. Assert it's returned when getting the current challenge.
        XCTAssertEqual(
            emptyHabit.getCurrentChallenge(),
            challenge,
            "The current challenge should be correctly returned."
        )
    }

    func testGettingTheCurrentChallengeAmongMany() {
        // 1. Declare an empty habit.
        let emptyHabit = makeEmptyDummy()

        // 2. Add 3 DaysChallengesMO entities to it.
        let challenge1 = DaysChallengeMO(context: context)
        challenge1.fromDate = Date().byAddingDays(-60)!.getBeginningOfDay()
        challenge1.toDate = Date().byAddingDays(-50)!.getBeginningOfDay()

        let challenge2 = DaysChallengeMO(context: context)
        challenge2.fromDate = Date().byAddingDays(-48)!.getBeginningOfDay()
        challenge2.toDate = Date().byAddingDays(-30)!.getBeginningOfDay()

        let challenge3 = DaysChallengeMO(context: context)
        challenge3.fromDate = Date().getBeginningOfDay()
        challenge3.toDate = Date().byAddingDays(10)!.getBeginningOfDay()

        emptyHabit.addToChallenges (
            [challenge1, challenge2, challenge3]
        )

        // 3. Assert it returns the current and correct one.
        XCTAssertEqual(
            emptyHabit.getCurrentChallenge(),
            challenge3,
            "The habit should return its current challenge among all of the added ones."
        )
    }

    func testGettingCurrentChallengeOnItsFinalDay() {
        // 1. Declare a dummy habit with its challenge on the last day.
        let dummyHabit = habitFactory.makeDummy()
        // 1.1 Remove its challenges.
        if let challenges = dummyHabit.challenges as? Set<DaysChallengeMO> {
            dummyHabit.removeFromChallenges(challenges as NSSet)
        }

        // 1.2 Add a new one on its final day.
        let dates = [Date().byAddingDays(-1), Date()].compactMap { $0 }
        guard !dates.isEmpty else {
            XCTFail("Couldn't generate the dummy challenge's dates.")
            return
        }
        dummyHabit.addToChallenges(daysChallengeFactory.makeDummy(using: dates))

        // 2. Assert the current challenge is correctly returned.
        XCTAssertNotNil(dummyHabit.getCurrentChallenge())
    }

    func testGettingColorAsEnum() {
        // 1. Declare a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Get its enum color.
        let color = HabitMO.Color(rawValue: dummyHabit.color)

        // 3. Assert it's equal to the returned.
        XCTAssertEqual(color, dummyHabit.getColor())
    }

    // MARK: Imperatives

    private func makeEmptyDummy() -> HabitMO {
        let habit = HabitMO(context: context)
        // Associate it's properties (id, created, name, color).
        habit.id = UUID().uuidString
        habit.createdAt = Date()
        habit.name = "Random habit name"
        habit.color = HabitMO.Color.systemRed.rawValue

        return habit
    }

}
