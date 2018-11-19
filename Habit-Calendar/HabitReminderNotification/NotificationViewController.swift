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

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    // MARK: Properties

    @IBOutlet var label: UILabel?

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }

    // MARK: UNNotificationContentExtension Implementation.

    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
    }
}
