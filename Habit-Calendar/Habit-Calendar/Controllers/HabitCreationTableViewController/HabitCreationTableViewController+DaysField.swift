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

    /// Configures the text being displayed by each label within the days field.
    func configureDaysLabels() {
//        if habitHandlerViewModel.isEditing {
//            challengeFieldTitleLabel.text = NSLocalizedString(
//                "New challenge of days",
//                comment: "Text of the title of the days field in the edition controller."
//            )
//            challengeFieldQuestionTitle.text = NSLocalizedString(
//                "Would you like to begin a new challenge of days?",
//                comment: "Description of the days field in the edition controller."
//            )
//        }
//
//        daysAmountLabel.text = habitHandlerViewModel.getDaysDescriptionText()
//        fromDayLabel.text = habitHandlerViewModel.getFirstDateDescriptionText() ?? "--"
//        toDayLabel.text = habitHandlerViewModel.getLastDateDescriptionText() ?? "--"
    }
}

extension HabitCreationTableViewController: HabitDaysSelectionViewControllerDelegate {

    // MARK: HabitDaysSelectionViewController Delegate Methods

    func didSelectDays(_ daysDates: [Date]) {
        habitHandlerViewModel.setDays(daysDates)
        configureDaysLabels()
        configureDoneButton()
    }
}
