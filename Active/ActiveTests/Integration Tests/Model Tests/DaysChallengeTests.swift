//
//  DaysChallengeTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import XCTest
@testable import Active

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

    func testGettingChallengeProgressInfo() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Mark some days as executed.
        guard let daysSet = dummyChallenge.days as? Set<HabitDayMO> else {
            XCTFail("Error: Couldn't get the dummy challenge's days.")
            return
        }
        let habitDays = Array(daysSet)
        let executedCount = habitDays.count / 4

        for index in 0..<executedCount {
            habitDays[index].markAsExecuted()
        }

        // 3. Assert on the completionProgress.
        XCTAssertEqual(
            executedCount,
            dummyChallenge.getCompletionProgress().executed,
            "The challenge's executed days from the completion progrees don't have the expected count."
        )
        XCTAssertEqual(
            habitDays.count,
            dummyChallenge.getCompletionProgress().total,
            "The challenge's total days from the completion progress don't have the expected count."
        )
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

    func testGettingNotificationTextForDay() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Get one of its habit days.
        guard let daysSet = dummyChallenge.days as? Set<HabitDayMO> else {
            XCTFail("Couldn't get the habit days set from the challenge dummy.")
            return
        }
        guard let habitDay = daysSet.first else {
            XCTFail("Couldn't get the first habit day from the challenge dummy.")
            return
        }
        guard let order = dummyChallenge.getOrder(of: habitDay) else {
            XCTFail("Couldn't get the day's order.")
            return
        }

        // 3. Assert that the notification text for the passed day will return a valid text.
        let text = dummyChallenge.getNotificationText(for: habitDay)
        XCTAssertNotNil(text)
        XCTAssertNotNil(text?.range(of: String(order)))
    }

    func testGettingNotificationTextForDayShouldReturnNil() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Declare a habitDayMO not included in the challenge.
        let dummyHabitDay = habitDayFactory.makeDummy()

        // 3. Assert that the notification text for the passed day will be nil.
        XCTAssertNil(dummyChallenge.getNotificationText(for: dummyHabitDay))
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

    func testGettingEmptyChallengeCurrentOffensiveShouldReturnNil() {
        // 1. Make an empty challenge dummy.
        let emptyDummyChallenge = DaysChallengeMO(context: context)

        // 2. Assert that getting its current offensive should return nil.
        XCTAssertNil(
            emptyDummyChallenge.getCurrentOffensive(),
            "Trying to get the offensive of an empty challenge should return nil."
        )
    }

    func testGettingChallengeCurrentOffensive() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()
        // 1.1. Add some past days.
        let pastDays = makeHabitDays(from: -6 ..< 0)
        dummyChallenge.addToDays(Set(pastDays) as NSSet)

        // 1.2. Add a current offensive to it.
        let offensive = OffensiveMO(context: context)
        offensive.id = UUID().uuidString
        offensive.createdAt = Date()
        offensive.fromDate = pastDays.first?.day?.date
        offensive.toDate = pastDays.last?.day?.date

        dummyChallenge.addToOffensives(offensive)

        // 2. Assert the challenge returns the current offensive.
        XCTAssertNotNil(
            dummyChallenge.getCurrentOffensive(),
            "The challenge should return the configured current offensive."
        )
    }

    func testGettingChallengeCurrentOffensiveWhenToDateIsToday() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()
        // 1.1. Add some past days to it.
        let pastDays = makeHabitDays(from: -15 ..< 0)
        dummyChallenge.addToDays(Set(pastDays) as NSSet)

        // 1.2. Add a current offensive to it. The offensive's toDate property
        // should be the current day. This is the scenario of the user marking
        // the current day as executed.
        let offensive = OffensiveMO(context: context)
        offensive.id = UUID().uuidString
        offensive.createdAt = Date()
        offensive.fromDate = pastDays.first?.day?.date
        offensive.toDate = Date().getBeginningOfDay()

        dummyChallenge.addToOffensives(offensive)

        // 2. Assert the challenge returns the current offensive.
        XCTAssertNotNil(
            dummyChallenge.getCurrentOffensive(),
            "The challenge should return the configured offensive as its current one."
        )
    }

    func testGettingChallengeCurrentOffensiveShouldReturnNilWhenBrokenOffensivesExist() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()
        // 1.1. Add some past days.
        let pastDays = makeHabitDays(from: -12 ..< 0)
        dummyChallenge.addToDays(Set(pastDays) as NSSet)

        // 1.2. Add some broken offensives related to those past days.
        // The broken offensives have begin and end dates that are not
        // related to the last habit day or the day before the current one.
        [(from: pastDays[0], to: pastDays[2]),
         (from: pastDays[4], to: pastDays[6])].forEach {
            let currentOffensive = OffensiveMO(context: context)
            currentOffensive.id = UUID().uuidString
            currentOffensive.createdAt = Date()
            currentOffensive.fromDate = $0.from.day!.date!
            currentOffensive.toDate = $0.from.day!.date!

            dummyChallenge.addToOffensives(currentOffensive)
        }

        guard (dummyChallenge.offensives?.count ?? 0) > 0 else {
            XCTFail("Couldn't properly configure the offensives to proceed with the tests.")
            return
        }

        // 2. Getting the current offensive should return nil.
        XCTAssertNil(
            dummyChallenge.getCurrentOffensive(),
            "The challenge shouldn't return any broken offensive as its current offensive."
        )
    }

    func testMarkingCurrentDayAsExecutedShouldCreateNewOffensive() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Mark its current day as executed.
        dummyChallenge.markCurrentDayAsExecuted()

        // 3. Try getting the challenge's current offensive.
        guard let currentOffensive = dummyChallenge.getCurrentOffensive() else {
            XCTFail("The challenge should have a new offensive added to it.")
            return
        }

        XCTAssertEqual(
            currentOffensive.fromDate?.description,
            Date().getBeginningOfDay().description,
            "The created offensive should have the current date as its from date."
        )
        XCTAssertEqual(
            currentOffensive.toDate?.description,
            Date().getBeginningOfDay().description,
            "The created offensive should have the current date as its to date."
        )
    }

    func testMarkingCurrentDayAsExecutedContinuesPreviousOffensive() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 1.1. Add some past days to it.
        let pastDays = makeHabitDays(from: -20..<0)
        dummyChallenge.addToDays(Set(pastDays) as NSSet)

        // 1.2. Add a current offensive to it.
        let offensive = OffensiveMO(context: context)
        offensive.id = UUID().uuidString
        offensive.createdAt = Date()
        offensive.fromDate = pastDays.first?.day?.date
        offensive.toDate = pastDays.last?.day?.date

        dummyChallenge.addToOffensives(offensive)

        // 2. Mark it as executed.
        dummyChallenge.markCurrentDayAsExecuted()

        // 3. Assert the current offensive now has its toDate property
        // equal to the beginning of the day of the current date.
        XCTAssertEqual(
            dummyChallenge.getCurrentOffensive()?.toDate?.description,
            Date().getBeginningOfDay().description,
            "The current offensive's toDate should be equal to today."
        )
    }

    func testBreakingPreviousOffensiveShouldCreateNewOffensive() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 1.1. Add some past days to it.
        let pastDays = makeHabitDays(from: -26..<0)
        dummyChallenge.addToDays(Set(pastDays) as NSSet)

        // 1.2. Configure a broken offensive and add to it.
        let offensive = OffensiveMO(context: context)
        offensive.id = UUID().uuidString
        offensive.createdAt = Date()
        offensive.fromDate = pastDays.first?.day?.date
        offensive.toDate = pastDays[pastDays.count - 2].day?.date

        dummyChallenge.addToOffensives(offensive)

        // 2. Mark the current day as executed.
        dummyChallenge.markCurrentDayAsExecuted()

        // 3. Assert it now has a current offensive and its
        // fromDate and toDate are equal to the current date.
        XCTAssertEqual(
            dummyChallenge.getCurrentOffensive()?.fromDate?.description,
            Date().getBeginningOfDay().description,
            "The current offensive's from date should be equal to the current date."
        )
        XCTAssertEqual(
            dummyChallenge.getCurrentOffensive()?.toDate?.description,
            Date().getBeginningOfDay().description,
            "The current offensive's to date should be equal to the current date."
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
