//
//  HabitCreationTableViewController+DaysField.swift
//  Active
//
//  Created by Tiago Maia Lopes on 24/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds the code to manage the days field.
extension HabitCreationTableViewController {

    // MARK: Imperatives

    /// Configures the text being displayed by each label within the days
    /// field.
    func configureDaysLabels() {
        if let days = days?.sorted(), !days.isEmpty {
            let formatter = DateFormatter.shortCurrent
            // Set the text for the label displaying the number of days.
            daysAmountLabel.text = "\(days.count) day\(days.count == 1 ? "" : "s") selected."
            // Set the text for the label displaying initial day in the sequence.
            fromDayLabel.text = formatter.string(from: days.first!)
            // Set the text for the label displaying final day in the sequence.
            toDayLabel.text = formatter.string(from: days.last!)
        } else {
            daysAmountLabel.text = "No days were selected."
            fromDayLabel.text = "--"
            toDayLabel.text = "--"
        }
    }
}

extension HabitCreationTableViewController: HabitDaysSelectionViewControllerDelegate {

    // MARK: HabitDaysSelectionViewController Delegate Methods

    func didSelectDays(_ daysDates: [Date]) {
        // Associate the habit's days with the dates selected by the user.
        days = daysDates
    }
}
