//
//  HabitCreationTableViewController+HabitHandling.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 16/10/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

extension HabitCreationTableViewController {

    // MARK: Properties

    /// Flag indicating if there's a habit being created or editted.
    var isEditingHabit: Bool {
        return habit != nil
    }

    // MARK: Imperatives

    /// Saves or updates the habit being created or edited.
    func handleHabitForPersistency() {
        // If there's no previous habit, create and persist a new one.
        container.performBackgroundTask { context in
            // Retrieve the app's current user before using it.
            guard let user = self.userStore.getUser(using: context) else {
                // It's a bug if there's no user. The user should be created on
                // the first launch.
                assertionFailure("Inconsistency: There's no user in the database. It must be set.")
                return
            }

            var habit: HabitMO!

            if !self.isEditingHabit {
                habit = self.habitStore.create(
                    using: context,
                    user: user,
                    name: self.name!,
                    color: self.habitColor!,
                    days: self.days!,
                    and: self.fireTimes
                )
            } else {
                // If there's a previous habit, update it with the new values.
                guard let habitToEdit = self.habitStore.habit(using: context, and: self.habit!.id!) else {
                    assertionFailure("The habit should be correclty fetched.")
                    return
                }

                habit = self.habitStore.edit(
                    habitToEdit,
                    using: context,
                    name: self.name,
                    color: self.habitColor,
                    days: self.days,
                    and: self.fireTimes
                )
            }

            self.saveCreationContext(context)

            let habitId = habit.id!
            DispatchQueue.main.async {
                // Every time a habit is added or edited, a new app shortcut related to it is added.
                self.shortcutsManager.addApplicationShortcut(
                    for: self.habitStore.habit(using: self.container.viewContext, and: habitId)!
                )
            }
        }
    }

    /// Tries to save the context and displays an alert to the user if an error happened.
    func saveCreationContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            context.rollback()
            DispatchQueue.main.async {
                self.present(
                    UIAlertController.make(
                        title: NSLocalizedString(
                            "Error",
                            comment: "Title of the alert displayed when the habit couldn't be persisted."
                        ),
                        message: NSLocalizedString(
                            "There was an error while the habit was being persisted. Please contact the developer.",
                            comment: "Message of the alert displayed when the habit couldn't be persisted."
                        )
                    ),
                    animated: true
                )
            }
            assertionFailure("Error: Couldn't save the new habit entity.")
        }
    }

}
