//
//  DaysChallengeMO.swift
//  Active
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// A challenge of n days a User has setup for an specific Habit entity to be
/// tracked and executed on.
class DaysChallengeMO: NSManagedObject {

    // MARK: Imperatives

    /// Returns the challenge's current day (associated with today's date),
    /// if there's one.
    /// - Returns: The HabitDayMO entity representing today's date.
    func getCurrentDay() -> HabitDayMO? {
        let todayPredicate = NSPredicate(
            format: "day.date >= %@ and day.date <= %@",
            Date().getBeginningOfDay() as NSDate,
            Date().getEndOfDay() as NSDate
        )
        return days?.filtered(using: todayPredicate).first as? HabitDayMO
    }

    /// Returns the HabitDay associated with the passed date, if found.
    /// - Parameter date: The date associated with the habit day.
    func getDay(for date: Date) -> HabitDayMO? {
        let beginningDate = date.getBeginningOfDay()

        // Declare the predicate to filter for the specific day.
        let dayPredicate = NSPredicate(
            format: "day.date = %@",
            beginningDate as NSDate
        )

        return days?.filtered(using: dayPredicate).first as? HabitDayMO
    }

    /// Returns the challenge's current offensive, if there's one.
    /// - Note: The current offensive isn't broken and its toDate represents the
    ///         last habitDay before the current one.
    /// - Returns: The current OffensiveMO entity or nil.
    func getCurrentOffensive() -> OffensiveMO? {
        // Get the last challenge's day.
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
        // property being the last challenge's date (in ascending order).
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

    /// Marks the current day as executed, if one exists in the challenge.
    /// - Note: Marking the current day as executed creates or updates
    ///         a related offensive entity associated with the challenge.
    ///         If there's an unbreaked offensive being tracked, its updated,
    ///         but if the previous offensive was broken, it creates a new one.
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
            // current challenge and habit.
            makeOffensive()
        }
    }

    /// Returns the executed days from the challenge.
    func getExecutedDays() -> Set<HabitDayMO>? {
        let executedPredicate = NSPredicate(format: "wasExecuted = true")
        return days?.filtered(using: executedPredicate) as? Set<HabitDayMO>
    }

    /// Returns the missed days from the challenge.
    func getMissedDays() -> Set<HabitDayMO>? {
        let missedPredicate = NSPredicate(
            format: "wasExecuted = false AND day.date < %@",
            Date().getBeginningOfDay() as NSDate
        )
        return days?.filtered(using: missedPredicate) as? Set<HabitDayMO>
    }

    /// Returns the past days from the challenge.
    func getPastDays() -> Set<HabitDayMO>? {
        let pastPredicate = NSPredicate(
            format: "day.date < %@",
            Date().getBeginningOfDay() as NSDate
        )
        return days?.filtered(using: pastPredicate) as? Set<HabitDayMO>
    }

    /// Returns the future days from the challenge.
    func getFutureDays() -> Set<HabitDayMO>? {
        let futurePredicate = NSPredicate(
            format: "day.date > %@",
            Date().getBeginningOfDay() as NSDate
        )
        return days?.filtered(using: futurePredicate) as? Set<HabitDayMO>
    }

    /// Gets the challenge's completion progress.
    /// - Returns: A tuple containing the number of executed days and
    ///            the total in the challenge.
    func getCompletionProgress() -> (executed: Int, total: Int) {
        return (getExecutedDays()?.count ?? 0, days?.count ?? 0)
    }

    /// Gets the order (related to the date) of a given habitDay entity.
    /// - Parameter day: The habitDayMO entity to get the order from.
    /// - Returns: The order as an Int, if the days is present in the challenge.
    func getOrder(of day: HabitDayMO) -> Int? {
        guard days?.contains(day) ?? false else {
            return nil
        }
        let sortedByDate = NSSortDescriptor(key: "day.date", ascending: true)
        guard let orderedDays = days?.sortedArray(using: [sortedByDate]) as? [HabitDayMO] else {
            return nil
        }

        if let index = orderedDays.index(of: day) {
            return index + 1
        } else {
            return nil
        }
    }

    /// Gets the challenge's notification text for an specific HabitDayMO entity.
    /// - Parameter day: the HabitDayMO entity to get the notification text.
    /// - Returns: The notification text including the day's order.
    func getNotificationText(for day: HabitDayMO) -> String? {
        guard let dayOrder = getOrder(of: day) else {
            return nil
        }
        var dayOrderText = String(dayOrder)

        switch dayOrder {
        case 1:
            dayOrderText += "st"
        case 2:
            dayOrderText += "nd"
        case 3:
            dayOrderText += "rd"
        default:
            dayOrderText += "th"
        }

        return "Today is your \(dayOrderText) day, did you execute this activity?"
    }

    /// Closes the challenge.
    /// - Note: Closing a challenge means that the challenge is no longer
    ///         active and its future days are deleted, its toDate is also set to today.
    func close() {
        guard let context = managedObjectContext else { return }

        // Mark challenge as closed.
        isClosed = true

        // Declare the days to be deleted.
        var daysToDelete = [HabitDayMO]()

        // Remove its future and current days.
        if let futureDays = getFutureDays() {
            daysToDelete.append(contentsOf: futureDays)
        }

        if let currentDay = getCurrentDay() {
            daysToDelete.append(currentDay)
        }

        // Remove the days.
        removeFromDays(Set(daysToDelete) as NSSet)
        habit?.removeFromDays(Set(daysToDelete) as NSSet)

        for day in daysToDelete {
            context.delete(day)
        }

        // Change its toDate to yesterday, ignore the current day.
        toDate = Date().byAddingDays(-1)?.getBeginningOfDay()
    }

    /// Creates a new offensive entity and adds it to the current
    /// challenge instance.
    private func makeOffensive() {
        if let context = managedObjectContext {
            let currentOffensive = OffensiveMO(context: context)
            currentOffensive.id = UUID().uuidString
            currentOffensive.createdAt = Date()
            currentOffensive.fromDate = Date().getBeginningOfDay()
            currentOffensive.toDate = Date().getBeginningOfDay()

            currentOffensive.habit = habit
            currentOffensive.challenge = self
        }
    }
}
