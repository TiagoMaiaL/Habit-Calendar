//
//  DaysChallengeFactory.swift
//  Active
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating DaysChallengeMO dummies.
struct DaysChallengeFactory: DummyFactory {

    // MARK: Types

    // This factory generates entities of the DaysChallengeMO class.
    typealias Entity = DaysChallengeMO

    // MARK: Properties

    var context: NSManagedObjectContext

    // MARK: Imperatives

    /// Generates a new DaysChallenge dummy.
    /// - Note: The generated dummy and its days don't have an associated Habit.
    /// - Returns: The generated DaysChallengeMO.
    func makeDummy() -> DaysChallengeMO {
        // Declare the dates used to create the challenge.
        let futureDates = (0..<Int.random(2..<15)).compactMap {
            Date().byAddingDays($0)?.getBeginningOfDay()
        }
        let futureDummy = makeDummy(using: futureDates)

        return futureDummy
    }

    /// Makes a completed days' challenge (its days are in the past and were executed).
    /// - Returns: A completed dummy days' challenge.
    func makeCompletedDummy() -> DaysChallengeMO {
        let randomNegative = Int.random(-15 ..< -2)

        // Declare the dates used to create the challenge.
        let pastDates = (randomNegative..<0).compactMap {
            Date().byAddingDays($0)?.getBeginningOfDay()
        }
        let completedDummy = makeDummy(using: pastDates)
        completedDummy.isClosed = true

        return completedDummy
    }

    /// Creates and configures a dummy challenge by using the passed dates.
    /// - Parameter dates: The days' dates.
    /// - Returns: A configured dummy challenge.
    func makeDummy(using dates: [Date]) -> DaysChallengeMO {
        assert(!dates.isEmpty, "The dates mustn't be empty.")
        let sortedDates = dates.sorted().map { $0.getBeginningOfDay() }

        // Declare the dummy and its main properties:
        let dummyChallenge = DaysChallengeMO(context: context)
        dummyChallenge.id = UUID().uuidString
        dummyChallenge.createdAt = Date()
        dummyChallenge.fromDate = sortedDates.first!
        dummyChallenge.toDate = sortedDates.last!

        // Associate its days according to the provided dates:
        // Declare the DayFactory.
        let dayFactory = DayFactory(context: context)
        // Declare the HabitDayFactory.
        let habitDayFactory = HabitDayFactory(context: context)

        for date in sortedDates {
            // Generate the dummy HabitDayMO and
            // associate it with the dummy Day.
            let habitDay = habitDayFactory.makeDummy()
            habitDay.day = dayFactory.makeDummy(with: date)
            dummyChallenge.addToDays(habitDay)
        }

        assert(
            (dummyChallenge.days?.count ?? 0) > 0,
            "The generated dummy challenge must have empty habit days associated with it."
        )

        return dummyChallenge
    }
}
