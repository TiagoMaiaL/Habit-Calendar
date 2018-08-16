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
        let dates = (0..<Int.random(1..<50)).compactMap {
            Date().byAddingDays($0)?.getBeginningOfDay()
        }

        // Declare the dummy and its main properties:
        let dummyChallenge = DaysChallengeMO(context: context)
        dummyChallenge.id = UUID().uuidString
        dummyChallenge.createdAt = Date()
        dummyChallenge.fromDate = dates.first!
        dummyChallenge.toDate = dates.last!

        // Associate its empty days:
        // Declare the DayFactory.
        let dayFactory = DayFactory(context: context)
        // Declare the HabitDayFactory.
        let habitDayFactory = HabitDayFactory(context: context)

        for date in dates {
            // Declare the current Day entity:
            var day: DayMO!

            // Try to fetch it from the current day date.
            let request: NSFetchRequest<DayMO> = DayMO.fetchRequest()
            let predicate = NSPredicate(format: "date >= %@ && date <= %@",
                                        date.getBeginningOfDay() as NSDate,
                                        date.getEndOfDay() as NSDate)
            request.predicate = predicate
            let results = try? context.fetch(request)

            if results?.isEmpty ?? true {
                // If none was found, create a new one with the date.
                day = dayFactory.makeDummy()
                day.date = date
            } else {
                day = results?.first!
            }

            // Generate the dummy HabitDayMO and
            // associate it with the dummy Day.

            let habitDay = habitDayFactory.makeDummy()
            habitDay.day = day

            dummyChallenge.addToDays(habitDay)
        }

        assert(
            (dummyChallenge.days?.count ?? 0) > 0,
            "The generated dummy challenge must have empty habit days associated with it."
        )

        return dummyChallenge
    }
}
