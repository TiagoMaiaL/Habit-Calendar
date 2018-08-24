//
//  HabitCreationViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

/// Controller used to allow the user to create/edit habits.
class HabitCreationTableViewController: UITableViewController {

    // MARK: Properties

    /// The segue identifier for the DaysSelection controller.
    private let daysSelectionSegue = "Show days selection controller"

    /// The segue identifier for the NotificationsSelection controller.
    private let notificationSelectionSegue = "Show fire dates selection controller"

    /// The text field used to give the habit a name.
    @IBOutlet weak var nameTextField: UITextField!

    /// The button used to store the habit.
    @IBOutlet weak var doneButton: UIButton!

    /// The label displaying the number of selected days.
    @IBOutlet weak var daysAmountLabel: UILabel!

    /// The label displaying the first day in the selected sequence.
    @IBOutlet weak var fromDayLabel: UILabel!

    /// The label displaying the last day in the selected sequence.
    @IBOutlet weak var toDayLabel: UILabel!

    /// The label displaying the amount of fire times selected.
    @IBOutlet weak var fireTimesAmountLabel: UILabel!

    /// The label displaying the of fire time times selected.
    @IBOutlet weak var selectedFireTimesLabel: UILabel!

    /// The color's field color picker view.
    @IBOutlet weak var colorPicker: ColorsPickerView!

    /// The container in which the habit is going to be persisted.
    var container: NSPersistentContainer!

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
    var fireTimes: [FireTimesSelectionViewController.FireTime]?

    // TODO: Show a cell indicating the user hasn't enabled local notifications.

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Assert on the values of the injected dependencies (implicitly unwrapped).
        assert(container != nil, "Error: failed to inject the persistent container.")
        assert(habitStore != nil, "Error: failed to inject the habit store")

        // Configure the appearance of the navigation bar to never use the
        // large titles.
        navigationItem.largeTitleDisplayMode = .never

        // Associate the event listener to the textField.
        nameTextField.addTarget(
            self,
            action: #selector(nameChanged(textField:)),
            for: .editingChanged
        )
        // Create a toolbar and add it as the field's accessory view.
        nameTextField.inputAccessoryView = makeToolbar()

        configureColorPicker()

        // Display the initial text of the days labels.
        configureDaysLabels()

        // Display the initial text of the notifications labels.
        configureFireTimesLabels()

        // Set the done button's initial state.
        configureDoneButton()

        // If there's a passed habit, it means that the controller should edit it.
        if habit != nil {
            displayHabitProperties()
            configureDeletionButton()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Display the theme color.
        displayThemeColor()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Declare the theme color to be passed to the controllers.
        let themeColor = self.habitColor?.getColor() ?? defaultThemeColor

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
                notificationsController.notificationManager = UserNotificationManager(
                    notificationCenter: UNUserNotificationCenter.current()
                )
                if let fireTimes = fireTimes {
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
        assert(!(name ?? "").isEmpty, "Error: the habit's name must be a valid value.")
        assert(habitColor != nil, "Error: the habit's color must be a valid value.")
        assert(!(days ?? []).isEmpty, "Error: the habit's days must have a valid value.")
        if fireTimes != nil {
            assert(fireTimes!.isEmpty == false, "Error: the habit's fireTimes must have a valid value.")
        }

        // If there's no previous habit, create and persist a new one.
        container.performBackgroundTask { context in
            // Retrieve the app's current user before using it.
            guard let user = self.userStore.getUser(using: context) else {
                // It's a bug if there's no user. The user should be created on
                // the first launch.
                assertionFailure("Inconsistency: There's no user in the database. It must be set.")
                return
            }

            if self.habit == nil {
                _ = self.habitStore.create(
                    using: context,
                    user: user,
                    name: self.name!,
                    color: self.habitColor!,
                    days: self.days!,
                    and: self.fireTimes
                )
            } else {
                // If there's a previous habit, update it with the new values.
                _ = self.habitStore.edit(
                    self.habit!,
                    using: context,
                    name: self.name,
                    days: self.days,
                    and: self.fireTimes
                )
            }

            // TODO: Report any errors to the user.
            do {
                try context.save()
            } catch {
                assertionFailure("Error: Couldn't save the new habit entity.")
            }
        }

        navigationController?.popViewController(
            animated: true
        )
    }

    /// Displays the deletion alert.
    @objc private func deleteHabit(sender: UIBarButtonItem) {
        // Alert the user to see if the deletion is really wanted:
        // Declare the alert.
        let alert = UIAlertController(
            title: "Delete",
            message: """
Are you sure you want to delete this habit? Deleting this habit makes all the history \
information unavailable.
""",
            preferredStyle: .alert
        )
        // Declare its actions.
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            // If so, delete the habit using the container's viewContext.
            // Pop the current controller.
            self.habitStore.delete(self.habit!, from: self.container.viewContext)
            self.navigationController?.popToRootViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))

        // Present it.
        present(alert, animated: true)
    }

    // MARK: Imperatives

    /// Enables or disables the button depending on the habit's filled data.
    private func configureDoneButton() {
        if let habitToEdit = habit {
            // Change the button's title if there's a habit to be editted.
            doneButton.setTitle("Edit", for: .normal)

            // Check if anything changed.
            let isNameDifferent = !(name ?? "").isEmpty && name != habitToEdit.name
            // TODO: Add method to get the enum color from the entity.
            let isColorDifferent = habitColor != nil && habitColor != HabitMO.Color(rawValue: habitToEdit.color)
            let isChallengeDifferent = days != nil && !days!.isEmpty
            let areFireTimesDifferent = fireTimes != nil && !fireTimes!.isEmpty

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
        habitColor = HabitMO.Color(rawValue: habit!.color)
        colorPicker.selectedColor = habitColor!.getColor()

        // Display the habit's current days' challenge.

        // Display the habit's fire times.
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

    // MARK: types

    /// The fields used for creating a new habit.
    private enum Field: Int {
        case name = 0,
            color,
            days,
            fireTimes
    }

    // MARK: TableView delegate methods

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let field = Field(rawValue: indexPath.row) {
            switch field {
            case .name:
                return 130
            case .color:
                // Compute the expected height for the color picker field.
                let marginsValue: CGFloat = 20
                let titleExpectedHeight: CGFloat = 40
                let stackVerticalSpace: CGFloat = 10

                return marginsValue + titleExpectedHeight + stackVerticalSpace + colorPicker.getExpectedHeight()
            case .days:
                return 160
            case .fireTimes:
                return 172
            }
        } else {
            return 0
        }
    }
}
