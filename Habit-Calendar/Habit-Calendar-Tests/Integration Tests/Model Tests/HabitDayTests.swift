//
//  HabitDayTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 26/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import XCTest
@testable import Habit_Calendar

/// Class in charge of testing the HabitDay core data entity methods.
class HabitDayTests: IntegrationTestCase {

    // MARK: Tests

    func testEditionToMarkHabitAsExecutedAtTheDay() {
        // 1. Generate a dummy HabitDay entity.
        let dummyHabitDay = habitDayFactory.makeDummy()

        // 2. Mark it as executed.
        dummyHabitDay.markAsExecuted()

        // 3. Assert it was executed.
        XCTAssertTrue(
            dummyHabitDay.wasExecuted,
            "The habit day should be marked as executed."
        )
        XCTAssertNotNil(
            dummyHabitDay.updatedAt,
            "The habit day should have an updatedAt date."
        )
    }

    func testEditionToMarkHabitAsNotExecutedAtTheDay() {
        // 1. Generate a dummy HabitDay entity.
        let dummyHabitDay = habitDayFactory.makeDummy()

        // 2. Mark it as executed.
        dummyHabitDay.markAsExecuted()

        // 2.1. Assert it was executed.
        XCTAssertTrue(
            dummyHabitDay.wasExecuted,
            "The habit day should be marked as executed."
        )

        // 3. Unmark it as executed.
        dummyHabitDay.markAsExecuted(false)

        // 3.1. Assert it wasn't executed.
        XCTAssertFalse(
            dummyHabitDay.wasExecuted,
            "The habit day shouldn't be marked as executed."
        )
        XCTAssertNotNil(
            dummyHabitDay.updatedAt,
            "The habit day should have an updatedAt date."
        )
    }
}
