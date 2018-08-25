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
