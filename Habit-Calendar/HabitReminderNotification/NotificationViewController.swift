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

    // MARK: UNNotificationContentExtension Implementation.

    func didReceive(_ notification: UNNotification) {
        // TODO: handle the notification.
        guard let habitID = notification.request.content.userInfo["habitIdentifier"] as? String else { return }

        dataController = DataController { error, persistentContainer in
            if error == nil {
                // Fetch the habit and display its data.
                let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
                request.predicate = NSPredicate(format: "id = %@", habitID)

                let result = try? persistentContainer.viewContext.fetch(request)
                print("Got the result: \(result?.count ?? 0)")
            }
        }
    }
}
