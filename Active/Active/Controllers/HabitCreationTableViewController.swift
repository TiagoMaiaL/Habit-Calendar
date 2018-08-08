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
            configureCreationButton()
        }
    }

    /// The habit's days the user has selected.
    // For now only one day is going to be added.
    private var days: [Date]? {
        didSet {
            configureCreationButton()
        }
    }

    /// The habit's notification times the user has chosen.
    private var selectedNotificationFireTimes: [FireTimesSelectionViewController.FireTime]?

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

        // Display the initial text of the days labels.
        configureDaysLabels()

        // Display the initial text of the notifications labels.
        configureFireTimesLabels()

        // Set the done button's initial state.
        configureCreationButton()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case daysSelectionSegue:
            // Associate the DaysSelectionController's delegate.
            if let daysController = segue.destination as? HabitDaysSelectionViewController {
                daysController.delegate = self
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
                if let fireTimes = selectedNotificationFireTimes {
                    notificationsController.selectedFireTimes = Set(fireTimes)
                }
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
                    color: HabitMO.Color.emerald, // TODO: Use a real enum value.
                    days: self.days!,
                    and: self.selectedNotificationFireTimes
                )
            } else {
                // If there's a previous habit, update it with the new values.
                _ = self.habitStore.edit(
                    self.habit!,
                    using: context,
                    name: self.name,
                    days: self.days,
                    and: self.selectedNotificationFireTimes
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

    /// Enables or disables the button depending on the habit's filled data.
    private func configureCreationButton() {
        // Check if the name and days are correctly set.
        doneButton.isEnabled = !(name ?? "").isEmpty && !(days ?? []).isEmpty
    }

    /// Configures the text being displayed by each label within the days
    /// field.
    private func configureDaysLabels() {
        if let days = days?.sorted(), !days.isEmpty {
            let dayFormatter = ISO8601DateFormatter()
            dayFormatter.formatOptions = [
                .withDashSeparatorInDate,
                .withYear,
                .withMonth,
                .withDay
            ]

            // Set the text for the label displaying the number of days.
            daysAmountLabel.text = "\(days.count) day\(days.count == 1 ? "" : "s") selected."
            // Set the text for the label displaying initial day in the sequence.
            fromDayLabel.text = dayFormatter.string(from: days.first!)
            // Set the text for the label displaying final day in the sequence.
            toDayLabel.text = dayFormatter.string(from: days.last!)
        } else {
            daysAmountLabel.text = "No days were selected."
            fromDayLabel.text = "--"
            toDayLabel.text = "--"
        }
    }

    /// Configures the text being displayed by each label within
    /// the notifications field.
    private func configureFireTimesLabels() {
        if let fireTimes = selectedNotificationFireTimes, !fireTimes.isEmpty {
            // Set the text for the label displaying the amount of fire times.
            fireTimesAmountLabel.text = "\(fireTimes.count) fire time\(fireTimes.count == 1 ? "" : "s") selected."

            // Set the text for the label displaying some of the
            // selected fire times:
            let fireTimeFormatter = DateFormatter.makeFireTimeDateFormatter()
            let fireDates = fireTimes.compactMap {
                return Calendar.current.date(from: $0)
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

    // MARK: HabitDaysSelectionViewController Delegate Methods

    func didSelectDays(_ daysDates: [Date]) {
        // Associate the habit's days with the dates selected by the user.
        days = daysDates
        // Change the days labels to display the current sequence info.
        configureDaysLabels()
    }
}

extension HabitCreationTableViewController {

    // MARK: HabitNotificationsSelectionViewControllerDelegate Delegate Methods

    func didSelectFireTimes(_ fireTimes: [FireTimesSelectionViewController.FireTime]) {
        // Associate the habit's fire dates with the fireDates selected by
        // the user.
        selectedNotificationFireTimes = fireTimes
        // Change the labels to display the selected fire times.
        configureFireTimesLabels()
    }
}

/// Extension that adds UIColor capabilities to the Color model enum.
extension HabitMO.Color {

    /// Gets the UIColor representing the current enum instance.
    /// - Returns: The UIColor associated with the instance.
    func getColor() -> UIColor {
        guard let color = HabitMO.Color.colors[self] else {
            assertionFailure("Error: the current instance doesn't have a valid color associated with it.")
            return .black
        }
        return color
    }

    /// The UIColors associated with each enum constant.
    private static let colors = [
        midnightBlue: UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1),
        amethyst: UIColor(red: 155/255, green: 89/255, blue: 182/255, alpha: 1),
        pomegranate: UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1),
        alizarin: UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1),
        carrot: UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1),
        orange: UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1),
        blue: UIColor(red: 0/255, green: 168/255, blue: 255/255, alpha: 1.0),
        peterRiver: UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1),
        belizeRole: UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1),
        turquoise: UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1),
        emerald: UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
    ]
}
