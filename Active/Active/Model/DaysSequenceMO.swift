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
    
    /// Returns the sequence's current day (associated with today's date),
    /// if there's one.
    /// - Returns: The habit day entity representing today's date.
    func getCurrentDay() -> HabitDayMO? {
        let todayPredicate = NSPredicate(
            format: "day.date >= %@ and day.date <= %@",
            Date().getBeginningOfDay() as NSDate,
            Date().getEndOfDay() as NSDate
        )
        return days?.filtered(using: todayPredicate).first as? HabitDayMO
    }
    
    /// Marks the current day as executed, if one exists in the sequence.
    /// - Note: Marking the current day as executed creates or updates
    ///         a related offensive entity associated with the sequence.
    ///         If there's an unbreaked offensive being tracked, its updated,
    ///         but if the previous sequence was broken, it creates a new one.
    func markCurrentDayAsExecuted() {
        guard let currentDay = getCurrentDay() else {
            return
        }
        
        // Mark the current day as executed.
        currentDay.markAsExecuted()

        // TODO:
        // Try fetching the current offensive. If we can get it,
        // update it.
        // TODO:
        // If there isn't a current offensive, add a new one to the
        // current sequence and habit.
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
