//
//  DayDummyFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating DayMO dummies.
struct DayFactory: DummyFactory {

    // MARK: Types

    // This factory generates entities of the Day class.
    typealias Entity = DayMO

    // MARK: Properties

    var context: NSManagedObjectContext

    // MARK: Imperatives

    /// Makes a day entity with the current day as it's date.
    /// - Returns: A new day entity.
    func makeDummy() -> DayMO {
        // If there's already a day created with the passed date, only return it.
        if let alreadyCreatedDay = getDay(from: Date().getBeginningOfDay()) {
            return alreadyCreatedDay
        }

        // Declare a new Day entity.
        let day = DayMO(context: context)

        // Configure it's properties (id, date).
        day.id = UUID().uuidString
        day.date = Date().getBeginningOfDay()

        return day
    }

    /// Makes a day entity with the passed date.
    /// - Parameter date: the day's Date.
    /// - Returns: A new day entity.
    func makeDummy(with date: Date) -> DayMO {
        // If there's already a day created with the passed date, only return it.
        if let alreadyCreatedDay = getDay(from: date) {
            return alreadyCreatedDay
        }

        // Declare a new Day entity.
        let day = DayMO(context: context)
        day.id = UUID().uuidString

        // Configure it's date.
        day.date = date.getBeginningOfDay()

        return day
    }

    /// Tries to get the day entity with the passed date.
    /// - Parameter date: the day's date.
    /// - Returns: the days corresponding to the date, if there's one.
    private func getDay(from date: Date) -> DayMO? {
        // Try to fetch it from the current day date.
        let request: NSFetchRequest<DayMO> = DayMO.fetchRequest()
        let predicate = NSPredicate(format: "date >= %@ && date <= %@",
                                    date.getBeginningOfDay() as NSDate,
                                    date.getEndOfDay() as NSDate)
        request.predicate = predicate
        let results = try? context.fetch(request)
        return results?.first
    }
}
