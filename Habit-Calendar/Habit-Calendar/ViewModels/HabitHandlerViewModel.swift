//
//  HabitHandlerViewModel.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 05/12/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// Manages a habit and presents its values.
struct HabitHandlerViewModel: HabitHandlingViewModel {

    // MARK: Properties

    /// The habit being handled by this view model.
    private var habit: HabitMO?

    /// The habit storage used to create/edit/delete the habit entity.
    private let habitStorage: HabitStorage

    /// The user storage used to get the main user and associate it to the habit.
    private let userStorage: UserStorage

    /// The persistent container used to perform the operations of the habit.
    private let container: NSPersistentContainer

    var isEditing: Bool {
        return habit != nil
    }

    var isValid: Bool {
        return false
    }

    /// The name of the habit, it can be provided by the entity, or set by the user.
    private var habitName: String?

    /// The color of the habit, provided by the entity or set by the user.
    private var habitColor: HabitMO.Color?

    /// The selected dates for the challenge of days.
    private var selectedDays: [Date]?

    // MARK: Initializers

    init(habit: HabitMO?,
         habitStorage: HabitStorage,
         userStorage: UserStorage,
         container: NSPersistentContainer) {
        if let habit = habit {
            self.habit = habit

            habitName = habit.name
            habitColor = habit.getColor()
        }
        self.habitStorage = habitStorage
        self.userStorage = userStorage
        self.container = container
    }

    // MARK: Imperatives

    func deleteHabit() {

    }

    func saveHabit() {

    }

    func getHabitName() -> String? {
        return habitName
    }

    mutating func setHabitName(_ name: String) {
        habitName = name
    }

    func getHabitColor() -> HabitMO.Color? {
        return habitColor
    }

    mutating func setHabitColor(_ color: HabitMO.Color) {
        habitColor = color
    }

    func getSelectedDays() -> [Date]? {
        return selectedDays
    }

    mutating func setDays(_ days: [Date]) {
        selectedDays = days
    }

    func getFireTimeComponents() -> [DateComponents]? {
        return nil
    }

    func setSelectedFireTimes(_ fireTimes: [DateComponents]) {

    }
}
