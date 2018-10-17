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
        if habit != nil {
            // If the habit is being editted, change the field's title and question texts.
            challengeFieldTitleLabel.text = NSLocalizedString(
                "New challenge of days",
                comment: "Text of the title of the days field in the edition controller."
            )
            challengeFieldQuestionTitle.text = NSLocalizedString(
                "Would you like to begin a new challenge of days?",
                comment: "Description of the days field in the edition controller."
            )
        }

        if let days = days?.sorted(), !days.isEmpty {
            let formatter = DateFormatter.shortCurrent
            // Set the text for the label displaying the number of days.
            daysAmountLabel.text = String.localizedStringWithFormat(
                NSLocalizedString(
                    "%d day(s) selected.",
                    comment: "The label showing how many days were selected for the challenge."
                ),
                days.count
            )
            // Set the text for the label displaying initial day in the sequence.
            fromDayLabel.text = formatter.string(from: days.first!)
            // Set the text for the label displaying final day in the sequence.
            toDayLabel.text = formatter.string(from: days.last!)
        } else {
            daysAmountLabel.text = NSLocalizedString(
                "No days were selected.",
                comment: "Text displayed when the user didn't select any days of a new challenge of days."
            )
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
