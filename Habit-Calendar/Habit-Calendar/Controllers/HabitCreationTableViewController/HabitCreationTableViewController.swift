//
//  HabitCreationViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

/// Controller used to allow the user to create/edit habits.
class HabitCreationTableViewController: UITableViewController {

    // MARK: Properties

    /// The segue identifier for the DaysSelection controller.
    private let daysSelectionSegue = "Show days selection controller"

    /// The segue identifier for the NotificationsSelection controller.
    private let fireTimesSelectionSegue = "Show fire dates selection controller"

    /// The button used to store the habit.
    @IBOutlet weak var doneButton: UIButton!

    /// The label displaying the number of selected days.
    @IBOutlet weak var daysAmountLabel: UILabel!

    /// The title label of the days' challenge field.
    @IBOutlet weak var challengeFieldTitleLabel: UILabel!

    /// The question label of the days' challenge field.
    @IBOutlet weak var challengeFieldQuestionTitle: UILabel!

    /// The label displaying the first day in the selected sequence.
    @IBOutlet weak var fromDayLabel: UILabel!

    /// The label displaying the last day in the selected sequence.
    @IBOutlet weak var toDayLabel: UILabel!

    /// The fire times table view cell.
    @IBOutlet weak var fireTimesCell: UITableViewCell!

    /// The stack view containing the fire times labels.
    @IBOutlet weak var fireTimesContainer: UIStackView!

    /// The label displaying the amount of fire times selected.
    @IBOutlet weak var fireTimesAmountLabel: UILabel!

    /// The label displaying the of fire time times selected.
    @IBOutlet weak var fireTimesLabel: UILabel!

    /// The container showing that the user hasn't enabled user notifications.
    @IBOutlet weak var notAuthorizedContainer: UIStackView!

    /// The labels indicating that the associated fields are required.
    @IBOutlet var requiredLabelMarkers: [UILabel]!

    /// The view model responsible for handling the habit. It might edit or create habits, as well as return the
    /// properties of the habit for displaying.
    var habitHandlerViewModel: HabitHandlingViewModel!

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

        // Observe the app's active event to display if the user notifications are allowed.
        startObserving()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180

        // Configure the appearance of the navigation bar to never use the large titles.
        navigationItem.largeTitleDisplayMode = .never

        // Configure the initial state of each field.
//        configureNameField()
        configureColorField()
        configureDaysLabels()
        displayFireTimes(habitHandlerViewModel.getFireTimeComponents() ?? [])
        configureDoneButton()

        if habitHandlerViewModel.isEditing {
            title = NSLocalizedString("Edit habit", comment: "Title of the edition controller.")
            configureDeletionButton()
            requiredLabelMarkers.forEach { $0.isHidden = true }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Display the theme color.
        displayThemeColor()

        // Display information about the authorization status.
        displayNotificationAvailability()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Display the selected habit color.
//        if let habitColor = habitHandlerViewModel.getHabitColor() {
//            colorPicker.selectedColor = habitColor.uiColor
//        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Declare the theme color to be passed to the controllers.
        let themeColor = habitHandlerViewModel.getHabitColor()?.uiColor ?? defaultThemeColor

        switch segue.identifier {
        case daysSelectionSegue:
            // Associate the DaysSelectionController's delegate.
            if let daysController = segue.destination as? HabitDaysSelectionViewController {
                daysController.delegate = self
                daysController.preSelectedDays = habitHandlerViewModel.getSelectedDays()
                daysController.themeColor = themeColor
            } else {
                assertionFailure("Error: Couldn't get the days selection controller.")
            }

        case fireTimesSelectionSegue:
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
        // TODO: Report any errors back to the user.
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

    // MARK: TableView delegate methods

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
