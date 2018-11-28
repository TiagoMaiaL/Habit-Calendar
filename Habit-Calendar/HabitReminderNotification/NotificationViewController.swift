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

    /// The view displaying the color of the daily habit view.
    @IBOutlet weak var dailyHabitColorView: RoundedView!

    /// The habit being displayed, if it could be fetched.
    private var habit: HabitMO?

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
    // TODO: Remove the duplicated code between the habit details and this controllers.
    // TODO: Localize the extension.
    private func display(_ habit: HabitMO) {
        let hasChallenge = habit.getCurrentChallenge() != nil && habit.getCurrentChallenge()?.getCurrentDay() != nil

        // Display the color of the habit.
        let color = habit.getColor().uiColor
        progressView.tint = color
        dailyHabitColorView.backgroundColor = color

        // Configure the initial views for display.
        dailyHabitColorView.isHidden = hasChallenge
        progressView.isHidden = !hasChallenge
        daysToFinishChallengeLabel.isHidden = !hasChallenge
        missedDaysLabel.isHidden = !hasChallenge
        currentDayOrderLabel.isHidden = !hasChallenge

        if hasChallenge {
            displayChallenge(for: habit)
        } else {
            displayInfo(for: habit)
        }

        // Display the information about the current day, if it was executed or not.
        if habit.getCurrentDay()?.wasExecuted ?? false {
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
    }

    /// Displays the notification when the habit has an active challenge of days.
    /// - Parameter Habit: The habit containing the challenge to be displayed.
    private func displayChallenge(for habit: HabitMO) {
        guard let challenge = habit.getCurrentChallenge(), let currentDay = challenge.getCurrentDay() else {
            assertionFailure("The habit must have a challenge to be displayed.")
            return
        }

        let progressInfo = challenge.getCompletionProgress()

        // Configure the display of the progress view.
        progressView.progress = CGFloat(Double(progressInfo.past) / Double(progressInfo.total))

        // Configure the progress labels
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

        // Configure the prompt section.
        currentDayOrderLabel.text = challenge.getNotificationOrderText(for: currentDay)
    }

    /// Displays how many days were executed and missed in the provided habit entity.
    /// - Parameter habit: The entitiy to get the info from.
    private func displayInfo(for habit: HabitMO) {
        executedDaysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("%d day(s) executed.", comment: "The label showing how many days were executed."),
            habit.getExecutedDaysCount()
        )
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

                self?.habit = result.first
                self?.display(result.first!)
            }
        }
    }

    func didReceive(
        _ response: UNNotificationResponse,
        completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void
    ) {
        guard let category = response.notification.request.content.getCategory() else { return }

        switch category {
        case .dayPrompt:
            guard let habit = self.habit else {
                completion(.dismiss)
                return
            }

            if habit.getCurrentDay() == nil {
                let habitDayStorage = HabitDayStorage(
                    calendarDayStorage: DayStorage()
                )
                _ = habitDayStorage.create(
                    using: dataController!.persistentContainer.viewContext,
                    date: Date(),
                    and: habit
                )
            }

            let (yesAction, noAction) = category.getActionIdentifiers()

            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // Pass the response to the app delegate (launching the app).
                // The extension won't handle other controllers, as it's not an app.
                completion(.dismissAndForwardAction)

            case yesAction:
                habit.markCurrentDayAsExecuted()
                dataController?.saveContext()
                display(habit)

                // Dismiss it not immediately, but after a small delay, so the user can see the progress changing.
                completion(.doNotDismiss)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    completion(.dismiss)
                }

            case noAction:
                habit.markCurrentDayAsExecuted(false)
                dataController?.saveContext()
                completion(.dismiss)

            default:
                break
            }
        }
    }
}
