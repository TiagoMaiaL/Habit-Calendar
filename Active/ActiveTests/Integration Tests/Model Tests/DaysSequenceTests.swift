//
//  DaysSequenceTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import XCTest
@testable import Active

/// Class in charge of testing the DaysSequencesMO methods.
class DaysSequenceTests: IntegrationTestCase {
    
    // MARK: Tests
    
    func testGettingSequenceExecutedDays() {
        // 1. Declare a dummy sequence.
        let sequenceDummy = factories.daysSequence.makeDummy()
        
        // 2. Mark some days as executed.
        let habitDays = Array(sequenceDummy.days as! Set<HabitDayMO>)
        let executedCount = habitDays.count / 2
        
        for i in 0..<executedCount {
            habitDays[i].markAsExecuted()
        }
        
        // 3. Make assertions on it:
        // Assert on the executed days count.
        XCTAssertEqual(
            executedCount,
            sequenceDummy.getExecutedDays()?.count,
            "The sequence's executed days don't have the expected count."
        )
    }
    
    func testGettingSequenceMissedDays() {
        // 1. Declare a dummy sequence.
        let sequenceDummy = factories.daysSequence.makeDummy()
        
        // 2. Mark some days as executed.
        let habitDays = Array(sequenceDummy.days as! Set<HabitDayMO>)
        let executedCount = habitDays.count / 3
        
        for i in 0..<executedCount {
            habitDays[i].markAsExecuted()
        }
        
        // 3. Assert on the missed days.
        XCTAssertEqual(
            habitDays.count - executedCount,
            sequenceDummy.getMissedDays()?.count,
            "The sequence's missed days don't have the expected count."
        )
    }
    
    func testGettingSequenceProgressInfo() {
        // 1. Declare a dummy sequence.
        let sequenceDummy = factories.daysSequence.makeDummy()
        
        // 2. Mark some days as executed.
        let habitDays = Array(sequenceDummy.days as! Set<HabitDayMO>)
        let executedCount = habitDays.count / 4
        
        for i in 0..<executedCount {
            habitDays[i].markAsExecuted()
        }
        
        // 3. Assert on the completionProgress.
        XCTAssertEqual(
            executedCount,
            sequenceDummy.getCompletionProgress().executed,
            "The sequence's executed days from the completion progrees don't have the expected count."
        )
        XCTAssertEqual(
            habitDays.count,
            sequenceDummy.getCompletionProgress().total,
            "The sequence's total days from the completion progress don't have the expected count."
        )
    }
    
    func testGettingTheCurrentDay() {
        // 1. Create a new dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        
        // 2. Get its current day and make assertions on its dates.
        guard let currentDay = dummySequence.getCurrentDay() else {
            XCTFail("Couldn't get the sequence's current day.")
            return
        }
        
        XCTAssertEqual(
            Date().getBeginningOfDay().description,
            currentDay.day!.date!.description,
            "The sequence's current day doesn't have the expected date."
        )
    }
    
    func testGettingEmptySequenceCurrentDayShouldBeNil() {
        // 1. Create an empty dummy sequence.
        let emptyDummySequence = DaysSequenceMO(
            context: context
        )
        
        // 2. Assert its current day is nil.
        XCTAssertNil(
            emptyDummySequence.getCurrentDay(),
            "The empty sequence shouldn't return the current day."
        )
    }
    
    func testGettingSequenceCurrentDayShouldBeNil() {
        // 1. Create a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        // 1.1. Clear it by removing its current day.
        guard let currentDay = dummySequence.getCurrentDay() else {
            XCTFail("Couldn't get the sequence's current day.")
            return
        }
        dummySequence.removeFromDays(currentDay)
        context.delete(currentDay)
        
        // 2. Assert its current day now is nil.
        XCTAssertNil(
            dummySequence.getCurrentDay(),
            "The sequence shouldn't return its current day."
        )
    }
    
    func testMarkingCurrentDayAsExecuted() {
        // 1. Create a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        
        // 2. Mark its current day as executed.
        dummySequence.markCurrentDayAsExecuted()
        
        // 3. Fetch the current day and assert it was
        // marked as executed.
        guard let currentDay = dummySequence.getCurrentDay() else {
            XCTFail("Couldn't retrieve the sequence's current day.")
            return
        }
        
        XCTAssertTrue(
            currentDay.wasExecuted,
            "The current day wasn't marked as executed."
        )
    }
    
    func testGettingEmptySequenceCurrentOffensiveShouldReturnNil() {
        // 1. Make an empty sequence dummy.
        let emptyDummySequence = DaysSequenceMO(context: context)
        
        // 2. Assert that getting its current offensive should return nil.
        XCTAssertNil(
            emptyDummySequence.getCurrentOffensive(),
            "Trying to get the offensive of an empty sequence should return nil."
        )
    }
    
    func testGettingSequenceCurrentOffensive() {
        // 1. Declare a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        // 1.1. Add some past days.
        let pastDays = makeHabitDays(from: -6 ..< 0)
        dummySequence.addToDays(Set(pastDays) as NSSet)
        
        // 1.2. Add a current offensive to it.
        let offensive = OffensiveMO(context: context)
        offensive.id = UUID().uuidString
        offensive.createdAt = Date()
        offensive.fromDate = pastDays.first?.day?.date
        offensive.toDate = pastDays.last?.day?.date
        
        dummySequence.addToOffensives(offensive)
        
        // 2. Assert the sequence returns the current sequence.
        XCTAssertNotNil(
            dummySequence.getCurrentOffensive(),
            "The sequence should return the configured current offensive."
        )
    }
    
    func testGettingSequenceCurrentOffensiveWhenToDateIsToday() {
        // 1. Declare a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        // 1.1. Add some past days to it.
        let pastDays = makeHabitDays(from: -15 ..< 0)
        dummySequence.addToDays(Set(pastDays) as NSSet)
        
        // 1.2. Add a current offensive to it. The offensive's toDate property
        // should be the current day. This is the scenario of the user marking
        // the current day as executed.
        let offensive = OffensiveMO(context: context)
        offensive.id = UUID().uuidString
        offensive.createdAt = Date()
        offensive.fromDate = pastDays.first?.day?.date
        offensive.toDate = Date().getBeginningOfDay()
        
        dummySequence.addToOffensives(offensive)
        
        // 2. Assert the sequence returns the current sequence.
        XCTAssertNotNil(
            dummySequence.getCurrentOffensive(),
            "The sequence should return the configured offensive as its current one."
        )
    }
    
    func testGettingSequenceCurrentOffensiveShouldReturnNilWhenBrokenOffensivesExist() {
        // 1. Declare a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        // 1.1. Add some past days.
        let pastDays = makeHabitDays(from: -12 ..< 0)
        dummySequence.addToDays(Set(pastDays) as NSSet)
        
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
            
            dummySequence.addToOffensives(currentOffensive)
        }
        
        guard (dummySequence.offensives?.count ?? 0) > 0 else {
            XCTFail("Couldn't properly configure the offensives to proceed with the tests.")
            return
        }
        
        // 2. Getting the current offensive should return nil.
        XCTAssertNil(
            dummySequence.getCurrentOffensive(),
            "The sequence shouldn't return any broken sequence as its current offensive."
        )
    }
    
    func testMarkingCurrentDayAsExecutedShouldCreateNewOffensive() {
        // 1. Declare a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        
        // 2. Mark its current day as executed.
        dummySequence.markCurrentDayAsExecuted()
        
        // 3. Try getting the sequence's current offensive.
        guard let currentOffensive = dummySequence.getCurrentOffensive() else {
            XCTFail("The sequence should have a new offensive added to it.")
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
        // 1. Declare a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        
        // 1.1. Add some past days to it.
        let pastDays = makeHabitDays(from: -20..<0)
        dummySequence.addToDays(Set(pastDays) as NSSet)
        
        // 1.2. Add a current offensive to it.
        let offensive = OffensiveMO(context: context)
        offensive.id = UUID().uuidString
        offensive.createdAt = Date()
        offensive.fromDate = pastDays.first?.day?.date
        offensive.toDate = pastDays.last?.day?.date
        
        dummySequence.addToOffensives(offensive)
        
        // 2. Mark it as executed.
        dummySequence.markCurrentDayAsExecuted()
        
        // 3. Assert the current offensive now has its toDate property
        // equal to the beginning of the day of the current date.
        XCTAssertEqual(
            dummySequence.getCurrentOffensive()?.toDate?.description,
            Date().getBeginningOfDay().description,
            "The current offensive's toDate should be equal to today."
        )
    }
    
    func testBreakingPreviousOffensiveShouldCreateNewOffensive() {
        // 1. Declare a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()

        // 1.1. Add some past days to it.
        let pastDays = makeHabitDays(from: -26..<0)
        dummySequence.addToDays(Set(pastDays) as NSSet)
        
        // 1.2. Configure a broken offensive and add to it.
        let offensive = OffensiveMO(context: context)
        offensive.id = UUID().uuidString
        offensive.createdAt = Date()
        offensive.fromDate = pastDays.first?.day?.date
        offensive.toDate = pastDays[pastDays.count - 2].day?.date
        
        dummySequence.addToOffensives(offensive)
        
        // 2. Mark the current day as executed.
        dummySequence.markCurrentDayAsExecuted()
        
        // 3. Assert it now has a current offensive and its
        // fromDate and toDate are equal to the current date.
        XCTAssertEqual(
            dummySequence.getCurrentOffensive()?.fromDate?.description,
            Date().getBeginningOfDay().description,
            "The current offensive's from date should be equals to the current date."
        )
        XCTAssertEqual(
            dummySequence.getCurrentOffensive()?.toDate?.description,
            Date().getBeginningOfDay().description,
            "The current offensive's to date should be equals to the current date."
        )
    }
    
    func testGettingSequencePastDays() {
        // 1. Declare a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        
        // 1.1 Add some past days to it.
        let pastAmount = -25
        let pastDays = makeHabitDays(from: pastAmount..<0)
        dummySequence.addToDays(Set(pastDays) as NSSet)
        
        // 2. Assert the returned number of past days matches the added ones.
        XCTAssertEqual(
            abs(pastAmount),
            dummySequence.getPastDays()?.count,
            "The amount of past days returned by the sequence should be equal to the amount of added ones."
        )
    }
    
    func testGettingSequenceFutureDays() {
        // 1. Declare a dummy sequence.
        let dummySequence = factories.daysSequence.makeDummy()
        
        // 1.1 Get its future days by getting its days count and
        // subtracting 1 (the current one).
        let futureAmount = dummySequence.days!.count - 1
        
        // 2. Assert the returned number of future days matches the
        // expected one.
        XCTAssertEqual(
            futureAmount,
            dummySequence.getFutureDays()?.count,
            "The amount of future days returned by the sequence should be equal to the expected amount."
        )
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
            
            let day = factories.day.makeDummy()
            day.date = dayDate
            
            let habitDay = factories.habitDay.makeDummy()
            habitDay.day = day
            
            return habitDay
        }
    }
}
