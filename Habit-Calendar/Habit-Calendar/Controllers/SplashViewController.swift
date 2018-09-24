//
//  SplashViewController.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 24/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Controller used to show that the app is being loaded. It also displays
/// any errors that might occur while loading the core data stack.
class SplashViewController: UIViewController {

    // MARK: Properties

    /// Loading view indicating progress.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Life Cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }
    }
}
