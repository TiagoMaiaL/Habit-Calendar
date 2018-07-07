//
//  HabitNotificationsSelectionViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 04/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The controller used to select the notification fire dates for the
/// habit being created/edited.
class HabitNotificationsSelectionViewController: UIViewController {

    // MARK: Properties
    
    /// The picker the user uses to select the fire date.
    @IBOutlet weak var timePickerView: UIDatePicker!
    
    /// The controller's label informing the possible actions
    /// for the controller.
    @IBOutlet weak var informationLabel: UILabel!
    
    /// The button used to finish the selection.
    @IBOutlet weak var doneButton: UIButton!
    
    /// The notification manager used to get the authorization status.
    var notificationManager: UserNotificationManager!
    
    /// The delegate in charge of receiving the selected fire dates.
    weak var delegate: HabitNotificationsSelectionViewControllerDelegate?
    
    // MARK: Deinitializers
    
    deinit {
        // Remove any observers.
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make assertions on the required dependencies.
        assert(
            notificationManager != nil,
            "Failed to inject the notification manager."
        )
        
        // Start observing the app's active state event. This is made
        // to check if the Notifications are now allowed and update
        // the views accordingly.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateViews(_:)),
            name: Notification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    // MARK: Actions
    
    @IBAction func selectFireDates(_ sender: UIButton) {
        // Call the delegate passing the fire dates selected
        // by the user.
        delegate?.didSelectFireDates([timePickerView.date])
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Imperatives
    
    /// Update the views according to the User's authorization.
    @objc private func updateViews(_ notification: Notification? = nil) {
        // Check if the local notifications are authorized by the user.
        notificationManager.getAuthorizationStatus { isAuthorized in
            // If it's not authorized, change the view informing it.
            DispatchQueue.main.async {
                if isAuthorized {
                    // Enable the button and the picker view.
                    self.informationLabel.text = "At what time would you like to be rembered to do your habitual activity?"
                    self.timePickerView.isEnabled = true
                    self.doneButton.isEnabled = true
                } else {
                    // Change information label, and disable
                    // the picker and the button.
                    self.informationLabel.text = "In order to get remembered about you habits, enable the user notifications in the settings app."
                    self.timePickerView.isEnabled = false
                    self.doneButton.isEnabled = false
                }
            }
        }
    }
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol HabitNotificationsSelectionViewControllerDelegate: class {
    
    /// Called when the habit days are done being selected by the user.
    func didSelectFireDates(_ fireDates: [Date])
    
}
