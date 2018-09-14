//
//  HabitDay.swift
//  Active
//
//  Created by Tiago Maia Lopes on 01/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// The HabitDay model entity.
/// - Note: A habit may have a list of days in which the goal may be accomplished.
///         A calendar day can also have as many habits as the user wants.
class HabitDayMO: NSManagedObject {

    // MARK: Imperatives

    /// Marks that the habit associated with this entity
    /// was executed or not.
    /// - Parameter executed: Bool indicating execution, defaults to true.
    func markAsExecuted(_ executed: Bool = true) {
        wasExecuted = executed
        updatedAt = Date()
    }
}
