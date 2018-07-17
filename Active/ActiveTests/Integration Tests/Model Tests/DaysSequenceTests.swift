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
        XCTMarkNotImplemented()
    }
    
    func testGettingCurrentOffensiveShouldReturnNil() {
        XCTMarkNotImplemented()
    }
    
    func testMarkingCurrentDayAsExecutedShouldCreateNewOffensive() {
        XCTMarkNotImplemented()
    }
    
    func testMarkingCurrentDayAsExecutedContinuesPreviousOffensive() {
        XCTMarkNotImplemented()
    }
    
    func testBreakingPreviousOffensiveShouldCreateNewOffensive() {
        XCTMarkNotImplemented()
    }
}
