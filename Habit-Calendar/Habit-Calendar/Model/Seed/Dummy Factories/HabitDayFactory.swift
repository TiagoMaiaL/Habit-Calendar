//
//  HabitDayFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating HabitDayMO dummies.
struct HabitDayFactory: DummyFactory {

    // MARK: Types

    // This factory generates entities of the HabitDay class.
    typealias Entity = HabitDayMO

    // MARK: Properties

    var context: NSManagedObjectContext

    // MARK: Imperatives

    /// Generates a new empty HabitDay dummy.
    /// - Note: The generated dummy doesn't have the associated Habit and
    ///         Day dummies.
    /// - Returns: The generated HabitDay dummy as a NSManagedObject.
    func makeDummy() -> HabitDayMO {
        // Declare a new habitDay entity.
        let habitDay = HabitDayMO(context: context)

        // Associate it's properties (id, wasExecuted).
        habitDay.id = UUID().uuidString
        habitDay.wasExecuted = false

        // Return the created HabitDay dummy object.
        return habitDay
    }
}
