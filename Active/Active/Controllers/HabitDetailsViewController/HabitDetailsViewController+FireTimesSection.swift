//
//  HabitDetailsViewController+FireTimesSection.swift
//  Active
//
//  Created by Tiago Maia Lopes on 23/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds code to manage the fire times section.
extension HabitDetailsViewController {

    // MARK: Imperatives

    /// Displays the fire times section, if there's an active days' challenge for the habit being presented.
    func displayFireTimesSection() {
        guard habit.getCurrentChallenge() != nil, let fireTimesText = habit.getFireTimesText() else {
            // Display the "No fire times" section.
            fireTimesContentView.isHidden = true
            return
        }

        fireTimesContentView.isHidden = false

        fireTimesLabel.textColor = habitColor
        fireTimesLabel.text = fireTimesText
    }
}
