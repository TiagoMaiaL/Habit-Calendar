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
            assertionFailure(
                "Inconsistency: There isn't a current habit day but the prompt is being displayed."
            )
            return
        }

        // Get the user's answer.
        let wasExecuted = sender.isOn

        challenge.managedObjectContext?.perform {
            challenge.markCurrentDayAsExecuted(wasExecuted)

            // TODO: Display an error to the user.
            try? challenge.managedObjectContext?.save()

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
        currentChallengeDurationLabel.text = """
        From \(formatter.string(from: currentChallenge.fromDate!)), \
        to \(formatter.string(from: currentChallenge.toDate!))
        """

        // Get the order of the day in the challenge.
        guard let orderedChallengeDays = currentChallenge.days?.sortedArray(
            using: [NSSortDescriptor(key: "day.date", ascending: true)]
            ) as? [HabitDayMO] else {
                assertionFailure("Error: Couldn't get the challenge's sorted habit days.")
                return
        }
        guard let dayIndex = orderedChallengeDays.index(of: currentDay) else {
            assertionFailure("Error: Couldn't get the current day's index.")
            return
        }

        promptContentView.isHidden = false

        wasExecutedSwitch.onTintColor = habitColor

        let order = dayIndex + 1
        displayPromptViewTitle(withOrder: order)

        if currentDay.wasExecuted {
            wasExecutedSwitch.isOn = true
            promptAnswerLabel.text = "Yes, I did it."
            promptAnswerLabel.textColor = habitColor
        } else {
            wasExecutedSwitch.isOn = false
            promptAnswerLabel.text = "No, not yet."
            promptAnswerLabel.textColor = UIColor(red: 47/255, green: 54/255, blue: 64/255, alpha: 1)
        }
    }

    /// Configures the prompt view title text.
    /// - Parameter order: the order of day in the current challenge.
    private func displayPromptViewTitle(withOrder order: Int) {
        var orderTitle = ""

        switch order {
        case 1:
            orderTitle = "1st"
        case 2:
            orderTitle = "2nd"
        case 3:
            orderTitle = "3rd"
        default:
            orderTitle = "\(order)th"
        }

        let attributedString = NSMutableAttributedString(string: "\(orderTitle) day")
        attributedString.addAttributes(
            [
                NSAttributedStringKey.font: UIFont(name: "SFProText-Semibold", size: 20)!,
                NSAttributedStringKey.foregroundColor: habitColor
            ],
            range: NSRange(location: 0, length: orderTitle.count)
        )

        currentDayTitleLabel.attributedText = attributedString
    }
}
