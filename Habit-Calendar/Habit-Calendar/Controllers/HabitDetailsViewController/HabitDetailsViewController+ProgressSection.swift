//
//  HabitDetailsViewController+ProgressSection.swift
//  Active
//
//  Created by Tiago Maia Lopes on 21/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds code to manage the current days' challenge's progress section.
extension HabitDetailsViewController {

    // MARK: Imperatives

    /// Displays the current days' challenge's progress.
    func displayProgressSection() {
        guard let challenge = habit.getCurrentChallenge() else {
            challengeProgressContentView.isHidden = true
            return
        }

        challengeProgressContentView.isHidden = false

        // Display the challenge's information.

        // How many days to complete the challenge.
        let daysToComplete = (challenge.days?.count ?? 0) - (challenge.getPastDays()?.count ?? 0)
        daysToFinishLabel.text = String.localizedStringWithFormat(
            NSLocalizedString(
                "%d day(s) to finish the challenge.",
                comment: "The label showing the days to finish the challenge."
            ),
            daysToComplete
        )
        // How many days were executed.
        executedDaysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("%d day(s) executed.", comment: "The label showing how many days were executed."),
            challenge.getExecutedDays()?.count ?? 0
        )
        // How many days were missed.
        missedDaysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("%d day(s) missed.", comment: "The label showing how many days were missed."),
            challenge.getMissedDays()?.count ?? 0
        )

        // Display the challenge's progress bar.
        let progressInfo = challenge.getCompletionProgress()
        progressBar.tint = habitColor
        progressBar.progress = CGFloat(progressInfo.past) / CGFloat(progressInfo.total)
    }
}
