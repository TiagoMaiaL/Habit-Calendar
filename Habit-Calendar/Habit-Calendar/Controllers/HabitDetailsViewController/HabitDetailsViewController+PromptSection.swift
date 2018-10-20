//
//  HabitDetailsViewController+PromptSection.swift
//  Active
//
//  Created by Tiago Maia Lopes on 22/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds the code to display the current challenge's prompt section.
extension HabitDetailsViewController {

    // MARK: Actions

    /// Sets the current as executed or not, depending on the user's action.
    @IBAction func informActivityExecution(_ sender: UISwitch) {
        guard let challenge = habit.getCurrentChallenge() else {
            assertionFailure("Inconsistency: There isn't a current habit day but the prompt is being displayed.")
            return
        }

        // Get the user's answer.
        let wasExecuted = sender.isOn

        challenge.managedObjectContext?.perform {
            challenge.markCurrentDayAsExecuted(wasExecuted)

            // Schedule / unschedule the notifications for the day, depending on the user's answer.
            let dayNotifications = self.notificationStorage.notifications(
                from: challenge.managedObjectContext!,
                habit: self.habit,
                andDay: Date()
            ).filter { $0.fireDate?.isFuture ?? false}

            if wasExecuted {
                // Update the review parameters. The execution count is increased by one.
                self.reviewManager.updateReviewParameters()
                self.notificationScheduler.unschedule(dayNotifications)
            } else {
                self.notificationScheduler.schedule(dayNotifications)
            }

            do {
                try challenge.managedObjectContext?.save()
            } catch {
                challenge.managedObjectContext?.rollback()
                self.present(
                    UIAlertController.make(
                        title: NSLocalizedString("Error", comment: ""),
                        message: NSLocalizedString(
                            "The current day couldn't be marked as executed. Please contact the developer.",
                            comment: "Message displayed when an error occurs while marking the day as executed."
                        )
                    ),
                    animated: true
                )
                assertionFailure("Inconsistency: couldn't mark the current day as executed.")
            }

            DispatchQueue.main.async {
                // Update the prompt view.
                self.displayPromptView()
                // Update the progress view.
                self.displayProgressSection()
                // Reload calendar to show the executed day.
                self.calendarView.reloadData()
                self.calendarView.scrollToDate(Date().getBeginningOfDay())
            }
        }
    }

    // MARK: Imperatives

    /// Displays the prompt view if today is a challenge's day.
    func displayPromptView() {
        // ContentView is hidden by default.
        promptContentView.isHidden = true

        // Check if there's a current challenge for the habit.
        guard let currentChallenge = habit.getCurrentChallenge() else {
            return
        }
        // Check if today is a challenge's HabitDay.
        guard let currentDay = currentChallenge.getCurrentDay() else {
            return
        }

        // Display the current challenge's duration.
        let formatter = DateFormatter.shortCurrent
        currentChallengeDurationLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("From %@, to %@", comment: "Text displayed the challenge's duration."),
            formatter.string(from: currentChallenge.fromDate!),
            formatter.string(from: currentChallenge.toDate!)
        )

        promptContentView.isHidden = false
        wasExecutedSwitch.onTintColor = habitColor
        displayPromptViewTitle(currentChallenge.getNotificationOrderText(for: currentDay))

        if currentDay.wasExecuted {
            wasExecutedSwitch.isOn = true
            promptAnswerLabel.text = NSLocalizedString(
                "Yes, I did it.",
                comment: "Text displayed when the current day is marked as executed."
            )
            promptAnswerLabel.textColor = habitColor
        } else {
            wasExecutedSwitch.isOn = false
            promptAnswerLabel.text = NSLocalizedString(
                "No, not yet.",
                comment: "Text displayed when the current day isn't marked as executed."
            )
            promptAnswerLabel.textColor = UIColor(red: 47/255, green: 54/255, blue: 64/255, alpha: 1)
        }
    }

    /// Configures the prompt view title text.
    /// - Parameter title: The title string.
    private func displayPromptViewTitle(_ title: String) {
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "SFProText-Semibold", size: 20)!,
                NSAttributedString.Key.foregroundColor: habitColor
            ],
            range: NSRange(location: 0, length: title.count)
        )

        currentDayTitleLabel.attributedText = attributedString
    }
}
