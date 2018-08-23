//
//  Habit.swift
//  Active
//
//  Created by Tiago Maia Lopes on 01/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// The Habit model entity.
/// - Note: The user can have as many habits as he/she wants.
class HabitMO: NSManagedObject {

    // MARK: Types

    /// Enum representing all possible Habit colors.
    enum Color: Int16 {
        case midnightBlue = 0,
            amethyst,
            pomegranate,
            alizarin,
            carrot,
            orange,
            blue,
            peterRiver,
            belizeRole,
            turquoise,
            emerald

        /// The total amount of listed colors.
        static let count = 11
    }

    // MARK: Properties

    /// The count of days in which the habit was marked
    /// as executed.
    var executedCount: Int {
        let predicate = NSPredicate(
            format: "wasExecuted == true"
        )
        return days?.filtered(using: predicate).count ?? 0
    }

    /// The percentage of executed days out of all days.
    var executionPercentage: Double {
        if let daysCount = days?.count,
            daysCount > 0 {
            return Double(executedCount) / Double(daysCount) * 100
        }
        return 0
    }

    // MARK: Imperatives

    /// Gets the habit title text.
    /// - Note: The habit title text may be used for user notifications
    ///         and to display the habit's info in the list or graphics.
    /// - Returns: The habit's title string.
    func getTitleText() -> String {
        assert(name != nil, "Habit's name must have a value.")
        return name!
    }

    /// Gets the habit subtitle text.
    /// - Note: The habit subtitle text may be used for user
    ///         notifications and to display the habit's info.
    /// - Returns: The habit's subtitle string.
    func getSubtitleText() -> String {
        // TODO: Make this localized.
        return "Have you practiced this activity?"
    }

    /// Gets the habit description text.
    /// - Note: The habit description text is used for user
    ///         notifications.
    /// - Returns: The habit's description string.
    func getDescriptionText() -> String {
        return ""
    }

    /// Gets the fire times description text.
    /// - Returns: The fire times description text to be display to the user, if there are fire times.
    func getFireTimesText() -> String? {
        guard let fireTimes = fireTimes as? Set<FireTimeMO>, !fireTimes.isEmpty else {
            return nil
        }

        let fireTimeFormatter = DateFormatter.makeFireTimeDateFormatter()
        let fireDates = fireTimes.compactMap {
            Calendar.current.date(
                from: DateComponents(hour: Int($0.hour), minute: Int($0.minute))
            )
        }.sorted()
        var fireTimesText = ""

        for fireDate in fireDates {
            fireTimesText += fireTimeFormatter.string(from: fireDate)

            // If the current fire time isn't the last one,
            // include a colon to separate it from the next.
            if fireDates.index(of: fireDate)! != fireDates.endIndex - 1 {
                fireTimesText += ", "
            }
        }

        return fireTimesText
    }

    /// Returns the current habit day for today (the current date),
    /// if there's one being tracked.
    func getCurrentDay() -> HabitDayMO? {
        // Get the current date.
        let today = Date()

        // Declare the predicate to search only for the current day.
        let predicate = NSPredicate(
            format: "day.date >= %@ and day.date <= %@",
            today.getBeginningOfDay() as NSDate,
            today.getEndOfDay() as NSDate
        )

        // Fetch it and return the first result, if there's one.
        return days?.filtered(using: predicate).first as? HabitDayMO
    }

    /// Returns the entity's habit days that are later than the current date.
    /// - Returns: The habit's day entities in the future.
    func getFutureDays() -> [HabitDayMO] {
        // Declare the predicate to filter for days greater
        // than today (future days).
        let futurePredicate = NSPredicate(
            format: "day.date >= %@", Date() as NSDate
        )

        if let days = days?.filtered(using: futurePredicate) as? Set<HabitDayMO> {
            return [HabitDayMO](days)
        } else {
            return []
        }
    }

    /// Returns the current challenge.
    /// - Note: The current challenge is a DaysChallenge containing the current
    ///         date within its range (fromDate, toDate).
    func getCurrentChallenge() -> DaysChallengeMO? {
        let today = Date()
        let currentPredicate = NSPredicate(
            format: "fromDate <= %@ AND %@ <= toDate",
            today as NSDate,
            today as NSDate
        )
        return challenges?.filtered(using: currentPredicate).first as? DaysChallengeMO
    }
}
