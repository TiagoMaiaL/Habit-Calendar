//
//  HabitCreationTableViewController+FireTimesField.swift
//  Active
//
//  Created by Tiago Maia Lopes on 24/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds the code to manage the fire times field.
extension HabitCreationTableViewController: FireTimesDisplayable {}

extension HabitCreationTableViewController: FireTimesSelectionViewControllerDelegate {

    // MARK: HabitNotificationsSelectionViewControllerDelegate Delegate Methods

    func didSelectFireTimes(_ fireTimes: [FireTimesDisplayable.FireTime]) {
        // Associate the selected fire times.
        self.fireTimes = fireTimes
        // Change the labels to display the selected fire times.
        displayFireTimes(fireTimes)
    }
}

/// Adds code to inform the user if user notifications are authorized or not.
extension HabitCreationTableViewController: NotificationAvailabilityDisplayable {

    // MARK: Imperatives

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActivationEvent(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc func handleActivationEvent(_ notification: Notification) {
        displayNotificationAvailability()
    }

    func displayNotificationAvailability() {
        notificationManager.getAuthorizationStatus { isAuthorized in
            DispatchQueue.main.async {
                self.notAuthorizedContainer.isHidden = isAuthorized
                self.fireTimesContainer.isHidden = !isAuthorized
                self.tableView.reloadData()
            }
        }
    }
}
