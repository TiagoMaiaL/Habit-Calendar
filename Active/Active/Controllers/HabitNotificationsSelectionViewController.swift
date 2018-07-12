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
    
    /// The fire date cell's reusable identifier.
    private let cellIdentifier = "fire date selection cell"
    
    /// The static fire dates interval.
    private let interval = 30
    
    private let fireDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        
        return formatter
    }()
    
    /// The fire dates displayed to the user for selection.
    private lazy var fireDates = makeFireDatesProgression(
        minutesInterval: interval
    )
    
    /// The fire dates selected by the user.
    private var selectedFireDates = Set<Date>()
    
    /// The controller's label informing the possible actions
    /// for the controller.
//    @IBOutlet weak var informationLabel: UILabel!
    
    /// The fire dates selection table view.
    @IBOutlet weak var tableView: UITableView!
    
    /// The button used to finish the selection.
    @IBOutlet weak var doneButton: UIButton!
    
    /// The notification manager used to get the authorization status and
    /// reflect the result in the view.
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
        assert(
            !selectedFireDates.isEmpty,
            "Inconsistency: the selected fire dates shouldn't be empty."
        )
        
        // Call the delegate passing the fire dates selected
        // by the user.
        delegate?.didSelectFireDates(Array<Date>(selectedFireDates))
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Imperatives
    
    /// Configures the state of the done button according
    /// to the selected fire dates.
    private func handleDoneButton() {
        doneButton.isEnabled = !selectedFireDates.isEmpty
    }
    
    /// Update the views according to the User's authorization.
    @objc private func updateViews(_ notification: Notification? = nil) {
        // Check if the local notifications are authorized by the user.
        notificationManager.getAuthorizationStatus { isAuthorized in
            // If it's not authorized, change the view informing it.
            DispatchQueue.main.async {
                if isAuthorized {
                    // Enable the button and the tableView selection.
                    // Change the controller's appearance.
//                    self.informationLabel.text = "At what time would you like to be rembered to do your habitual activity?"
                } else {
                    // Change information label, and disable
                    // the button and the tableView selection.
                    // Change the controller's appearance to represent
                    // that there's no authorization to use
                    // local notifications.
//                    self.informationLabel.text = "In order to get remembered about you habits, enable the user notifications in the settings app."
                }
            }
        }
    }
}

extension HabitNotificationsSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Imperatives
    
    /// Creates an array of successive fire times by adding
    /// the specified interval in minutes.
    /// - Note: The first date is 00:00 and the last date is 23:59 or
    ///         a time before.
    /// - Parameter minutesInterval: The minutes used to create the
    ///                              progression of dates.
    /// - Returns: An array of successive fire times within a day.
    func makeFireDatesProgression(minutesInterval: Int) -> [Date] {
        var fireDates = [Date]()
        
        let minutesInDay = 24 * 60
        let beginningDate = Date().getBeginningOfDay()
        
        // Generate the dates and append them to the array.
        // Declare the range to be used by determining the amount of
        // dates to be added.
        for index in 0..<Int(minutesInDay / minutesInterval) {
            // Get the next date in the progression.
            guard let nextDate = beginningDate.byAddingMinutes(
                minutesInterval * index
            ) else {
                assertionFailure("Inconsistency: the range can't be correclty generated.")
                return []
            }
            
            fireDates.append(nextDate)
        }
        
        return fireDates
    }
    
    // MARK: TableView DataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fireDates.count
    }
    
    // MARK: TableView Delegate methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the cell.
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier
        ) ?? UITableViewCell(
            style: .default,
            reuseIdentifier: cellIdentifier
        )
        
        // Set it's time text by using a date formatter.
        cell.textLabel?.text = fireDateFormatter.string(from: fireDates[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected date.
        let selectedDate = fireDates[indexPath.row]
        
        // Add it to the selected ones.
        selectedFireDates.insert(selectedDate)
        
        // Enable the done button.
        handleDoneButton()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Get the selected date.
        let selectedDate = fireDates[indexPath.row]
        
        // Remove it from the selected dates.
        if selectedFireDates.contains(selectedDate) {
            selectedFireDates.remove(selectedDate)
        }
        
        // Handle the done button enabled state.
        handleDoneButton()
    }
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol HabitNotificationsSelectionViewControllerDelegate: class {
    
    /// Called when the habit days are done being selected by the user.
    func didSelectFireDates(_ fireDates: [Date])
    
}
