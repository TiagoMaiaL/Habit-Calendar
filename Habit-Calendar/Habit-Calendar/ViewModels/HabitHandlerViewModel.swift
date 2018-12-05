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

    private var habit: HabitMO?

    private let habitStorage: HabitStorage

    private let userStorage: UserStorage

    private let container: NSPersistentContainer

    var isEditing: Bool {
        return habit != nil
    }

    var isValid: Bool {
        return false
    }

    // MARK: Initializers

    init(habit: HabitMO?,
         habitStorage: HabitStorage,
         userStorage: UserStorage,
         container: NSPersistentContainer) {
        self.habit = habit
        self.habitStorage = habitStorage
        self.userStorage = userStorage
        self.container = container
    }

    // MARK: Imperatives

    func deleteHabit() {

    }

    func saveHabit() {

    }

    func getHabitName() -> String {
        return ""
    }

    func setHabitName(_ name: String) {

    }

    func getHabitColor() -> HabitMO.Color? {
        return nil
    }

    func setHabitColor(_ color: HabitMO.Color) {

    }

    func getSelectedDays() -> [Date]? {
        return nil
    }

    func setDays(_ days: [Date]) {

    }

    func getFireTimeComponents() -> [DateComponents]? {
        return nil
    }

    func setSelectedFireTimes(_ fireTimes: [DateComponents]) {

    }
}
