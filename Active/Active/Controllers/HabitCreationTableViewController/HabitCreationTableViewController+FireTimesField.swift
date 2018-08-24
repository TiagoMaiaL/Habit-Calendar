//
//  HabitCreationTableViewController+FireTimesField.swift
//  Active
//
//  Created by Tiago Maia Lopes on 24/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds the code to manage the fire times field.
extension HabitCreationTableViewController {

    // MARK: Imperatives

    /// Configures the text being displayed by each label within
    /// the notifications field.
    func configureFireTimesLabels() {
        if let fireTimes = fireTimes, !fireTimes.isEmpty {
            // Set the text for the label displaying the amount of fire times.
            fireTimesAmountLabel.text = "\(fireTimes.count) fire time\(fireTimes.count == 1 ? "" : "s") selected."

            // Set the text for the label displaying some of the
            // selected fire times:
            let fireTimeFormatter = DateFormatter.makeFireTimeDateFormatter()
            let fireDates = fireTimes.compactMap {
                Calendar.current.date(from: $0)
                }.sorted()
            var fireTimesText = ""

            for fireDate in fireDates {
                fireTimesText += fireTimeFormatter.string(from: fireDate)

                // If the current fire time isn't the last one,
                // include a colon to separate it from the next.
                if fireDates.index(of: fireDate)! != fireDates.endIndex - 1 {
                    fireTimesText += ", "
                }
            }

            selectedFireTimesLabel.text = fireTimesText
        } else {
            fireTimesAmountLabel.text = "No fire times selected."
            selectedFireTimesLabel.text = "--"
        }
    }
}

extension HabitCreationTableViewController: FireTimesSelectionViewControllerDelegate {

    // MARK: HabitNotificationsSelectionViewControllerDelegate Delegate Methods

    func didSelectFireTimes(_ fireTimes: [FireTimesSelectionViewController.FireTime]) {
        // Associate the selected fire times.
        self.fireTimes = fireTimes
        // Change the labels to display the selected fire times.
        configureFireTimesLabels()
    }
}
