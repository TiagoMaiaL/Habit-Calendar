//
//  DaysSequenceFactory.swift
//  Active
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating DaysSequenceMO dummies.
struct DaysSequenceFactory: DummyFactory {

    // MARK: Types

    // This factory generates entities of the DaysSequenceMO class.
    typealias Entity = DaysChallengeMO

    // MARK: Properties

    var context: NSManagedObjectContext

    // MARK: Imperatives

    /// Generates a new DaysSequence dummy.
    /// - Note: The generated dummy and its days don't have the an associated
    ///         Habit.
    /// - Returns: The generated DaysSequenceMO dummy as a NSManagedObject.
    func makeDummy() -> DaysChallengeMO {
        // Declare the dates used to create the sequence.
        let dates = (0..<Int.random(1..<50)).compactMap {
            Date().byAddingDays($0)?.getBeginningOfDay()
        }

        // Declare the dummy and its main properties:
        let dummySequence = DaysChallengeMO(context: context)
        dummySequence.id = UUID().uuidString
        dummySequence.createdAt = Date()
        dummySequence.fromDate = dates.first!
        dummySequence.toDate = dates.last!

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

            dummySequence.addToDays(habitDay)
        }

        assert(
            (dummySequence.days?.count ?? 0) > 0,
            "The generated dummy sequence must have empty habit days associated with it."
        )

        return dummySequence
    }
}
