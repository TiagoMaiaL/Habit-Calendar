//
//  DaysSequenceMO.swift
//  Active
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// A sequence of n days a User has setup for an specific Habit entity to be
/// tracked and executed on.
class DaysSequenceMO: NSManagedObject {
    
    // MARK: Imperatives
    
    /// Returns the sequence's current day (associated with today's date).
    /// - Returns: The habit day entity representing today's date.
    func getCurrentDay() -> HabitDayMO? {
        let todayPredicate = NSPredicate(
            format: "day.date >= %@ and day.date <= %@",
            Date().getBeginningOfDay() as NSDate,
            Date().getEndOfDay() as NSDate
        )
        return days?.filtered(using: todayPredicate).first as? HabitDayMO
    }
    
    /// Returns the executed days from the sequence.
    func getExecutedDays() -> Set<HabitDayMO>? {
        let executedPredicate = NSPredicate(format: "wasExecuted = true")
        return days?.filtered(using: executedPredicate) as? Set<HabitDayMO>
    }
    
    /// Returns the missed days from the sequence.
    func getMissedDays() -> Set<HabitDayMO>? {
        let executedPredicate = NSPredicate(format: "wasExecuted = false")
        return days?.filtered(using: executedPredicate) as? Set<HabitDayMO>
    }
    
    /// Returns the sequence's completion progress.
    /// - Returns: A tuple containing the number of executed days and
    ///            the total in the sequence.
    func getCompletionProgress() -> (executed: Int, total: Int) {
        return (getExecutedDays()?.count ?? 0, days?.count ?? 0)
    }
}
