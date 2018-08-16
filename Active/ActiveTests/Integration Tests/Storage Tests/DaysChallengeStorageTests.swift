//
//  DaysChallengeStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Active

/// Class in charge of testing the DaysChallengeStorage methods.
class DaysChallengeStorageTests: IntegrationTestCase {

    // MARK: Properties

    var challengeStorage: DaysChallengeStorage!

    // MARK: Setup/TearDown

    override func setUp() {
        super.setUp()

        // Initialize a new DaysChallengeStorage instance.
        challengeStorage = DaysChallengeStorage(
            habitDayStorage: HabitDayStorage(
                calendarDayStorage: DayStorage()
            )
        )
    }

    override func tearDown() {
        // Remove the initialized storage class.
        challengeStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testChallengeCreationWithTheProvidedDaysDates() {
        // 1. Declare a dummy habit. It'll be used to create the challenge.
        let dummyHabit = habitFactory.makeDummy()
        // 1.1 Clear its days and challenges.
        if let habitDays = dummyHabit.days as? Set<HabitDayMO> {
            for habitDay in habitDays {
                dummyHabit.removeFromDays(habitDay)
                context.delete(habitDay)
            }
        }
        if let challenges = dummyHabit.challenges as? Set<DaysChallengeMO> {
            for challenge in challenges {
                dummyHabit.removeFromChallenges(challenge)
                context.delete(challenge)
            }
        }

        // 2. Declare the days dates. They are generated until a random amount.
        let dates = (0..<Int.random(2..<50)).compactMap {
            Date().byAddingDays($0)?.getBeginningOfDay()
        }

        // 3. Create a new challenge for the habit with the generated dates.
        let createdChallenge = challengeStorage.create(
            using: context,
            daysDates: dates,
            and: dummyHabit
        )

        // 4. Make assertions on the newly created challenge:
        // 4.1. Assert on its main properties.
        XCTAssertNotNil(
            createdChallenge.id,
            "The created challenge doesn't have an id."
        )
        XCTAssertNotNil(
            createdChallenge.createdAt,
            "The created challenge doesn't have a createdAt property."
        )

        // The fromDate should correspond to the first day in the previously generated dates.
        XCTAssertEqual(
            createdChallenge.fromDate,
            dates.first!,
            "The created challenge doesn't have the right fromDate."
        )

        // The toDate should correspond to the first day in the previously generated dates.
        XCTAssertEqual(
            createdChallenge.toDate,
            dates.last!,
            "The created challenge doesn't have the right toDate."
        )

        // 4.2. Check if the challenge's habit is the expected dummy one.
        XCTAssertEqual(
            createdChallenge.habit,
            dummyHabit,
            "The created challenge should have the correct habit (the dummy one) associated with it."
        )

        // 4.3. Check the amount of days.
        XCTAssertEqual(
            createdChallenge.days?.count,
            dates.count,
            "The created days' challenge has the wrong amount of dates."
        )
        // 4.4. Check if the challenge's days dates are within the passed ones.
        guard let createdHabitDays = createdChallenge.days as? Set<HabitDayMO> else {
            XCTFail("The created days' challenge doesn't have the correct day entities.")
            return
        }
        // 4.4.1. For each generated habit day, check if the entity has a date within the specified ones.
        for habitDay in createdHabitDays {
            XCTAssertTrue(
                dates.map { $0.description }.contains(
                    habitDay.day?.date?.getBeginningOfDay().description ?? ""
                ),
                "The challenge's day's date is not within the expected ones."
            )
        }

        // 4.5. Assert the challenge comes clean of offensives.
        XCTAssertTrue(
            (createdChallenge.offensives?.count ?? 0) == 0,
            "The created challenge shouldn't have any offensives, it should be clean."
        )
    }

    func testChallengeDeletion() {
        // 1. Declare a dummy challenge.
        let dummyChallenge = daysChallengeFactory.makeDummy()

        // 2. Delete it using the storage.
        challengeStorage.delete(dummyChallenge, from: context)

        // 3. Assert it was deleted.
        XCTAssertTrue(
            dummyChallenge.isDeleted,
            "The dummy challenge should be marked as deleted."
        )
    }

}
