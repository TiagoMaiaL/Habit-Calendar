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
    private let notificationSelectionSegue = "Show fire dates selection controller"

    /// The label displaying the name field's title.
    @IBOutlet weak var nameFieldTitleLabel: UILabel!

    /// The text field used to give the habit a name.
    @IBOutlet weak var nameTextField: UITextField!

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

    /// The stack view containing the fire times labels.
    @IBOutlet weak var fireTimesContainer: UIStackView!

    /// The label displaying the amount of fire times selected.
    @IBOutlet weak var fireTimesAmountLabel: UILabel!

    /// The label displaying the of fire time times selected.
    @IBOutlet weak var fireTimesLabel: UILabel!

    /// The label displaying the color field's title.
    @IBOutlet weak var colorFieldTitleLabel: UILabel!

    /// The color's field color picker view.
    @IBOutlet weak var colorPicker: ColorsPickerView!

    /// The container showing that the user hasn't enabled user notifications.
    @IBOutlet weak var notAuthorizedContainer: UIStackView!

    /// The labels indicating that the associated fields are required.
    @IBOutlet var requiredLabelMarkers: [UILabel]!

    /// The container in which the habit is going to be persisted.
    var container: NSPersistentContainer!

    /// The shortcuts manager used to add a new shortcut when a habit gets added or edited.
    /// - Note: The manager is used by this controller to add a shortcut every time a habit is created or edited, and
    ///         to remove one when the habit is deleted.
    var shortcutsManager: HabitsShortcutItemsManager!

    /// The habit storage used for this controller to
    /// create/edit the habit.
    var habitStore: HabitStorage!

    /// The user storage used to associate the main user
    /// to any created habits.
    var userStore: UserStorage!

    /// The habit entity being editted.
    var habit: HabitMO?

    /// The habit's name being informed by the user.
    var name: String? {
        didSet {
            // Update the button state.
            configureDoneButton()
        }
    }

    /// The color to be used as the theme one in case the user hasn't selected any.
    let defaultThemeColor = UIColor(red: 47/255, green: 54/255, blue: 64/255, alpha: 1)

    /// The habit's color selected by the user.
    var habitColor: HabitMO.Color? {
        didSet {
            displayThemeColor()
            // Update the button state.
            configureDoneButton()
        }
    }

    /// The habit's days the user has selected.
    var days: [Date]? {
        didSet {
            configureDaysLabels()
            // Update the button state.
            configureDoneButton()
        }
    }

    /// The habit's notification fire times the user has selected.
    var fireTimes: [FireTimesDisplayable.FireTime]? {
        didSet {
            // Update the button state.
            configureDoneButton()
        }
    }

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

        // Assert on the values of the injected dependencies (implicitly unwrapped).
        assert(userStore != nil, "Error: Failed to inject the user store.")
        assert(container != nil, "Error: failed to inject the persistent container.")
        assert(habitStore != nil, "Error: failed to inject the habit store.")
        assert(notificationManager != nil, "Error: failed to inject the notification manager.")
        assert(shortcutsManager != nil, "Error: The shortcuts manager must be injected.")

        // Observe the app's active event to display if the user notifications are allowed.
        startObserving()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180

        // Configure the appearance of the navigation bar to never use the
        // large titles.
        navigationItem.largeTitleDisplayMode = .never

        configureNameField()
        configureColorField()

        // Display the initial text of the days labels.
        configureDaysLabels()

        // Display the initial text of the notifications labels.
        displayFireTimes(fireTimes ?? [])

        // Set the done button's initial state.
        configureDoneButton()

        // If there's a passed habit, it means that the controller should edit it.
        if isEditingHabit {
            title = NSLocalizedString("Edit habit", comment: "Title of the edition controller.")
            displayHabitProperties()
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

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Declare the theme color to be passed to the controllers.
        let themeColor = self.habitColor?.uiColor ?? defaultThemeColor

        switch segue.identifier {
        case daysSelectionSegue:
            // Associate the DaysSelectionController's delegate.
            if let daysController = segue.destination as? HabitDaysSelectionViewController {
                daysController.delegate = self
                daysController.preSelectedDays = days
                daysController.themeColor = themeColor
            } else {
                assertionFailure("Error: Couldn't get the days selection controller.")
            }

        case notificationSelectionSegue:
            // Associate the NotificationsSelectionController's delegate.
            if let notificationsController = segue.destination as? FireTimesSelectionViewController {
                notificationsController.delegate = self

                if let fireTimes = fireTimes {
                    notificationsController.selectedFireTimes = Set(fireTimes)
                } else if let fireTimes = (habit?.fireTimes as? Set<FireTimeMO>)?.map({ $0.getFireTimeComponents() }) {
                    // In case the habit is being editted and has some fire times to be displayed.
                    notificationsController.selectedFireTimes = Set(fireTimes)
                }
                notificationsController.themeColor = themeColor
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
        // Make assertions on the required values to create/update a habit.
        // If the habit is being created, make the assertions.
        if !isEditingHabit {
            assert(!(name ?? "").isEmpty, "Error: the habit's name must be a valid value.")
            assert(habitColor != nil, "Error: the habit's color must be a valid value.")
            assert(!(days ?? []).isEmpty, "Error: the habit's days must have a valid value.")
        }

        handleHabitForPersistency()

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
                self.shortcutsManager.removeApplicationShortcut(for: self.habit!)
                self.habitStore.delete(self.habit!, from: self.container.viewContext)
                self.navigationController?.popToRootViewController(animated: true)
            }
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default))

        // Present it.
        present(alert, animated: true)
    }

    // MARK: Imperatives

    /// Enables or disables the button depending on the habit's filled data.
    private func configureDoneButton() {
        if let habitToEdit = habit {
            // Change the button's title if there's a habit to be editted.
            doneButton.setTitle(NSLocalizedString("Edit", comment: "Title of the edition button."), for: .normal)

            // Check if anything changed.
            let isNameDifferent = !(name ?? "").isEmpty && name != habitToEdit.name
            let isColorDifferent = habitColor != nil && habitColor != habitToEdit.getColor()
            let isChallengeDifferent = days != nil && !days!.isEmpty
            let areFireTimesDifferent = fireTimes != nil

            doneButton.isEnabled = isNameDifferent || isColorDifferent || isChallengeDifferent || areFireTimesDifferent
        } else {
            // Check if the name and days are correctly set.
            doneButton.isEnabled = !(name ?? "").isEmpty && !(days ?? []).isEmpty && habitColor != nil
        }
    }

    /// Display the provided habit's data for edittion.
    private func displayHabitProperties() {
        // Display the habit's name.
        nameTextField.text = habit!.name

        // Display the habit's color.
        habitColor = habit!.getColor()
        colorPicker.selectedColor = habitColor!.uiColor

        // Display the habit's current days' challenge.

        // Display the habit's fire times.
        if habit!.fireTimes!.count > 0 {
            guard let fireTimesSet = habit?.fireTimes as? Set<FireTimeMO> else {
                assertionFailure("Error: couldn't get the FireTimeMO entities.")
                return
            }
            displayFireTimes(fireTimesSet.map { $0.getFireTimeComponents() })
        }
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
