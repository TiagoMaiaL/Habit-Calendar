//
//  DayStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 12/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Habit_Calendar

/// Class in charge of testing the DayStorage methods.
class DayStorageTests: IntegrationTestCase {

    // MARK: Properties

    /// The storage tested by these tests.
    var dayStorage: DayStorage!

    // MARK: setup/tearDown

    override func setUp() {
        super.setUp()

        // Initialize a new DayStorage instance.
        dayStorage = DayStorage()
    }

    override func tearDown() {
        // Remove the initialized storage class.
        dayStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testDayCreation() {
        // Declare the date to be represented by the day entity.
        let dayDate = Date()
        // Create the day by passing the declared date.
        let day = try? dayStorage.create(using: context, and: dayDate)

        // Assert the day isn't nil and has the correct date.
        // The date stored by the new DayMO is always at the
        // beginning of the passed one.
        XCTAssertNotNil(
            day,
            "The created day shouldn't be nil."
        )
        XCTAssertEqual(
            day!.date,
            dayDate.getBeginningOfDay(),
            "The created Day entity should have the correct date property."
        )
        XCTAssertNotNil(
            day!.id,
            "The created Day entity should have an id."
        )
    }

    func testTheCreationOfTheSameDayTwiceShouldThrow() {
        // Create a dummy day.
        let dummyDay = dayFactory.makeDummy()

        // Try to create another day with the same date.
        // Assert that the attempt throws an error.
        XCTAssertThrowsError(
            try dayStorage.create(using: context, and: dummyDay.date!),
            "The attempt to create the same day more than once should throw an error."
        )
    }

    func testSpecificDayFetching() {
        // Create the dummy day and hold its date for comparision.
        guard let date = dayFactory.makeDummy().date else {
            XCTFail("The day dummy lacks the date property.")
            return
        }

        // Fetch the generated dummy.
        let fetchedDay = dayStorage.day(using: context, and: date)

        // Assert that the fetched day's date is right.
        XCTAssertNotNil(
            fetchedDay,
            "The dummy day should be correctly fetched."
        )
        XCTAssertEqual(
            date,
            fetchedDay?.date, "The fetched Day's date should be correct."
        )
    }

    func testDayDeletion() {
        // Create a dummy day and hold its date for fetching.
        let dummyDay = dayFactory.makeDummy()
        guard let date = dummyDay.date else {
            XCTFail("The day dummy lacks the date property.")
            return
        }

        // Fetch the dummy day and ensure it's returned.
        XCTAssertNotNil(
            dayStorage.day(using: context, and: date),
            "The created dummy should be correclty fetched before the deletion."
        )

        // Delete the created entity.
        dayStorage.delete(dummyDay, from: context)

        // Try to fetch the dummy day again, now it shouldn't be fetched.
        XCTAssertNil(
            dayStorage.day(using: context, and: date),
            "The deleted Day's fetch attempt should return nil."
        )
    }
}
