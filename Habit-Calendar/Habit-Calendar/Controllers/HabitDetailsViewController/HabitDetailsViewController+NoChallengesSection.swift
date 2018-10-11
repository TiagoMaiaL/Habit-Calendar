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

        do {
            try container.viewContext.save()
        } catch {
            container.viewContext.rollback()
            present(
                UIAlertController.make(
                    title: NSLocalizedString("Error", comment: ""),
                    message: NSLocalizedString(
                        "The new challenge of days couldn't be added to the habit. Plase contact the developer.",
                        comment: "Message displayed when there's an error with the creation of a new challenge."
                    )
                ),
                animated: true
            )
            assertionFailure("Couldn't add a new challenge to the habit.")
        }
    }
}
