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
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
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
        
        // 3. Fetch the missed days.
        XCTAssertEqual(
            habitDays.count - executedCount,
            sequenceDummy.getMissedDays()?.count,
            "The sequence's missed days don't have the expected count."
        )
    }
    
    func testGettingSequenceProgressInfo() {
        XCTFail("Not Implemented.")
    }
}
