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
    
    // MARK: Properties
    
    /// The persistent container used by the storage.
    let container: NSPersistentContainer
    
    // MARK: - Initializers
    
    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameter container: the persistent container used by the storage.
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    // MARK: - Imperatives
    
    /// Creates and persists a calendar day instance.
    /// - Parameter date: the date associated with the day entity.
    /// - Returns: the created calendar day.
    func create(withDate date: Date) -> Day {
        let day = Day(context: container.viewContext)
        day.id = UUID().uuidString
        day.date = date
        return day
    }
    
    /// Queries for a day with the provided date.
    /// - Parameter date: the date associated with the day entity.
    /// - Returns: the day, if there's one.
    func day(for date: Date) -> Day? {
        let request: NSFetchRequest<Day> = Day.fetchRequest()
        
        // Associate the predicate to search for the specific day(begin <= date <= end).
        let predicate = NSPredicate(format: "date >= %@ && date <= %@",
                                    date.getBeginningOfDay() as NSDate,
                                    date.getEndOfDay() as NSDate)
        request.predicate = predicate
        
        // Query it.
        let results = try? container.viewContext.fetch(request)
        
        // If the results count is greater than 1, there's an error in the entity
        // creation somewhere. There should be only one day entity per date.
        assert(results?.count ?? 0 <= 1, "DayStorage -- day: there's more than on Day entity for the passed date attribute.")
        
        return results?.first
    }
    
    /// Deletes the passed day instance.
    /// - Paramater: the day to be deleted.
    func delete(day: Day) {
        container.viewContext.delete(day)
    }
    
}
