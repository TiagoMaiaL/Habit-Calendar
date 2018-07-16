//
//  DaysSequenceStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Active

/// Class in charge of testing the DaysSequenceStorage methods.
class DaysSequenceStorageTests: IntegrationTestCase {
    
    // MARK: Properties
    
    var sequenceStorage: DaysSequenceStorage!
    
    // MARK: Setup/TearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize a new DaysSequenceStorage instance.
        sequenceStorage = DaysSequenceStorage()
    }
    
    override func tearDown() {
        // Remove the initialized storage class.
        sequenceStorage = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    // What are we going to test?
    // The creation, by using the provided days.
    // The edition by appending to an existing sequence.
    // The deletion.
    
    func testSequenceCreationWithTheProvidedDaysDates() {
        // 1. Declare a dummy habit. It'll be used to create the sequence.
        let dummyHabit = factories.habit.makeDummy()
        // 1.1 Clear its days and sequences.
        if let habitDays = dummyHabit.days as? Set<HabitDayMO> {
            for habitDay in habitDays {
                dummyHabit.removeFromDays(habitDay)
                context.delete(habitDay)
            }
        }
        if let sequences = dummyHabit.daysSequences as? Set<DaysSequenceMO> {
            for sequence in sequences {
                dummyHabit.removeFromDaysSequences(sequence)
                context.delete(sequence)
            }
        }
        
        // 2. Declare the days dates. They are generated until a random amount.
        let dates = (0..<Int.random(2..<50)).compactMap {
            Date().byAddingDays($0)
        }
        
        // 3. Create a new sequence for the habit with the generated dates.
        let createdSequence = sequenceStorage.create(
            using: context,
            daysDates: dates,
            and: dummyHabit
        )
        
        // 4. Make assertions on the newly created sequence:
        // 4.1. Check if the sequence's habit is the
        // expected dummy one.
        XCTAssertEqual(
            createdSequence.habit,
            dummyHabit,
            "The created sequence should have the correct habit (the dummy one) associated with it."
        )
        
        // 4.2. Check the amount of days.
        XCTAssertEqual(
            createdSequence.days?.count,
            dates.count,
            "The created days sequence has the wrong amount of dates."
        )
        // 4.3. Check if the sequence's days dates are within the passed ones.
        guard let createdHabitDays = createdSequence.days as? Set<HabitDayMO> else {
            XCTFail("The created days sequence doesn't have the correct day entities.")
            return
        }
        // 4.3.1. For each generated habit day, check if the entity has a date
        // within the specified ones.
        for habitDay in createdHabitDays {
            XCTAssertTrue(
                dates.map { $0.description }.contains(
                    habitDay.day?.date?.description ?? ""
                ),
                "The sequence's day's date is not within the expected ones."
            )
        }
    }
    
    func testSequenceEditionByPassingNewDaysDates() {
        XCTFail("Not Implemented.")
    }
    
    func testInvalidEditionOfPastSequence() {
        XCTFail("Not Implemented.")
    }
    
    func testSequenceDeletion() {
        XCTFail("Not Implemented.")
    }
    
}
