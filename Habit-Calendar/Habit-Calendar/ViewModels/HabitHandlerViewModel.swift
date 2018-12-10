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

    /// The shortcuts manager used to add, edit,
    /// or remove a shortcut related to the habit.
    private let shortcutsManager: HabitsShortcutItemsManager

    var isEditing: Bool {
        return habit != nil
    }

    var isValid: Bool {
        // Its name and color must be provided.
        let isCreationValid = habitName != nil && habitColor != nil

        let isNameDifferent = !(habitName ?? "").isEmpty && habitName != habit?.name
        let isColorDifferent = habitColor != nil && habitColor != habit?.getColor()
        let isChallengeDifferent = selectedDays != nil && !selectedDays!.isEmpty
        let areFireTimesDifferent = selectedFireTimes != nil

        // One of its properties must be changed.
        let isEditionValid = (isNameDifferent || isColorDifferent || isChallengeDifferent || areFireTimesDifferent)

        return isEditing ? isEditionValid : isCreationValid
    }

    /// The name of the habit, it can be provided by the entity, or set by the user.
    private var habitName: String?

    /// The color of the habit, provided by the entity or set by the user.
    private var habitColor: HabitMO.Color?

    /// The selected dates for the challenge of days.
    private var selectedDays: [Date]?

    /// The selected fire time components.
    private var selectedFireTimes: [DateComponents]?

    /// The fire time components associated with the passed habit for edition.
    private var habitFireTimes: [DateComponents]?

    // MARK: Initializers

    init(habit: HabitMO?,
         habitStorage: HabitStorage,
         userStorage: UserStorage,
         container: NSPersistentContainer,
         shortcutsManager: HabitsShortcutItemsManager) {
        if let habit = habit {
            self.habit = habit

            habitName = habit.name
            habitColor = habit.getColor()
            habitFireTimes = (habit.fireTimes as? Set<FireTimeMO>)?.map { $0.getFireTimeComponents() }
        }
        self.habitStorage = habitStorage
        self.userStorage = userStorage
        self.container = container
        self.shortcutsManager = shortcutsManager
    }

    // MARK: Imperatives

    func deleteHabit() {
        guard let habit = habit else { return }

        shortcutsManager.removeApplicationShortcut(for: habit)
        habitStorage.delete(habit, from: container.viewContext)
    }

    func saveHabit() {
        guard isValid else { return }

        container.performBackgroundTask { context in
            var savedHabit: HabitMO!
            var habitId: String!

            if self.isEditing {
                // Edit the habit.
            } else {
                // Create a new one.
                guard let user = self.userStorage.getUser(using: context) else {
                    assertionFailure("Couldn't get the user of the app.")
                    return
                }
                savedHabit = self.habitStorage.create(
                    using: context,
                    user: user,
                    name: self.habitName!,
                    color: self.habitColor!,
                    days: self.selectedDays,
                    and: self.selectedFireTimes
                )
            }

            // Hold its id.
            habitId = savedHabit.id

            do {
                try context.save()

                // Add an app shortcut for the saved habit. Since this needs to be made in the main thread, use
                // an entity associated with it.
                DispatchQueue.main.async {
                    self.shortcutsManager.addApplicationShortcut(
                        for: self.habitStorage.habit(using: self.container.viewContext, and: habitId)!
                    )
                }
            } catch {
                print("\(error)")
            }
        }
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
        return selectedFireTimes ?? habitFireTimes
    }

    mutating func setSelectedFireTimes(_ fireTimes: [DateComponents]) {
        self.selectedFireTimes = fireTimes
    }

    func getFireTimesAmountDescriptionText() -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString(
                "%d fire time(s) selected.",
                comment: "The number of fire times selected by the user."
            ),
            (selectedFireTimes ?? habitFireTimes)?.count ?? 0
        )
    }

    func getFireTimesDescriptionText() -> String? {
        if let fireTimes = selectedFireTimes ?? habitFireTimes, !fireTimes.isEmpty {
            // TODO: This code is replicated between the protocol and this view model. Fix this.
            // Set the text for the label displaying some of the selected fire times:
            let fireTimeFormatter = DateFormatter.fireTimeFormatter
            let fireDates = fireTimes.compactMap { Calendar.current.date(from: $0) }.sorted()
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
