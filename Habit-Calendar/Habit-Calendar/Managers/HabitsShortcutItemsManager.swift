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

    /// The app containing the shortcutItems to be managed.
    private(set) weak var application: UIApplication!

    /// The identifiers of each habit associated with a shortcut item of the application object.
    private(set) var habitIdentifiers: [String] {
        get {
            // TODO: Get the user default values.
            return []
        }
        set {
            // TODO: Update the user default values.
        }
    }

    // MARK: Initializers

    init(application: UIApplication) {
        self.application = application
    }

    // MARK: Imperatives

    /// Refreshes the shortcut items of the application to include the passed habit, if necessary.
    /// - Parameter habit: the HabitMO used to add the new shortcut item.
    func refreshApplicationShortcuts(with habit: HabitMO) {
        // TODO:
    }

    /// Removes the shortcut item corresponding to the passed habit.
    /// - Parameter habit: the HabitMO used to get and remove the associated shortcut item.
    func removeShortcut(for habit: HabitMO) {
        // TODO:
    }
}
