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
            // Hide everything related to fire times.
            noFireTimesContentView.isHidden = true
            notificationsAuthContentView.isHidden = true
            fireTimesContentView.isHidden = true
            return
        }

        notificationManager.getAuthorizationStatus { isAuthorized in
            DispatchQueue.main.sync {
                if isAuthorized {
                    // If the habit doesn't have any fire times associated with it, display the "no fire times" section
                    // and hide the others.
                    guard let fireTimesSet = self.habit.fireTimes as? Set<FireTimeMO>, !fireTimesSet.isEmpty else {
                        self.fireTimesContentView.isHidden = true
                        self.notificationsAuthContentView.isHidden = true

                        // Display and configure the "No fire times" section.
                        self.noFireTimesContentView.isHidden = false
                        self.newFireTimesButton.backgroundColor = self.habitColor
                        return
                    }

                    // Everything is ok, display the fire times.
                    self.noFireTimesContentView.isHidden = true
                    self.notificationsAuthContentView.isHidden = true

                    // Configure the fire times section.
                    self.fireTimesContentView.isHidden = false
                    self.fireTimesLabel.textColor = self.habitColor
                    self.displayFireTimes(fireTimesSet.map { $0.getFireTimeComponents() })
                } else {
                    // Display the "not authorized" view and hide the others.
                    self.notificationsAuthContentView.isHidden = false

                    self.noFireTimesContentView.isHidden = true
                    self.fireTimesContentView.isHidden = true
                }
            }
        }
    }
}

extension HabitDetailsViewController: FireTimesSelectionViewControllerDelegate {

    // MARK: FireTimesSelectionViewControllerDelegate methods

    func didSelectFireTimes(_ fireTimes: [FireTimesDisplayable.FireTime]) {
        _ = habitStorage.edit(habit, using: container.viewContext, and: fireTimes)
        // Save it to make any new changes in sync.
        try? container.viewContext.save()
    }
}

/// Adds code to inform the user if user notifications are authorized or not.
extension HabitDetailsViewController: NotificationAvailabilityDisplayable {

    // MARK: Imperatives

    func displayNotificationAvailability() {
        // Update the fire times section.
        displayFireTimesSection()
    }
}
