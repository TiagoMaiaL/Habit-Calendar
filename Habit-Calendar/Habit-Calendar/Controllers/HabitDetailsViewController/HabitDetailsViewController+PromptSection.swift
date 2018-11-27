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
        let context = container.viewContext

        // If there isn't a current day, create one.
        if habit.getCurrentDay() == nil {
            _ = habitDayStorage.create(using: context, date: Date(), and: habit)
        }

        // Get the user's answer and mark the day according to it.
        let wasExecuted = sender.isOn

        context.perform {
            self.habit.markCurrentDayAsExecuted(wasExecuted)

            do {
                try context.save()
            } catch {
                context.rollback()
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
        if let currentChallenge = habit.getCurrentChallenge() {
            challengeHeaderStackView.isHidden = false

            // Display the current challenge's duration.
            let formatter = DateFormatter.shortCurrent
            currentChallengeDurationLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("From %@, to %@", comment: "Text displayed the challenge's duration."),
                formatter.string(from: currentChallenge.fromDate!),
                formatter.string(from: currentChallenge.toDate!)
            )
        } else {
            challengeHeaderStackView.isHidden = true
        }

        wasExecutedSwitch.onTintColor = habitColor
        if let currentDay = habit.getCurrentChallenge()?.getCurrentDay() {
            currentDayTitleLabel.isHidden = false
            displayPromptViewTitle(currentDay.challenge!.getNotificationOrderText(for: currentDay))
        } else {
            currentDayTitleLabel.isHidden = true
        }

        if habit.getCurrentDay()?.wasExecuted ?? false {
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
