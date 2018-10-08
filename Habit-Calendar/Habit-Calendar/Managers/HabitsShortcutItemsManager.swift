//
//  HabitsShortcutItemsManager.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 08/10/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Instance in charge of managing the dynamic shortcut items of the application.
/// Each shortcut gives quick access to a habit.
/// - Note: The shortcuts can be refreshed or deleted in the following actions:
///     - A habit is created or updated.
///     - A habit is viewed (its details are displayed to the user).
///     - A habit is deleted.
class HabitsShortcutItemsManager {

    // MARK: Properties

    /// The key for the identifier of the habit in the user info dictionary of the
    /// shortcut item.
    static let habitIdentifierUserInfoKey = "habit_identifier"

    /// The limit of dynamic shortcut items that can be added to the application.
    static let shortcutItemsLimit = 4

    /// The app containing the shortcutItems to be managed.
    private(set) weak var application: UIApplication!

    /// The identifiers of each habit associated with a shortcut item of the application object.
    var habitIdentifiers: [String] {
        return application.shortcutItems?.compactMap {
            $0.userInfo?[HabitsShortcutItemsManager.habitIdentifierUserInfoKey] as? String
        } ?? []
    }

    // MARK: Initializers

    init(application: UIApplication) {
        self.application = application
    }

    // MARK: Imperatives

    /// Adds a new shortcut item associated with the passed habit to the application.
    /// - Parameter habit: the HabitMO used to add the new shortcut item.
    func addApplicationShortcut(for habit: HabitMO) {
        assert(habit.id != nil, "An invalid habit entity was passed.")
        var shortcuts = [UIApplicationShortcutItem]()

        if let appShortcuts = application.shortcutItems, !appShortcuts.isEmpty {
            shortcuts = appShortcuts
        }

        shortcuts.insert(makeShorcutItem(habit: habit), at: 0)

        if shortcuts.count > HabitsShortcutItemsManager.shortcutItemsLimit {
            _ = shortcuts.removeLast()
        }

        application.shortcutItems = shortcuts
    }

    /// Removes the shortcut item corresponding to the passed habit.
    /// - Parameter habit: the HabitMO used to get and remove the associated shortcut item.
    func removeApplicationShortcut(for habit: HabitMO) {
        assert(habit.id != nil, "An invalid habit entity was passed.")
        // TODO:
    }

    /// Makes a new dynamic shortcut item for the passed habit.
    /// - Parameter habit: the habit associated with the shortcut to be created.
    /// - Returns: the shortcut item.
    private func makeShorcutItem(habit: HabitMO) -> UIApplicationShortcutItem {
        return UIApplicationShortcutItem(
            type: AppDelegate.QuickActionType.displayHabit.rawValue,
            localizedTitle: habit.getTitleText(),
            localizedSubtitle: nil,
            icon: nil,
            userInfo: [
                HabitsShortcutItemsManager.habitIdentifierUserInfoKey: habit.id! as NSSecureCoding
            ]
        )
    }
}
