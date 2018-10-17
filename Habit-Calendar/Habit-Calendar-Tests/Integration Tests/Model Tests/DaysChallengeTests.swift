//
//  DaysChallengeTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import XCTest
@testable import Habit_Calendar

/// Class in charge of testing the DaysChallengeMO methods.
class DaysChallengeTests: IntegrationTestCase {

    // MARK: Tests

    func testGettingChallengeExecutedDays() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Mark some days as executed.
        guard let daysSet = dummyChallenge.days as? Set<HabitDayMO> else {
            XCTFail("Error: Couldn't get the dummy challenge's days.")
            return
        }
        let habitDays = Array(daysSet)
        let executedCount = habitDays.count / 2

        for index in 0..<executedCount {
            habitDays[index].markAsExecuted()
        }

        // 3. Make assertions on it:
        // Assert on the executed days count.
        XCTAssertEqual(
            executedCount,
            dummyChallenge.getExecutedDays()?.count,
            "The challenge's executed days don't have the expected count."
        )
    }

    func testGettingChallengeMissedDays() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Declare some new past habit days.
        let pastHabitDays = makeHabitDays(from: -36..<0)

        // 2.1 Add them to the challenge.
        dummyChallenge.addToDays(Set(pastHabitDays) as NSSet)

        // 3. Mark some of them as executed.
        guard let pastDaysSet = dummyChallenge.getPastDays() else {
            XCTFail("Error: Couldn't get the dummy challenge's days.")
            return
        }
        let pastDays = Array(pastDaysSet)
        let executedCount = pastDays.count / 3

        for index in 0..<executedCount {
            pastDays[index].markAsExecuted()
        }

        // 4. Assert on the missed days.
        XCTAssertEqual(
            pastDays.count - executedCount,
            dummyChallenge.getMissedDays()?.count,
            "The challenge's missed days don't have the expected count."
        )
    }

    func testGettingInitialProgress() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Assert the past is 0.
        XCTAssertEqual(0, dummyChallenge.getCompletionProgress().past)
    }

    func testGettingCurrentProgressWithCurrentDayNotExecuted() {
        // 1. Declare a dummy challenge with some past dates.
        let dates = [
            Date().byAddingDays(-2),
            Date().byAddingDays(-1),
            Date(),
            Date().byAddingDays(1)
            ].compactMap { $0 }
        let dummyChallenge = daysChallengeFactory.makeDummy(using: dates)

        // 2. Assert the past count is correct.
        let progress = dummyChallenge.getCompletionProgress()
        XCTAssertEqual(2, progress.past)
        XCTAssertEqual(4, progress.total)
    }

    func testGettingCurrentProgressWithCurrentDayExecuted() {
        // 1. Declare a dummy challenge with some past dates.
        let dates = [
            Date().byAddingDays(-2),
            Date(),
            Date().byAddingDays(1)
            ].compactMap { $0 }
        let dummyChallenge = daysChallengeFactory.makeDummy(using: dates)
        dummyChallenge.markCurrentDayAsExecuted()

        // 2. Assert on the past count.
        XCTAssertEqual(2, dummyChallenge.getCompletionProgress().past)
    }

    func testGettingPastProgress() {
        // 1. Declare a dummy challenge in the past.
        let pastChallengeDummy = daysChallengeFactory.makeCompletedDummy()

        // 2. Assert its past dates are equal to the total one.
        let progress = pastChallengeDummy.getCompletionProgress()
        XCTAssertEqual(progress.past, progress.total)
    }

    func testGettingTheCurrentDay() {
        // 1. Create a new dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Get its current day and make assertions on its dates.
        guard let currentDay = dummyChallenge.getCurrentDay() else {
            XCTFail("Couldn't get the challenge's current day.")
            return
        }

        XCTAssertEqual(
            Date().getBeginningOfDay().description,
            currentDay.day!.date!.description,
            "The challenge's current day doesn't have the expected date."
        )
    }

    func testGettingDayFromDate() {
        // 1. Create a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Try to get the day associated with today.
        let habitDay = dummyChallenge.getDay(for: Date())

        // 3. Assert it returned the correct habit day.
        XCTAssertNotNil(habitDay)
        XCTAssertEqual(
            Date().getBeginningOfDay(),
            habitDay?.day?.date,
            "The method should return the correct date."
        )
    }

    func testGettingDayFromDateShouldReturnNil() {
        // 1. Create a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Try to get the day associated with yesterday.
        guard let yesterday = Date().byAddingDays(-1) else {
            XCTFail("Couldn't generate yesterday date.")
            return
        }
        let habitDay = dummyChallenge.getDay(for: yesterday)

        // 3. Assert it returned the correct habit day.
        XCTAssertNil(habitDay)
    }

    func testGettingDayFromDateNotInBeginning() {
        // 1. Create a dummy challenge with a date not in the beginning.
        let dummyChallenge = daysChallengeFactory.makeDummy()
        let dummyDay = dayFactory.makeDummy()

        var components = Date().components
        components.hour = 12
        components.minute = 0
        components.second = 0
        let expectedDate = Calendar.current.date(from: components)

        dummyDay.date = expectedDate

        let habitDay = habitDayFactory.makeDummy()
        habitDay.day = dummyDay

        dummyChallenge.addToDays(habitDay)

        // 2. Try fetching the day.
        XCTAssertNotNil(dummyChallenge.getDay(for: expectedDate!))
    }

    func testGettingEmptyChallengeCurrentDayShouldBeNil() {
        // 1. Create an empty dummy challenge.
        let emptyDummyChallenge = DaysChallengeMO(
            context: context
        )

        // 2. Assert its current day is nil.
        XCTAssertNil(
            emptyDummyChallenge.getCurrentDay(),
            "The empty challenge shouldn't return the current day."
        )
    }

    func testGettingChallengeCurrentDayShouldBeNil() {
        // 1. Create a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()
        // 1.1. Clear it by removing its current day.
        guard let currentDay = dummyChallenge.getCurrentDay() else {
            XCTFail("Couldn't get the challenge's current day.")
            return
        }
        dummyChallenge.removeFromDays(currentDay)
        context.delete(currentDay)

        // 2. Assert its current day now is nil.
        XCTAssertNil(
            dummyChallenge.getCurrentDay(),
            "The challenge shouldn't return its current day."
        )
    }

    func testGettingDayOrderSortedByDate() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Get one of it's days at a random index.
        let sortedByDate = NSSortDescriptor(key: "day.date", ascending: true)
        guard let orderedDays = dummyChallenge.days?.sortedArray(using: [sortedByDate]) as? [HabitDayMO] else {
            XCTFail("Couldn't get the days sorted by date.")
            return
        }
        let randomIndex = Int.random(0..<orderedDays.count)
        let randomDay = orderedDays[randomIndex]

        // 3. Try getting the day's order in the challenge, it should return the expected result.
        XCTAssertNotNil(dummyChallenge.getOrder(of: randomDay))
        XCTAssertEqual(randomIndex + 1, dummyChallenge.getOrder(of: randomDay))
    }

    func testGettingDayOrderSortedByDateShouldReturnNil() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Declare a dummy habit day.
        let dummyHabitDay = habitDayFactory.makeDummy()

        // 3. Try getting the day's order in the challenge, it should return nil.
        XCTAssertNil(dummyChallenge.getOrder(of: dummyHabitDay))
    }

    func testMarkingCurrentDayAsExecuted() {
        // 1. Create a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Mark its current day as executed.
        dummyChallenge.markCurrentDayAsExecuted()

        // 3. Fetch the current day and assert it was
        // marked as executed.
        guard let currentDay = dummyChallenge.getCurrentDay() else {
            XCTFail("Couldn't retrieve the challenge's current day.")
            return
        }

        XCTAssertTrue(
            currentDay.wasExecuted,
            "The current day wasn't marked as executed."
        )
    }

    func testGettingChallengePastDays() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 1.1 Add some past days to it.
        let pastAmount = -25
        let pastDays = makeHabitDays(from: pastAmount..<0)
        dummyChallenge.addToDays(Set(pastDays) as NSSet)

        // 2. Assert the returned number of past days matches the added ones.
        XCTAssertEqual(
            abs(pastAmount),
            dummyChallenge.getPastDays()?.count,
            "The amount of past days returned by the challenge should be equal to the amount of added ones."
        )
    }

    func testGettingChallengeFutureDays() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 1.1 Get its future days by getting its days count and subtracting 1 (the current one).
        let futureAmount = dummyChallenge.days!.count - 1

        // 2. Assert the returned number of future days matches the expected one.
        XCTAssertEqual(
            futureAmount,
            dummyChallenge.getFutureDays()?.count,
            "The amount of future days returned by the challenge should be equal to the expected amount."
        )
    }

    func testClosingChallenge() {
        // Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // Get its total number of days.
        guard let daysNumber = dummyChallenge.days?.count else {
            XCTFail("Couldn't get the number of days from the dummy challenge entity.")
            return
        }
        // Get its number of future days.
        guard var dayNumber = dummyChallenge.getFutureDays()?.count else {
            XCTFail("Couldn't get the number of future days from the dummy challenge entity.")
            return
        }

        if dummyChallenge.getCurrentDay() != nil {
            dayNumber += 1
        }

        // Close it.
        dummyChallenge.close()

        // Assert its toDate is today (the date the user closed).
        XCTAssertEqual(
            dummyChallenge.toDate,
            Date().byAddingDays(-1)?.getBeginningOfDay(),
            "The challenge's toDate should be yesterday."
        )
        // Assert the future days were properly deleted from the challenge.
        XCTAssertEqual(
            dummyChallenge.days?.count,
            daysNumber - daysNumber,
            "The future days should be removed from the challenge."
        )
        XCTAssertTrue(dummyChallenge.isClosed)
    }

    func testMarkingLastDayAsExecutedClosesTheChallenge() {
        // 1. Declare a challenge that's about to be completed (its last day is now).
        let dates = [
            Date().byAddingDays(-1)!.getBeginningOfDay(),
            Date().getBeginningOfDay()
        ]
        let challenge = daysChallengeFactory.makeDummy(using: dates)

        // 2. Mark current day as executed.
        challenge.markCurrentDayAsExecuted()

        // 3. The challenge now should be marked as closed.
        XCTAssertTrue(
            challenge.isClosed,
            "The challenge should get closed after marking its last day as executed."
        )
    }

    func testMarkingSomeDayAsExecutedShouldNotCloseTheChallenge() {
        // 1. Declare a challenge.
        let challenge = daysChallengeFactory.makeDummy()

        // 2. Mark its current day as executed.
        challenge.markCurrentDayAsExecuted()

        // 3. The challenge shouldn't be closed.
        XCTAssertFalse(challenge.isClosed)
    }

    func testMarkingLastDayAsNotExecutedShouldOpenTheChallenge() {
        // 1. Declare a challenge that's completed, with today as its last day.
        let dates = [
            Date().byAddingDays(-1)!.getBeginningOfDay(),
            Date().getBeginningOfDay()
        ]
        let challenge = daysChallengeFactory.makeDummy(using: dates)
        challenge.isClosed = true
        challenge.getCurrentDay()?.wasExecuted = false

        // 2. Mark its last day as not executed.
        challenge.markCurrentDayAsExecuted(false)

        // 3. The challenge should not be closed anymore.
        XCTAssertFalse(challenge.isClosed)
    }

    func testGettingNotificationOrderText() {
        // 1. Declare a dummy challenge.
        let dates = (0..<5).map { Date().byAddingDays($0)!.getBeginningOfDay() }
        let dummyChallenge = daysChallengeFactory.makeDummy(using: dates)

        // 2. Get a random day.
        let sortDescriptor = NSSortDescriptor(key: "day.date", ascending: true)
        guard let days = dummyChallenge.days?.sortedArray(using: [sortDescriptor]) as? [HabitDayMO] else {
            XCTFail("Couldn't get the challenge's days.")
            return
        }

        // 3. Get the text related to it and make assertions.
        let randomIndex = Int.random(0..<days.count)
        let order = randomIndex + 1
        let text = dummyChallenge.getNotificationOrderText(for: days[randomIndex])

        XCTAssertFalse(text.isEmpty)
        guard let range = text.range(of: String(order)) else {
            XCTFail("Couldn't find the range of the order text.")
            return
        }
        XCTAssertFalse(range.isEmpty)
    }

    // MARK: Imperatives

    /// Generates habit days with its dates generated from the passed range.
    /// - Parameter range: The Int range representing the amount of days to be
    ///                    generated. The generated days's dates are the
    ///                    current date by adding the range index to its day.
    /// - Returns: An array of habit days.
    private func makeHabitDays(from range: CountableRange<Int>) -> [HabitDayMO] {
        return range.compactMap { (index: Int) -> HabitDayMO in
            let dayDate = Date().byAddingDays(index)!.getBeginningOfDay()

            let day = dayFactory.makeDummy(with: dayDate)
            let habitDay = habitDayFactory.makeDummy()
            habitDay.day = day

            return habitDay
        }
    }
}
