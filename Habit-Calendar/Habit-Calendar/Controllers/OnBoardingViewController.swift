//
//  OnBoardingViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 11/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {

    // MARK: Parameters

    /// The notification manager used to get the user's authorization.
    var notificationManager: UserNotificationManager!

    // MARK: Imperatives

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(notificationManager != nil, "The notification manager must be injected.")
    }

    // MARK: Actions

    @IBAction func closeController(_ sender: RoundedButton) {
        dismiss(animated: true) {
            UserDefaults.standard.setFirstLaunchPassed()

            // Request the user's authorization to schedule local notifications.
            self.notificationManager.requestAuthorization { authorized in
                print("User \(authorized ? "authorized" : "denied").")
            }
        }
    }
}
