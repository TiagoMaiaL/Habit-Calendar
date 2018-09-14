//
//  HabitDayStorage.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 26/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Habit_Calendar

/// Class in charge of testing the HabitDayStorage methods.
class HabitDayStorageTests: IntegrationTestCase {

    // MARK: Properties

    /// The day storage to be used.
    var dayStorage: DayStorage!

    /// The habit day storage to be tested.
    var habitDayStorage: HabitDayStorage!

    // MARK: setup/teardown

    override func setUp() {
        super.setUp()

        // Initialize the Day storage.
        dayStorage = DayStorage()

        // Initialize the HabitDay storage.
        habitDayStorage = HabitDayStorage(calendarDayStorage: dayStorage)
    }

    override func tearDown() {
        // Remove the initialized storage class.
        habitDayStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testCreationByPassingTheDayAndHabit() {
        // 1. Declare the dummy habit to be used.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Declare the day's date.
        guard let date = Date().byAddingDays(3) else {
            XCTFail("Couldn't generate a fake date.")
            return
        }

        // 3. Create the HabitDay out of the habit and date.
        let habitDay = habitDayStorage.create(
            using: context,
            date: date,
            and: dummyHabit
        )

        // 3.1. Make an assertion to check if the habit has the returned
        //      HabitDay entity.
        XCTAssertTrue(
            dummyHabit.days?.contains(habitDay) ?? false,
            "The habit day is not associated to the passed habit."
        )

        // 3.2. Make an assertion to check if the HabitDay has a valid Day
        //      entity and has the expected date.
        XCTAssertNotNil(
            habitDay.day,
            "The HabitDay entity should have an associated Day entity."
        )
        XCTAssertNotNil(
            habitDay.id,
            "The created habit day should have an id."
        )
        XCTAssertNotNil(
            habitDay.day!.date,
            "The HabitDay's Day entity shouldn't be invalid."
        )
        XCTAssertEqual(
            habitDay.day!.date!.description,
            date.getBeginningOfDay().description,
            "The habitDay's Day doesn't have the expected date value."
        )
    }

    func testDaysCreationByPassingTheDaysDatesAndHabit() {
        // 1. Declare the habit dummy to be used.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Declare the Day dates to be used.
        let days = (1...7).compactMap { dayIndex -> Date? in
            return Date().byAddingDays(dayIndex)
        }

        XCTAssertEqual(
            7,
            days.count,
            "Couldn't generate the dates for the days."
        )

        // 3. Create the habitDays:
        let habitDays = habitDayStorage.createDays(
            using: context,
            dates: days,
            and: dummyHabit
        )

        // 3.1. Make assertions on the count
        //      (must be equals to the number of days used).
        XCTAssertEqual(habitDays.count, days.count)

        // 3.2. Make assertions to check if the days belong to
        //      the passed habit.
        for habitDay in habitDays {
            XCTAssertTrue(
                dummyHabit.days?.contains(habitDay) ?? false,
                "The HabitDay isn't associated to the dummy Habit entity."
            )
        }

        // 3.3. Make assertions on the dates of each day and
        //      check if they are contained in the array.
        for habitDay in habitDays {
            XCTAssertNotNil(
                habitDay.day,
                "The HabitDay doesn't have an associated Day entity."
            )
            XCTAssertNotNil(
                habitDay.day!.date,
                "The HabitDay doesn't have a valid Day entity."
            )
            XCTAssertTrue(
                days.map { $0.getBeginningOfDay().description }.contains(habitDay.day!.date!.description),
                "The HabitDay's entity isn't correct, its date isn't inside the expected ones."
            )
        }
    }

    func testRemovalFromHabit() {
        // 1. Create a dummy Habit with a dummy HabitDay.
        let dummyHabit = habitFactory.makeDummy()
        let dummyHabitDay = habitDayFactory.makeDummy()

        dummyHabitDay.habit = dummyHabit

        // 2. Remove the created habitDay.
        habitDayStorage.delete(
            dummyHabitDay,
            from: dummyHabit.managedObjectContext!
        )

        // 3. Assert that it's not contained in the dummyHabit.
        XCTAssertTrue(
            dummyHabitDay.isDeleted,
            "The habitDay wasn't deleted, but it should."
        )
    }
}
