//
//  DaysChallengeStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Habit_Calendar

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
            Date().byAddingDays($0)
        }

        // 3. Create a new challenge for the habit with the generated dates.
        let createdChallenge = challengeStorage.create(using: context, daysDates: dates, and: dummyHabit)

        // 4. Make assertions on the newly created challenge:
        // 4.1. Assert on its main properties.
        XCTAssertNotNil(createdChallenge.id)
        XCTAssertNotNil(createdChallenge.createdAt)

        // The fromDate should correspond to the first day in the previously generated dates.
        XCTAssertEqual(
            createdChallenge.fromDate,
            dates.first!.getBeginningOfDay(),
            "The created challenge doesn't have the right fromDate."
        )

        // The toDate should correspond to the first day in the previously generated dates.
        XCTAssertEqual(
            createdChallenge.toDate,
            dates.last!.getBeginningOfDay(),
            "The created challenge doesn't have the right toDate."
        )

        // 4.2. Check if the challenge's habit is the expected dummy one.
        XCTAssertEqual(createdChallenge.habit, dummyHabit)

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
                dates.map { $0.getBeginningOfDay().description }.contains(
                    habitDay.day?.date?.description ?? ""
                ),
                "The challenge's day's date is not within the expected ones."
            )
        }
    }

    func testChallengeCreationWithFutureDays() {
        // 1. Declare dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Declare the future days' dates.
        let days = [
            Date().byAddingDays(5)!,
            Date().byAddingDays(9)!
        ]

        // 3. Create the challenge.
        let challenge = challengeStorage.create(using: context, daysDates: days, and: dummyHabit)

        // 4. Assert on its fromDate and toDate properties.
        XCTAssertEqual(
            challenge.fromDate,
            days.first?.getBeginningOfDay(),
            "The fromDate should match with the passed one."
        )
        XCTAssertEqual(
            challenge.toDate,
            days.last?.getBeginningOfDay(),
            "The toDate should match with the passed one."
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

    func testClosingPastChallenges() {
        // 1. Declare some past challenges that aren't closed yet.
        let pastChallenges = [
            daysChallengeFactory.makeCompletedDummy(),
            daysChallengeFactory.makeCompletedDummy(),
            daysChallengeFactory.makeCompletedDummy()
        ]
        pastChallenges.forEach { $0.isClosed = false }

        // 2. Use the storage to close all past challenges.
        challengeStorage.closePastChallenges(using: context)

        // 3. Check if the challenges are closed.
        XCTAssertTrue(
            pastChallenges.filter { !$0.isClosed }.isEmpty,
            "All challenges should be marked as closed."
        )
    }

}
