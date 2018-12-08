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

    /// The selected fire time components.
    private var fireTimes: [DateComponents]?

    // MARK: Initializers

    init(habit: HabitMO?,
         habitStorage: HabitStorage,
         userStorage: UserStorage,
         container: NSPersistentContainer) {
        if let habit = habit {
            self.habit = habit

            habitName = habit.name
            habitColor = habit.getColor()
            fireTimes = (habit.fireTimes as? Set<FireTimeMO>)?.map { $0.getFireTimeComponents() }
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
        selectedDays = days.sorted()
    }

    func getDaysDescriptionText() -> String {
        if let days = selectedDays, !days.isEmpty {
            return String.localizedStringWithFormat(
                NSLocalizedString(
                    "%d day(s) selected.",
                    comment: "The label showing how many days were selected for the challenge."
                ),
                days.count
            )
        } else {
            return NSLocalizedString(
                "No days were selected.",
                comment: "Text displayed when the user didn't select any days of a new challenge of days."
            )
        }
    }

    func getFirstDateDescriptionText() -> String? {
        if let days = selectedDays, !days.isEmpty {
            return DateFormatter.shortCurrent.string(from: days.first!)
        } else {
            return nil
        }
    }

    func getLastDateDescriptionText() -> String? {
        if let days = selectedDays, !days.isEmpty {
            return DateFormatter.shortCurrent.string(from: days.last!)
        } else {
            return nil
        }
    }

    func getFireTimeComponents() -> [DateComponents]? {
        return fireTimes
    }

    mutating func setSelectedFireTimes(_ fireTimes: [DateComponents]) {
        self.fireTimes = fireTimes
    }

    func getFireTimesAmountDescriptionText() -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString(
                "%d fire time(s) selected.",
                comment: "The number of fire times selected by the user."
            ),
            fireTimes?.count ?? 0
        )
    }

    func getFireTimesDescriptionText() -> String? {
        if let fireTimes = fireTimes, !fireTimes.isEmpty {
            // TODO: This code is replicated between the protocol and this view model. Fix this.
            // Set the text for the label displaying some of the selected fire times:
            let fireTimeFormatter = DateFormatter.fireTimeFormatter
            let fireDates = fireTimes.compactMap {
                Calendar.current.date(from: $0)
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
        } else {
            return nil
        }
    }
}
