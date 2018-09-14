//
//  HabitDetailsViewController+NoChallengesSection.swift
//  Active
//
//  Created by Tiago Maia Lopes on 22/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds code to display the section informing that there's no active days' challenge for the habit.
extension HabitDetailsViewController {

    // MARK: Imperatives

    /// Displays the no-challenge content view, in case the habit doesn't have an active days' challenge.
    func displayNoChallengesView() {
        // Only display the view if there's no active challenge.
        guard habit.getCurrentChallenge() == nil else {
            noChallengeContentView.isHidden = true
            return
        }

        noChallengeContentView.isHidden = false
        newChallengeButton.backgroundColor = habitColor
    }

}

extension HabitDetailsViewController: HabitDaysSelectionViewControllerDelegate {

    // MARK: HabitDaysSelectionViewControllerDelegate methods.

    func didSelectDays(_ daysDates: [Date]) {
        assert(!daysDates.isEmpty, "The selected days must not be empty.")

        // Edit the habit being displayed by adding a new days challenge to it.
        _ = habitStorage.edit(
            habit, using:
            container.viewContext,
            days: daysDates
        )
        // TODO: Check the possible errors thrown by the save.
        try? container.viewContext.save()
    }
}
