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
class HabitCreationTableViewController: UITableViewController,
    HabitDaysSelectionViewControllerDelegate,
    FireTimesSelectionViewControllerDelegate {

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
    private var name: String? {
        didSet {
            // Update the button state.
            configureCreationButton()
        }
    }

    /// The color to be used as the theme one in case the user hasn't selected any.
    private let defaultThemeColor = UIColor(
        red: 47/255,
        green: 54/255,
        blue: 64/255,
        alpha: 1
    )

    /// The habit's color selected by the user.
    private var habitColor: HabitMO.Color? {
        didSet {
            displayThemeColor()
            // Update the button state.
            configureCreationButton()
        }
    }

    /// The habit's days the user has selected.
    private var days: [Date]? {
        didSet {
            configureDaysLabels()
            // Update the button state.
            configureCreationButton()
        }
    }

    /// The habit's notification fire times the user has selected.
    private var fireTimes: [FireTimesSelectionViewController.FireTime]?

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
        configureCreationButton()
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

    /// Finishes editing the name's textField.
    @objc private func endNameEdition() {
        nameTextField.resignFirstResponder()
    }

    // MARK: Imperatives

    /// Listens to the change events emmited the name text field.
    /// - Paramter textField: The textField being editted.
    @objc private func nameChanged(textField: UITextField) {
        // Associate the name with the field's text.
        name = textField.text
    }

    /// Applies the selected theme color to the controller's fields.
    private func displayThemeColor() {
        let themeColor = habitColor?.getColor() ?? defaultThemeColor
        // Set the theme color of:
        // the days field.
        let daysFieldColor = (days?.isEmpty ?? true) ? UIColor.red : themeColor
        daysAmountLabel.textColor = daysFieldColor
        fromDayLabel.textColor = daysFieldColor
        toDayLabel.textColor = daysFieldColor

        // the Notifications field.
        let notificationsFieldColor = (fireTimes?.isEmpty ?? true) ? UIColor.red : themeColor
        fireTimesAmountLabel.textColor = notificationsFieldColor
        selectedFireTimesLabel.textColor = notificationsFieldColor

        // the done button.
        doneButton.backgroundColor = themeColor
    }

    /// Enables or disables the button depending on the habit's filled data.
    private func configureCreationButton() {
        // Check if the name and days are correctly set.
        doneButton.isEnabled = !(name ?? "").isEmpty && !(days ?? []).isEmpty && habitColor != nil
    }

    /// Configures the colors to be diplayed by the color picker view.
    private func configureColorPicker() {
        // Set the color change handler.
        colorPicker.colorChangeHandler = { uiColor in
            // Associate the selected color.
            self.habitColor = HabitMO.Color.getInstanceFrom(color: uiColor)
        }
        // Get the possible colors to be displayed.
        let possibleColors = Array(HabitMO.Color.uiColors.values)
        // Pass the to the picker.
        colorPicker.colorsToDisplay = possibleColors
    }

    /// Configures the text being displayed by each label within the days
    /// field.
    private func configureDaysLabels() {
        if let days = days?.sorted(), !days.isEmpty {
            let formatter = DateFormatter.shortCurrent
            // Set the text for the label displaying the number of days.
            daysAmountLabel.text = "\(days.count) day\(days.count == 1 ? "" : "s") selected."
            // Set the text for the label displaying initial day in the sequence.
            fromDayLabel.text = formatter.string(from: days.first!)
            // Set the text for the label displaying final day in the sequence.
            toDayLabel.text = formatter.string(from: days.last!)
        } else {
            daysAmountLabel.text = "No days were selected."
            fromDayLabel.text = "--"
            toDayLabel.text = "--"
        }
    }

    /// Configures the text being displayed by each label within
    /// the notifications field.
    private func configureFireTimesLabels() {
        if let fireTimes = fireTimes, !fireTimes.isEmpty {
            // Set the text for the label displaying the amount of fire times.
            fireTimesAmountLabel.text = "\(fireTimes.count) fire time\(fireTimes.count == 1 ? "" : "s") selected."

            // Set the text for the label displaying some of the
            // selected fire times:
            let fireTimeFormatter = DateFormatter.makeFireTimeDateFormatter()
            let fireDates = fireTimes.compactMap {
                Calendar.current.date(from: $0)
            }.sorted()
            var fireTimesText = ""

            for fireDate in fireDates {
                fireTimesText += fireTimeFormatter.string(from: fireDate)

                // If the current fire time isn't the last one,
                // include a colon to separate it from the next.
                if fireDates.index(of: fireDate)! != fireDates.endIndex - 1 {
                    fireTimesText += ", "
                }
            }

            selectedFireTimesLabel.text = fireTimesText
        } else {
            fireTimesAmountLabel.text = "No fire times selected."
            selectedFireTimesLabel.text = "--"
        }
    }

    /// Creates and configures a new UIToolbar with a done button to be
    /// used as the name field's accessoryView.
    /// - Returns: An UIToolbar.
    private func makeToolbar() -> UIToolbar {
        let toolBar = UIToolbar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.size.width,
                height: 50
            )
        )
        toolBar.setItems(
            [
                UIBarButtonItem(
                    title: "Done",
                    style: .done,
                    target: self,
                    action: #selector(endNameEdition)
                )
            ],
            animated: false
        )

        return toolBar
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

extension HabitCreationTableViewController {

    // MARK: HabitDaysSelectionViewController Delegate Methods

    func didSelectDays(_ daysDates: [Date]) {
        // Associate the habit's days with the dates selected by the user.
        days = daysDates
    }
}

extension HabitCreationTableViewController {

    // MARK: HabitNotificationsSelectionViewControllerDelegate Delegate Methods

    func didSelectFireTimes(_ fireTimes: [FireTimesSelectionViewController.FireTime]) {
        // Associate the selected fire times.
        self.fireTimes = fireTimes
        // Change the labels to display the selected fire times.
        configureFireTimesLabels()
    }
}
