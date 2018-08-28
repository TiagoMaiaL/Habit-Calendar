//
//  HabitDetailsViewController+FireTimesSection.swift
//  Active
//
//  Created by Tiago Maia Lopes on 23/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds the code to display the fire times.
extension HabitDetailsViewController: FireTimesDisplayable {}

/// Adds code to manage the fire times section.
extension HabitDetailsViewController {

    // MARK: Imperatives

    /// Displays the fire times section, if there's an active days' challenge for the habit being presented.
    func displayFireTimesSection() {
        guard habit.getCurrentChallenge() != nil else {
            // Hide all sections.
            noFireTimesContentView.isHidden = true
            fireTimesContentView.isHidden = true
            return
        }

        guard let fireTimesSet = habit.fireTimes as? Set<FireTimeMO>, !fireTimesSet.isEmpty else {
            fireTimesContentView.isHidden = true

            // Display the "No fire times" section.
            noFireTimesContentView.isHidden = false
            newFireTimesButton.backgroundColor = habitColor
            return
        }

        // Display the section showing the fire times.
        noFireTimesContentView.isHidden = true
        fireTimesContentView.isHidden = false

        fireTimesLabel.textColor = habitColor
        displayFireTimes(fireTimesSet.map { $0.getFireTimeComponents() })
    }
}

extension HabitDetailsViewController: FireTimesSelectionViewControllerDelegate {

    // MARK: FireTimesSelectionViewControllerDelegate methods

    func didSelectFireTimes(_ fireTimes: [FireTimesDisplayable.FireTime]) {
        _ = habitStorage.edit(habit, using: container.viewContext, and: fireTimes)
    }
}

/// Adds code to inform the user if user notifications are authorized or not.
extension HabitDetailsViewController: NotificationAvailabilityDisplayable {

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
        // If notifications aren't authorized, and the habit has an active challenge,
        // show it to the user.
        if !isAuthorized && habit.getCurrentChallenge() != nil {
            notificationsAuthContentView.isHidden = false
            fireTimesContentView.isHidden = true
        } else {
            // If they are, continue with the normal flow.
            notificationsAuthContentView.isHidden = true
            // Reload the sections related to the fire times.
            displayFireTimesSection()
        }
    }
}
