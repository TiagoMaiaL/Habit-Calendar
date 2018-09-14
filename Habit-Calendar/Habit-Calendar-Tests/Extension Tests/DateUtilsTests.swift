//
//  DateUtilsTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 13/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
@testable import Habit_Calendar

/// Class in charge of testing the Date Utilities extension.
class DateUtilsTests: XCTestCase {

    // MARK: Tests

    func testGettingDateComponents() {
        // Declare the date.
        let date = Date()

        // Get the date's components.
        let dateComponents = Calendar.current.dateComponents(
            [.second, .minute, .hour, .day, .month, .year],
            from: date
        )

        // Compare with the extension's one.
        XCTAssertEqual(dateComponents, date.components)
    }

    func testGettingTheBeginningOfToday() {
        // Declare today's date.
        let today = Date()

        // Get the date representing the beginning (midnight) of today's date.
        let todayBeginning = today.getBeginningOfDay()

        // Compare the dates' day, month and year.
        XCTAssertEqual(
            today.components.day,
            todayBeginning.components.day,
            "The dates should have equal days."
        )
        XCTAssertEqual(
            today.components.month,
            todayBeginning.components.month,
            "The dates should have equal months."
        )
        XCTAssertEqual(
            today.components.year,
            todayBeginning.components.year,
            "The dates should have equal years."
        )

        // Check if the generated date represents the previous date at midnight.
        XCTAssertEqual(
            todayBeginning.components.minute,
            0,
            "The beginning of a day's date should be at midnight (0 minutes).")
        XCTAssertEqual(
            todayBeginning.components.hour,
            0,
            "The beginning of a day's date should be at midnight (0 hours, midnight)."
        )
    }

    func testGettingTheEndOfToday() {
        // Declare today's date.
        let today = Date()

        // Get the date representing the end (23:59 PM) of today's date.
        let todayEnd = today.getEndOfDay()

        // Compare the dates' day, month and year.
        XCTAssertEqual(today.components.day, todayEnd.components.day, "The dates should have equal days.")
        XCTAssertEqual(today.components.month, todayEnd.components.month, "The dates should have equal months.")
        XCTAssertEqual(today.components.year, todayEnd.components.year, "The dates should have equal years.")

        // Check if the generated date represents the previous date at the end.
        XCTAssertEqual(todayEnd.components.minute, 59, "The end of a day's date should be at 59 minutes.")
        XCTAssertEqual(todayEnd.components.hour, 23, "The end of a day's date should be at 23 hours.")
    }

    func testGettingDateByAddingMinutes() {
        // Declare a date at the beginning of the day.
        let today = Date().getBeginningOfDay()

        // Get a new date by adding 2 hours (120 minutes)
        let fifteen = today.byAddingMinutes(15)

        // Compare the month, year and day components, they should be equal.
        XCTAssertEqual(
            today.components.day,
            fifteen?.components.day,
            "The days shouldn't be changed."
        )
        XCTAssertEqual(
            today.components.month,
            fifteen?.components.month,
            "The months shouldn't be changed."
        )
        XCTAssertEqual(
            today.components.year,
            fifteen?.components.year,
            "The years shouldn't be changed."
        )

        // Compare the minutes.
        // The new date should have the initial amount
        // of minutes in Date 1 + 120.
        XCTAssertEqual(
            fifteen?.components.minute,
            (today.components.minute ?? 0) + 15,
            "The new date should have the expected amount of minutes."
        )
    }

    func testGettingDateByAddingDays() {
        // Declare a date at the beginning of the month.
        let date = Calendar.current.date(
            bySetting: .day,
            value: 1,
            of: Date()
        )

        // Get a new date by adding a number of days to the original date.
        let dateAfter = date?.byAddingDays(7)

        // Compare the dates' month and year components.
        XCTAssertEqual(date?.components.month, dateAfter?.components.month)
        XCTAssertEqual(date?.components.year, dateAfter?.components.year)

        // Check if the days were correclty added.
        XCTAssertEqual(
            (date?.components.day ?? 1) + 7,
            dateAfter?.components.day,
            "The days should be correclty added."
        )
    }

    func testGettingDateByAddingMonths() {
        // Declare a date at the beginning of the year.
        let beginningOfYear = Calendar.current.date(
            bySetting: .month,
            value: 1,
            // Get the first day of the month
            of: Calendar.current.date(
                bySetting: .day,
                value: 1,
                of: Date()
            ) ?? Date()
        )

        // Get a new date by adding the months.
        let sevenMonthsLater = beginningOfYear?.byAddingMonths(7)

        // Compare the dates' day component.
        XCTAssertNotNil(sevenMonthsLater)
        XCTAssertEqual(beginningOfYear?.components.year, sevenMonthsLater?.components.year)
        XCTAssertEqual(beginningOfYear?.components.day, sevenMonthsLater?.components.day)

        // Compare the components to check if the months were properly added.
        XCTAssertEqual(
            (beginningOfYear?.components.month ?? 0) + 7,
            sevenMonthsLater?.components.month,
            "The months weren't properly added."
        )
    }

    func testGettingDateByAddingYears() {
        // Get the current date.
        let now = Date()

        // Declare the years to be added.
        let randomNumber = Int.random(0..<1_000_000)

        // Get a new date by appending two years to the initial one.
        let twoYearsFromNow = now.byAddingYears(randomNumber)

        // Compare the days and months.
        XCTAssertEqual(
            now.components.day,
            twoYearsFromNow?.components.day,
            "The two dates should have the same day number."
        )
        XCTAssertEqual(
            now.components.month,
            twoYearsFromNow?.components.month,
            "The two dates should have the same month number."
        )

        // Compare the years.
        XCTAssertEqual(
            (now.components.year ?? 0) + randomNumber,
            twoYearsFromNow?.components.year ?? 0,
            "The expected date's year should be the initial date's year + 2."
        )
    }

    func testIfDateIsToday() {
        // Get the current date.
        let now = Date()

        // Assert it's today.
        XCTAssertTrue(
            now.isInToday,
            "The current date should be considered today."
        )
    }

    func testIfDateIsInFuture() {
        // Get the current date.
        let now = Date()

        // Append some days to it.
        guard let futureDate = now.byAddingDays(10) else {
            XCTFail("Couldn't get a day in the future.")
            return
        }

        // Check if it's in the future.
        XCTAssertTrue(
            futureDate.isFuture,
            "The date should be considered to be in the future."
        )
    }

    func testIfDateIsInPast() {
        // Get the current date.
        let now = Date()

        // Remove some days from it.
        guard let futureDate = now.byAddingDays(-5) else {
            XCTFail("Couldn't get a day in the past.")
            return
        }

        // Check if it's in the future.
        XCTAssertTrue(
            futureDate.isPast,
            "The date should be considered to be in the past."
        )
    }

    func testGettingNumberOfDaysBetweenDates() {
        // 1. Declare the range: initial and final dates.
        let daysNumber = 13
        let initialDate = Date()
        let finalDate = Date().byAddingDays(daysNumber)!

        // 2. Call the method on the initial date to get the difference in
        // days to another date.
        let difference = initialDate.getDifferenceInDays(from: finalDate)

        // 3. Assert that the difference in days is correct.
        XCTAssertEqual(
            difference,
            daysNumber,
            "The difference between the dates is wrong."
        )
    }

    func testGettingNumberOfDaysBetweenDatesReturnsNegativeDifference() {
        // 1. Declare the range: initial and final dates.
        let daysNumber = 13
        let initialDate = Date()
        let finalDate = Date().byAddingDays(daysNumber)!

        // 2. Call the method on the initial date to get the difference in
        // days to another date.
        let difference = finalDate.getDifferenceInDays(from: initialDate)

        // 3. Assert that the difference in days is correct.
        XCTAssertEqual(
            difference,
            -daysNumber,
            "The difference between the dates isn't the expected negative one."
        )
    }

    func testGettingTheBeginningOfMonth() {
        let today = Date()

        // Get the beginning of the month.
        let beginningOfMonth = today.getBeginningOfMonth()

        // Compare the year and month components.
        XCTAssertNotNil(beginningOfMonth)
        XCTAssertEqual(today.components.year, beginningOfMonth?.components.year)
        XCTAssertEqual(today.components.month, beginningOfMonth?.components.month)

        // The day component must be equals to one.
        XCTAssertEqual(
            beginningOfMonth?.components.day,
            1,
            "The date should be at the beginning of the month."
        )
    }

    func testIsDateInBetweenShouldReturnTrue() {
        // Declare three dates: A past one, today, and a future one.
        let today = Date()
        guard let pastDate = today.byAddingDays(-34) else {
            XCTFail("Error: couldn't generate the past date.")
            return
        }
        guard let futureDate = today.byAddingDays(25) else {
            XCTFail("Error: couldn't generate the future date.")
            return
        }

        // Assert it returns true.
        XCTAssertTrue(today.isInBetween(pastDate, futureDate))
    }

    func testIsDateInBetweenShouldReturnFalseWhenOtherDatesAreFuture() {
        // Declare three dates: today, a future one, and another one in the future.
        let today = Date()
        guard let futureDate1 = today.byAddingDays(20) else {
            XCTFail("Error: couldn't generate the future date.")
            return
        }
        guard let futureDate2 = today.byAddingDays(25) else {
            XCTFail("Error: couldn't generate the future date.")
            return
        }

        // Assert it returns false.
        XCTAssertFalse(today.isInBetween(futureDate1, futureDate2))
    }

    func testIsDateInBetweenShouldReturnFalseWhenOtherDatesArePast() {
        // Declare three dates: today, a past one, and another one in the past.
        let today = Date()
        guard let pastDate1 = today.byAddingDays(-17) else {
            XCTFail("Error: couldn't generate the past date.")
            return
        }
        guard let pastDate2 = today.byAddingDays(-4) else {
            XCTFail("Error: couldn't generate the past date.")
            return
        }

        // Assert it returns false.
        XCTAssertFalse(today.isInBetween(pastDate1, pastDate2))
    }
}
