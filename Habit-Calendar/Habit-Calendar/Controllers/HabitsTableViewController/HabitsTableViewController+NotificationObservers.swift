//
//  HabitsTableViewController+NotificationObservers.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 04/10/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

extension HabitsTableViewController: NotificationObserver {
    func startObserving() {
        // Register to possible notifications thrown by changes in other managed contexts.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContextChanges(_:)),
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActivationEvent(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHabitToDisplayNotification(_:)),
            name: Notification.Name.didChooseHabitToDisplay,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewHabitQuickAction(_:)),
            name: Notification.Name.didSelectNewHabitQuickAction,
            object: nil
        )
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HabitsTableViewController: AppActiveObserver {
    func handleActivationEvent(_ notification: Notification) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            self.refreshListDate()
            self.updateList()
        }
    }
}

extension HabitsTableViewController: ManagedContextChangeObserver {
    /// Listens to any saved changes happening in other contexts and refreshes
    /// the viewContext.
    /// - Parameter notification: The thrown notification
    @objc internal func handleContextChanges(_ notification: Notification) {
        // If the changes were only updates, reload the tableView.
        if (notification.userInfo?["updated"] as? Set<NSManagedObject>) != nil {
            DispatchQueue.main.async {
                self.updateList()
            }
        }

        // Refresh the current view context by using the payloads in the notifications.
        container.viewContext.mergeChanges(fromContextDidSave: notification)

        DispatchQueue.main.async {
            self.displayEmptyStateIfNeeded()
        }
    }
}

extension HabitsTableViewController: HabitToBeDisplayedObserver {
    /// Takes the user to the habit details controller.
    private func showHabitDetails(_ habit: HabitMO) {
        // If the habit is already being displayed, there's no need to push a new controller.
        if let presentedDetailsController = navigationController?.topViewController as? HabitDetailsViewController {
            guard presentedDetailsController.habit != habit else { return }
            navigationController?.popViewController(animated: true)
        }

        guard let detailsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: "HabitDetails"
            ) as? HabitDetailsViewController else {
                assertionFailure("Couldn't get the habit details controller.")
                return
        }

        detailsController.habit = habit
        detailsController.container = container
        detailsController.habitStorage = habitStorage
        detailsController.notificationManager = notificationManager
        detailsController.notificationStorage = NotificationStorage()
        detailsController.notificationScheduler = NotificationScheduler(
            notificationManager: notificationManager
        )
        detailsController.shortcutsManager = shortcutsManager
        detailsController.reviewManager = reviewManager

        navigationController?.pushViewController(detailsController, animated: true)
    }

    func handleHabitToDisplayNotification(_ notification: Notification) {
        guard let habit = notification.userInfo?["habit"] as? HabitMO else {
            assertionFailure("Couldn't get the user notification's habit.")
            return
        }
        showHabitDetails(habit)
    }
}

extension HabitsTableViewController: NewHabitQuickActionObserver {
    func handleNewHabitQuickAction(_ notification: Notification) {
        if !(navigationController?.visibleViewController is HabitCreationTableViewController) {
            performSegue(withIdentifier: newHabitSegueIdentifier, sender: self)
        }
    }
}
