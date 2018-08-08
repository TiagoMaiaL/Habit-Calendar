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

    // MARK: Life cycle

    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)

        // TODO: Change fromDate property.
        print("Changing \(key) ------ DaysSequenceMO")
    }

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

    /// Returns the sequence's current offensive, if there's one.
    /// - Note: The current offensive isn't broken and its toDate represents the
    ///         last habitDay before the current one.
    /// - Returns: The current OffensiveMO entity or nil.
    func getCurrentOffensive() -> OffensiveMO? {
        // Get the last sequence's day.
        let pastDays = (days?.sortedArray(
            using: [NSSortDescriptor(key: "day.date", ascending: true)]
        ) as? [HabitDayMO])?.filter {
            $0.day?.date?.getEndOfDay().isPast ?? false
        }
        let lastDay = pastDays?.last

        if lastDay != nil {
            assert(
                lastDay!.day != nil && lastDay!.day!.date != nil,
                "Inconsistency: The habitDay must have a valid day."
            )
        }

        // Get the last offensive by filtering for the one with the toDate
        // property being the last sequence's date (in ascending order).
        var toDatePredicate: NSPredicate!

        if let lastDay = lastDay {
            toDatePredicate = NSPredicate(
                format: "toDate = %@ OR toDate = %@",
                lastDay.day!.date! as NSDate,
                Date().getBeginningOfDay() as NSDate
            )
        } else {
            toDatePredicate = NSPredicate(
                format: "toDate = %@",
                Date().getBeginningOfDay() as NSDate
            )
        }

        return offensives?.filtered(using: toDatePredicate).first as? OffensiveMO
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

        // Try fetching the current offensive. If we can get it,
        // update it.
        if let currentOffensive = getCurrentOffensive() {
            currentOffensive.toDate = Date().getBeginningOfDay()
            currentOffensive.updatedAt = Date()
        } else {
            // If there isn't a current offensive, add a new one to the
            // current sequence and habit.
            makeOffensive()
        }
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

    /// Returns the past days from the sequence.
    func getPastDays() -> Set<HabitDayMO>? {
        let pastPredicate = NSPredicate(
            format: "day.date < %@",
            Date().getBeginningOfDay() as NSDate
        )
        return days?.filtered(using: pastPredicate) as? Set<HabitDayMO>
    }

    /// Returns the future days from the sequence.
    func getFutureDays() -> Set<HabitDayMO>? {
        let futurePredicate = NSPredicate(
            format: "day.date > %@",
            Date().getBeginningOfDay() as NSDate
        )
        return days?.filtered(using: futurePredicate) as? Set<HabitDayMO>
    }

    /// Returns the sequence's completion progress.
    /// - Returns: A tuple containing the number of executed days and
    ///            the total in the sequence.
    func getCompletionProgress() -> (executed: Int, total: Int) {
        return (getExecutedDays()?.count ?? 0, days?.count ?? 0)
    }

    /// Creates a new offensive entity and adds it to the current
    /// sequence instance.
    private func makeOffensive() {
        if let context = managedObjectContext {
            let currentOffensive = OffensiveMO(context: context)
            currentOffensive.id = UUID().uuidString
            currentOffensive.createdAt = Date()
            currentOffensive.fromDate = Date().getBeginningOfDay()
            currentOffensive.toDate = Date().getBeginningOfDay()

            currentOffensive.habit = habit
            currentOffensive.daysSequence = self
        }
    }
}
