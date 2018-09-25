//
//  DayStorage.swift
//  Active
//
//  Created by Tiago Maia Lopes on 07/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Class in charge of storing calendar Day entities.
class DayStorage {

    // MARK: Types

    enum DayStorageError: Error {
        case dayAlreadyCreated
    }

    // MARK: - Imperatives

    /// Creates and persists a calendar day instance.
    /// - Parameter context: the context used to write the entity to.
    /// - Parameter date: the date associated with the day entity.
    /// - Note: The new entity's date is always at the beginning
    //          of the day specified in the required date.
    /// - Throws: An error when a Day with the same date already exists.
    /// - Returns: the created calendar day.
    func create(using context: NSManagedObjectContext, and date: Date) throws -> DayMO {
        // Check if an entity with the same date already exists.
        // If so, throw an error.
        if self.day(using: context, and: date) != nil {
            throw DayStorageError.dayAlreadyCreated
        }

        let day = DayMO(context: context)
        day.id = UUID().uuidString
        day.date = date.getBeginningOfDay()
        return day
    }

    /// Queries for a day with the provided date.
    /// - Parameter context: the context used to fetch the day from.
    /// - Parameter date: the date associated with the day entity.
    /// - Returns: the day, if there's one.
    func day(using context: NSManagedObjectContext, and date: Date) -> DayMO? {
        let request: NSFetchRequest<DayMO> = DayMO.fetchRequest()

        // Associate the predicate to search for the specific day(begin <= date <= end).
        let predicate = NSPredicate(format: "date >= %@ && date <= %@",
                                    date.getBeginningOfDay() as NSDate,
                                    date.getEndOfDay() as NSDate)
        request.predicate = predicate

        // Query it.
        let results = try? context.fetch(request)

        // If the results count is greater than 1, there's an error in the entity
        // creation somewhere. There should be only one day entity per date.
        assert(
            results?.count ?? 0 <= 1,
            "DayStorage -- day: there's more than on Day entity for the passed date attribute."
        )

        return results?.first
    }

    /// Deletes the passed day instance.
    /// - Parameter context: The context used to delete the entity from.
    /// - Paramater: the day to be deleted.
    func delete(_ day: DayMO, from context: NSManagedObjectContext) {
        context.delete(day)
    }

}
