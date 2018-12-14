//
//  HabitCreationViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

private enum Constants {
    enum SegueIds {
        /// The segue identifier for the DaysSelection controller.
        static let daysSelection = "Show days selection controller"

        /// The segue identifier for the NotificationsSelection controller.
        static let fireTimesSelection = "Show fire dates selection controller"
    }

    enum CellReuseIds {
        /// The cell identifier for the name field.
        static let nameField = "name field reuse identifier"

        /// The cell identifier for the color field.
        static let colorField = "color field reuse identifier"

        /// The cell identifier for the challenge field.
        static let challengeField = "challenge field reuse identifier"

        /// The cell identifier for the fire times field.
        static let fireTimesField = "Fire tiems field reuse identifier"
    }

    enum Fields: Int {
        case name = 0
        case color
        case challenge
        case fireTimes

        static let count = Fields.fireTimes.rawValue + 1

        /// Gets the cell identifier associated with the field enum.
        func getAssociatedCellIdentifier() -> String {
            switch self {
            case .name:
                return Constants.CellReuseIds.nameField
            case .color:
                return Constants.CellReuseIds.colorField
            case .challenge:
                return Constants.CellReuseIds.challengeField
            case .fireTimes:
                return Constants.CellReuseIds.fireTimesField
            }
        }
    }
}

/// Controller used to allow the user to create/edit habits.
class HabitCreationTableViewController: UITableViewController {

    // MARK: Properties

    /// The button used to store the habit.
    @IBOutlet weak var doneButton: UIButton!

    /// The view model responsible for handling the habit. It might edit or create habits, as well as return the
    /// properties of the habit for displaying.
    var habitHandlerViewModel: HabitHandlerViewModelContract!

    /// The color to be used as the theme one in case the user hasn't selected any.
    let defaultThemeColor = UIColor(red: 47/255, green: 54/255, blue: 64/255, alpha: 1)

    /// The notification manager used to get the app's authorization status.
    var notificationManager: UserNotificationManager!

    /// Flag indicating if notifications are authorized or not.
    var areNotificationsAuthorized: Bool = true

    // MARK: Deinitializers

    deinit {
        stopObserving()
    }

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(habitHandlerViewModel != nil, "The habit handler view model must be injected.")
        assert(notificationManager != nil, "Error: failed to inject the notification manager.")

        habitHandlerViewModel.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180

        // Observe the app's active event to display if the user notifications are allowed.
        startObserving()

        // Configure the appearance of the navigation bar to never use the large titles.
        navigationItem.largeTitleDisplayMode = .never

        if habitHandlerViewModel.isEditing {
            title = NSLocalizedString("Edit habit", comment: "Title of the edition controller.")
            configureDeletionButton()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Display information about the authorization status.
        displayNotificationAvailability()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Declare the theme color to be passed to the controllers.
        let themeColor = habitHandlerViewModel.getHabitColor()?.uiColor ?? defaultThemeColor

        switch segue.identifier {
        case Constants.SegueIds.daysSelection:
            // Associate the DaysSelectionController's delegate.
            if let daysController = segue.destination as? HabitDaysSelectionViewController {
                daysController.delegate = self
                daysController.preSelectedDays = habitHandlerViewModel.getSelectedDays()
                daysController.themeColor = themeColor
            } else {
                assertionFailure("Error: Couldn't get the days selection controller.")
            }
        case Constants.SegueIds.fireTimesSelection:
            // Associate the NotificationsSelectionController's delegate.
            if let fireTimesSelectionController = segue.destination as? FireTimesSelectionViewController {
                fireTimesSelectionController.delegate = self
                fireTimesSelectionController.container = habitHandlerViewModel.container
                fireTimesSelectionController.fireTimesStorage = FireTimeStorage()

                if let fireTimes = habitHandlerViewModel.getFireTimeComponents() {
                    fireTimesSelectionController.selectedFireTimeComponents = Set(fireTimes)
                }
                fireTimesSelectionController.themeColor = themeColor
            } else {
                assertionFailure("Error: Couldn't get the fire dates selection controller.")
            }
        default:
            break
        }
    }

    // MARK: Actions

    /// Creates the habit.
    @IBAction func storeHabit(_ sender: UIButton) {
        habitHandlerViewModel.saveHabit()
        navigationController?.popViewController(
            animated: true
        )
    }

    /// Displays the deletion alert.
    @objc private func deleteHabit(sender: UIBarButtonItem) {
        // Alert the user to see if the deletion is really wanted:
        // Declare the alert.
        let alert = UIAlertController(
            title: NSLocalizedString(
                "Delete",
                comment: "Title of the alert displayed when the user wants to delete a habit."
            ),
            message: NSLocalizedString(
                "Are you sure you want to delete this habit? Deleting this habit will also delete its history.",
                comment: "Message of the alert displayed when the user wants to delete a habit."
            ),
            preferredStyle: .alert
        )
        // Declare its actions.
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Delete", comment: "Destructive action."),
                style: .destructive
            ) { _ in
                // Remove the shortcut associated with the habit.
                self.habitHandlerViewModel.deleteHabit()
                self.navigationController?.popToRootViewController(animated: true)
            }
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default))

        // Present it.
        present(alert, animated: true)
    }

    // MARK: Imperatives

    /// Enables or disables the button depending on the habit's filled data.
    func configureDoneButton() {
        if habitHandlerViewModel.isEditing {
            doneButton.setTitle(NSLocalizedString("Edit", comment: "Title of the edition button."), for: .normal)
        }
        doneButton.isEnabled = habitHandlerViewModel.isValid
        doneButton.backgroundColor = habitHandlerViewModel.getHabitColor()?.uiColor ?? defaultThemeColor
    }

    /// Configures and displays the deletion nav bar button.
    private func configureDeletionButton() {
        let trashButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteHabit(sender:))
        )
        trashButton.tintColor = .red
        navigationItem.setRightBarButton(trashButton, animated: false)
    }
}

extension HabitCreationTableViewController {

    // MARK: TableView data source methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.Fields.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = Constants.Fields(rawValue: indexPath.row)!
        var cell = tableView.dequeueReusableCell(withIdentifier: field.getAssociatedCellIdentifier(), for: indexPath)

        switch field {
        case .name:
            if let nameFieldCell = cell as? HabitNameFieldTableViewCell {
                configureNameFieldCell(nameFieldCell)
            } else {
                assertionFailure("Couldn't get the name field table view cell.")
            }
        case .color:
            if let colorFieldCell = cell as? HabitColorFieldTableViewCell {
                configureColorFieldCell(colorFieldCell)
            } else {
                assertionFailure("Couldn't get the color field table view cell.")
            }
        case .challenge:
            if let challengeFieldCell = cell as? HabitChallengeFieldTableViewCell {
                configureChallengeFieldCell(challengeFieldCell)
            } else {
                assertionFailure("Couldn't get the challenge field table view cell.")
            }
        case .fireTimes:
            // Display a cell indicating if notifications are authorized or not.
            if areNotificationsAuthorized {
                if let fireTimesFieldCell = cell as? HabitFireTimesFieldTableViewCell {
                    configureFireTimesFieldCell(fireTimesFieldCell)
                } else {
                    assertionFailure("Couldn't get the fire times field table view cell.")
                }
            } else {
                cell = tableView.dequeueReusableCell(
                    withIdentifier: "notifications not authorized reuse identifier",
                    for: indexPath
                )
                cell.isUserInteractionEnabled = false
            }
        }

        return cell
    }

    // MARK: TableView delegate methods

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: Imperatives

    /// Configures the name field for display.
    /// - Parameter nameFieldCell: The cell for the name field.
    private func configureNameFieldCell(_ cell: HabitNameFieldTableViewCell) {
        cell.isRequired = habitHandlerViewModel.isEditing
        cell.nameTextField.text = habitHandlerViewModel.getHabitName() ?? ""
        cell.nameChangeHandler = { [weak self] name in
            self?.habitHandlerViewModel.setHabitName(name)
            self?.configureDoneButton()
        }
    }

    /// Configures the color field for display.
    /// - Parameter colorFieldCell: The cell for the color field.
    private func configureColorFieldCell(_ cell: HabitColorFieldTableViewCell) {
        cell.isRequired = habitHandlerViewModel.isEditing
        cell.colorPicker.colorsToDisplay = Array(HabitMO.Color.uiColors.values)
        cell.selectedColor = habitHandlerViewModel.getHabitColor()?.uiColor
        cell.colorChangeHandler = { [weak self] color in
            self?.habitHandlerViewModel.setHabitColor(HabitMO.Color.getInstanceFrom(color: color)!)
            // Relaod the challenge and fire times fields to display the selected color.
            self?.tableView.reloadRows(
                at: [IndexPath(row: Constants.Fields.challenge.rawValue, section: 0),
                     IndexPath(row: Constants.Fields.fireTimes.rawValue, section: 0)],
                with: .automatic
            )
            self?.configureDoneButton()
        }
    }

    /// Configures the challenge field for display.
    /// - Parameter challengeFieldCell: The cell for the challenge field.
    private func configureChallengeFieldCell(_ cell: HabitChallengeFieldTableViewCell) {
        if habitHandlerViewModel.isEditing {
            cell.titleLabel.text = NSLocalizedString(
                "New challenge of days",
                comment: "Text of the title of the days field in the edition controller."
            )
            cell.infoLabel.text = NSLocalizedString(
                "Would you like to begin a new challenge of days?",
                comment: "Description of the days field in the edition controller."
            )
        }
        cell.daysCountLabel.text = habitHandlerViewModel.getDaysDescriptionText()
        cell.fromDateLabel.text = habitHandlerViewModel.getFirstDateDescriptionText() ?? "--"
        cell.toDateLabel.text = habitHandlerViewModel.getLastDateDescriptionText() ?? "--"
        cell.themeColor = habitHandlerViewModel.getHabitColor()?.uiColor ?? defaultThemeColor
    }

    /// Configures the fire times field for display.
    /// - Parameter fireTimesFieldCell: The cell for the fire times field.
    private func configureFireTimesFieldCell(_ cell: HabitFireTimesFieldTableViewCell) {
        cell.fireTimesAmountLabel.text = habitHandlerViewModel.getFireTimesAmountDescriptionText()
        cell.fireTimesLabel.text = habitHandlerViewModel.getFireTimesDescriptionText()
        cell.themeColor = habitHandlerViewModel.getHabitColor()?.uiColor ?? defaultThemeColor
    }
}

extension HabitCreationTableViewController:
FireTimesSelectionViewControllerDelegate, HabitDaysSelectionViewControllerDelegate {

    // MARK: HabitNotificationsSelectionViewControllerDelegate Delegate Methods

    func didSelectFireTimes(_ fireTimes: [FireTimesDisplayable.FireTime]) {
        habitHandlerViewModel.setSelectedFireTimes(fireTimes)
        tableView.reloadData()
        configureDoneButton()
    }

    // MARK: HabitDaysSelectionViewController Delegate Methods

    func didSelectDays(_ daysDates: [Date]) {
        habitHandlerViewModel.setDays(daysDates)
        tableView.reloadData()
        configureDoneButton()
    }
}

extension HabitCreationTableViewController: NotificationAvailabilityDisplayable {

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActivationEvent(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc func handleActivationEvent(_ notification: Notification) {
        displayNotificationAvailability()
    }

    func displayNotificationAvailability() {
        notificationManager.getAuthorizationStatus { [weak self] isAuthorized in
            DispatchQueue.main.async {
                self?.areNotificationsAuthorized = isAuthorized
                self?.tableView.reloadData()
            }
        }
    }
}

extension HabitCreationTableViewController: HabitHandlingViewModelDelegate {
    func didReceiveSaveError(_ error: Error) {
        let alertController = UIAlertController.make(
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString(
                "There was an error while the habit was being persisted. Please contact the developer.",
                comment: "Message of the alert displayed when the habit couldn't be persisted."
            )
        )
        self.present(alertController, animated: true)
        assertionFailure("Error: Couldn't save the new habit entity.")
    }
}
