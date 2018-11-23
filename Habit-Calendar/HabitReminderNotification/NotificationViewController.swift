//
//  NotificationViewController.swift
//  HabitReminderNotification
//
//  Created by Tiago Maia Lopes on 16/11/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import CoreData

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    // MARK: Properties

    /// The label displaying the habit name.
    @IBOutlet weak var habitNameLabel: UILabel!

    /// The progress view displaying the progress of the current challenge of days.
    @IBOutlet weak var progressView: RoundedProgressView!

    /// The label displaying how many days to finish the challenge.
    @IBOutlet weak var daysToFinishChallengeLabel: UILabel!

    /// The label displaying how many days were executed in the current challenge of days.
    @IBOutlet weak var executedDaysLabel: UILabel!

    /// The label displaying how many days were missed in the current challenge of days.
    @IBOutlet weak var missedDaysLabel: UILabel!

    /// The label showing the order of the today (e.g. today is your 15th day).
    @IBOutlet weak var currentDayOrderLabel: UILabel!

    /// The label displaying if the activity was executed today or not.
    @IBOutlet weak var dayPerformedLabel: UILabel!

    /// The data controller used to initalize core data and fetch the habit
    /// associated with the notification from the store.
    private var dataController: DataController?

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }

    // MARK: Imperatives

    /// Displays the habit associated with the received notification.
    /// - Parameter habit: The habit to be displayed.
    private func display(_ habit: HabitMO) {
        let color = habit.getColor().uiColor

        // Display the habit in one of two states: with challenges or without.
        if let challenge = habit.getCurrentChallenge() {
            let progressInfo = challenge.getCompletionProgress()

            progressView.progress = CGFloat(Double(progressInfo.past) / Double(progressInfo.total))
            progressView.tint = color

            daysToFinishChallengeLabel.text = String.localizedStringWithFormat(
                NSLocalizedString(
                    "%d day(s) to finish the challenge.",
                    comment: "The label showing the days to finish the challenge."
                ),
                progressInfo.total - progressInfo.past
            )
            missedDaysLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("%d day(s) missed.", comment: "The label showing how many days were missed."),
                challenge.getMissedDays()?.count ?? 0
            )
            executedDaysLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("%d day(s) executed.", comment: "The label showing how many days were executed."),
                challenge.getExecutedDays()?.count ?? 0
            )

            currentDayOrderLabel.text = challenge.getNotificationOrderText(for: habit.getCurrentDay()!)

            if habit.getCurrentDay()!.wasExecuted {
                dayPerformedLabel.text = NSLocalizedString(
                    "Yes, I did it.",
                    comment: "Text displayed when the current day is marked as executed."
                )
                dayPerformedLabel.textColor = color
            } else {
                dayPerformedLabel.text = NSLocalizedString(
                    "No, not yet.",
                    comment: "Text displayed when the current day isn't marked as executed."
                )
                dayPerformedLabel.textColor = UIColor(red: 47/255, green: 54/255, blue: 64/255, alpha: 1)
            }
        } else {

        }
    }

    // MARK: UNNotificationContentExtension Implementation.

    func didReceive(_ notification: UNNotification) {
        guard let habitID = notification.request.content.userInfo["habitIdentifier"] as? String else {
            assertionFailure("The notification request must inform the habit id.")
            return
        }
        habitNameLabel.text = notification.request.content.title

        dataController = DataController { [weak self] error, persistentContainer in
            if error == nil {
                // Fetch the habit and display its data.
                let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
                request.predicate = NSPredicate(format: "id = %@", habitID)

                guard let result = try? persistentContainer.viewContext.fetch(request), result.count > 0 else {
                    assertionFailure("""
Trying to display the habit but it doesn't exist anymore. Any scheduled notifications should've been removed.
"""
                    )
                    return
                }

                self?.display(result.first!)
            }
        }
    }
}
