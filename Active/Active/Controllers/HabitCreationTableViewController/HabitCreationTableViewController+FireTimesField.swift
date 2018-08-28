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

    func observeForegroundEvent() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getAuthStatus(_:)),
            name: Notification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }

    @objc func getAuthStatus(_ notification: NSNotification? = nil) {
        notificationManager.getAuthorizationStatus { isAuthorized in
            DispatchQueue.main.async {
                self.displayNotificationAvailability(isAuthorized)
            }
        }
    }

    func displayNotificationAvailability(_ isAuthorized: Bool) {
        areNotificationsAuthorized = isAuthorized
        tableView.reloadData()
    }
}
