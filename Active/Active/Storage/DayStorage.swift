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
        day.date = date
        return day
    }
    
    /// Deletes the passed day instance.
    func delete(day: Day) {
        container.viewContext.delete(day)
    }
    
}
