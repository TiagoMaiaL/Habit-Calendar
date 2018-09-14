//
//  HabitDayStorage.swift
//  Active
//
//  Created by Tiago Maia Lopes on 07/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Class in charge of storing HabitDay entities.
class HabitDayStorage {

    // MARK: - Properties

    /// The Day storage used to manage Day instances.
    let calendarDayStorage: DayStorage

    // MARK: - Initializers

    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameter calendarDayStorage: the storage used to manage calendar day instances.
    init(calendarDayStorage: DayStorage) {
        self.calendarDayStorage = calendarDayStorage
    }

    // MARK: - Imperatives

    /// Creates an array of HabitDay entities with the provided dates and habit.
    /// - Parameter context: The context used to insert the days into.
    /// - Parameter dates: The dates for each day.
    /// - Parameter habit: The habit associated with the entities.
    /// - Returns: the array of HabitDay entities.
    func createDays(using context: NSManagedObjectContext, dates: [Date], and habit: HabitMO) -> [HabitDayMO] {
        assert(!dates.isEmpty, "HabitDayStorage -- createDays: dates argument shouldn't be empty.")

        var habitDays = [HabitDayMO]()

        for date in dates {
            // Create the HabitDay entity from the Habit and calendar Day entities.
            let habitDay = create(using: context, date: date, and: habit)

            habitDays.append(habitDay)
        }

        return habitDays
    }

    /// Creates a HabitDay entity with the provided calendar day and habit.
    /// - Parameter context: The context used to write the day into.
    /// - Parameter date: The calendar date to be associated with the entity.
    /// - Parameter habit: The habit associated with the entity.
    /// - Returns: the created entity.
    func create(using context: NSManagedObjectContext, date: Date, and habit: HabitMO) -> HabitDayMO {
        // Declare the context to be used.
        let context = habit.managedObjectContext ?? context

        // Create the entity.
        let habitDay = HabitDayMO(context: context)

        // Get the calendar Day entity from the storage.
        // If a calendar Day entity wasn't found, a new Day entity should be
        // created to hold the HabitDay entities.
        let calendarDay = try? calendarDayStorage.day(using: context, and: date) ??
            calendarDayStorage.create(using: context, and: date)

        habitDay.id = UUID().uuidString
        habitDay.day = calendarDay
        habitDay.habit = habit
        // Starts with wasExecuted as false.
        habitDay.wasExecuted = false

        return habitDay
    }

    /// Deletes the provided HabitDay entity from the storage.
    /// - Parameter habitDay: The entity to be deleted.
    /// - Parameter context: The context used to remove the entity from.
    func delete(_ habitDay: HabitDayMO, from context: NSManagedObjectContext) {
        context.delete(habitDay)
    }

}
