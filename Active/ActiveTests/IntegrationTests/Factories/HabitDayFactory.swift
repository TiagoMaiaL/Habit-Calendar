//
//  HabitDayFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData
@testable import Active

/// Factory in charge of generating HabitDay (entity) dummies.
struct HabitDayFactory: DummyFactory {
    
    // MARK: Types
    
    // This factory generates entities of the HabitDay class.
    typealias Entity = HabitDayMO
    
    // MARK: Properties
    
    var container: NSPersistentContainer
    
    // MARK: Imperatives
    
    /// Generates a new HabitDay dummy with it's associated Day dummy.
    /// - Note: The generated dummy doens't have an associated Habit dummy.
    /// - Returns: The generated HabitDay dummy as a NSManagedObject.
    func makeDummy() -> HabitDayMO {
        // Declare a new habitDay entity.
        let habitDay = Active.HabitDayMO(context: container.viewContext)
        
        // Associate it's properties (id, wasExecuted).
        habitDay.id = UUID().uuidString
        habitDay.wasExecuted = false
        
        // Declare the Day factory to be used.
        let dayFactory = DayFactory(container: container)
        
        // Associate it with a Day dummy object.
        habitDay.day = dayFactory.makeDummy()

        // Return the created HabitDay dummy object.
        return habitDay
    }
}
