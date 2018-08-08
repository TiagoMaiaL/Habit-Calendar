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
        sequenceStorage = DaysSequenceStorage(
            habitDayStorage: HabitDayStorage(
                calendarDayStorage: DayStorage()
            )
        )
    }

    override func tearDown() {
        // Remove the initialized storage class.
        sequenceStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testSequenceCreationWithTheProvidedDaysDates() {
        // 1. Declare a dummy habit. It'll be used to create the sequence.
        let dummyHabit = habitFactory.makeDummy()
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
            Date().byAddingDays($0)?.getBeginningOfDay()
        }

        // 3. Create a new sequence for the habit with the generated dates.
        let createdSequence = sequenceStorage.create(
            using: context,
            daysDates: dates,
            and: dummyHabit
        )

        // 4. Make assertions on the newly created sequence:
        // 4.1. Assert on its main properties.
        XCTAssertNotNil(
            createdSequence.id,
            "The created sequence doesn't have an id."
        )
        XCTAssertNotNil(
            createdSequence.createdAt,
            "The created sequence doesn't have a createdAt property."
        )

        // The fromDate should correspond to the first day
        // in the previously generated dates.
        XCTAssertEqual(
            createdSequence.fromDate,
            dates.first!,
            "The created sequence doesn't have the right fromDate."
        )

        // The toDate should correspond to the first day
        // in the previously generated dates.
        XCTAssertEqual(
            createdSequence.toDate,
            dates.last!,
            "The created sequence doesn't have the right toDate."
        )

        // 4.2. Check if the sequence's habit is the
        // expected dummy one.
        XCTAssertEqual(
            createdSequence.habit,
            dummyHabit,
            "The created sequence should have the correct habit (the dummy one) associated with it."
        )

        // 4.3. Check the amount of days.
        XCTAssertEqual(
            createdSequence.days?.count,
            dates.count,
            "The created days sequence has the wrong amount of dates."
        )
        // 4.4. Check if the sequence's days dates are within the passed ones.
        guard let createdHabitDays = createdSequence.days as? Set<HabitDayMO> else {
            XCTFail("The created days sequence doesn't have the correct day entities.")
            return
        }
        // 4.4.1. For each generated habit day, check if the entity has a date
        // within the specified ones.
        for habitDay in createdHabitDays {
            XCTAssertTrue(
                dates.map { $0.description }.contains(
                    habitDay.day?.date?.getBeginningOfDay().description ?? ""
                ),
                "The sequence's day's date is not within the expected ones."
            )
        }

        // 4.5. Assert the sequence comes clean of offensives.
        XCTAssertTrue(
            (createdSequence.offensives?.count ?? 0) == 0,
            "The created sequence shouldn't have any offensives, it should be clean."
        )
    }

    func testSequenceDeletion() {
        // 1. Declare a dummy sequence.
        let dummySequence = daysSequenceFactory.makeDummy()

        // 2. Delete it using the storage.
        sequenceStorage.delete(dummySequence, from: context)

        // 3. Assert it was deleted.
        XCTAssertTrue(
            dummySequence.isDeleted,
            "The dummy sequence should be marked as deleted."
        )
    }

}
