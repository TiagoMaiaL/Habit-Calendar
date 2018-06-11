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
    
    /// The persistent container used by the storage.
    let container: NSPersistentContainer
    
    /// The Day storage used to manage Day instances.
    let calendarDayStorage: DayStorage
    
    // MARK: - Initializers
    
    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameter container: the persistent container used by the storage.
    /// - Parameter calendarDayStorage: the storage used to manage calendar day instances.
    init(container: NSPersistentContainer, calendarDayStorage: DayStorage) {
        self.container = container
        self.calendarDayStorage = calendarDayStorage
    }
    
    // MARK: - Imperatives
    
    /// Creates an array of HabitDay entities with the provided dates and habit.
    /// - Parameter dates: the dates for each day.
    /// - Parameter habit: The habit associated with the entities.
    /// - Returns: the array of HabitDay entities.
    func createDays(with dates: [Date], habit: Habit) -> [HabitDay] {
        assert(!dates.isEmpty, "HabitDayStorage -- createDays: dates argument shouldn't be empty.")
        
        var habitDays = [HabitDay]()
        
        for date in dates {
            // Get the calendar Day entity from the storage.
            // If a calendar Day entity wasn't found, a new Day entity should be created to
            // hold the HabitDay entities.
            let calendarDay = calendarDayStorage.day(for: date) ?? calendarDayStorage.create(withDate: date)
            
            // Create the HabitDay entity from the Habit and calendar Day entities.
            let habitDay = create(with: calendarDay, habit: habit)
            
            habitDays.append(habitDay)
        }
        
        return habitDays
    }
    
    /// Creates a HabitDay entity with the provided calendar day and habit.
    /// - Parameter day: the calendar day associated with the entity.
    /// - Parameter habit: The habit associated with the entity.
    /// - Returns: the created entity.
    func create(with day: Day, habit: Habit) -> HabitDay {
        let habitDay = HabitDay(context: container.viewContext)
        
        habitDay.day = day
        habitDay.habit = habit
        // Starts with wasExecuted as false.
        habitDay.wasExecuted = false
        
        return habitDay
    }
    
    /// Deletes the provided HabitDay entity from the storage.
    /// - Parameter habitDay: The entity to be deleted.
    func delete(habitDay: HabitDay) {
        container.viewContext.delete(habitDay)
    }
    
}
