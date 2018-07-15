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
class HabitCreationTableViewController: UITableViewController, HabitDaysSelectionViewControllerDelegate, HabitNotificationsSelectionViewControllerDelegate {

    // MARK: Properties
    
    /// The segue identifier for the DaysSelection controller.
    private let daysSelectionSegue = "Show days selection controller"
    
    /// The segue identifier for the NotificationsSelection controller.
    private let notificationSelectionSegue = "Show fire dates selection controller"
    
    /// The text field used to give the habit a name.
    @IBOutlet weak var nameTextField: UITextField!
    
    /// The button used to store the habit.
    @IBOutlet weak var doneButton: UIButton!
    
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
    private var selectedNotificationFireTimes: [Date]?
    
    // TODO: Show a cell indicating the user hasn't enabled local notifications.
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assert on the values of the injected dependencies (implicitly unwrapped).
        assert(container != nil, "Error: failed to inject the persistent container.")
        assert(habitStore != nil, "Error: failed to inject the habit store")
        
        // Associate the event listener to the textField.
        nameTextField.addTarget(
            self,
            action: #selector(nameChanged(textField:)),
            for: .editingChanged
        )
        
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
            if let notificationsController = segue.destination as? HabitNotificationsSelectionViewController {
                notificationsController.delegate = self
                notificationsController.notificationManager = UserNotificationManager(
                    notificationCenter: UNUserNotificationCenter.current()
                )
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
                assertionFailure("Inconsistency: There's no user in the database. It should be set.")
                return
            }
            
            if self.habit == nil {
                _ = self.habitStore.create(
                    using: context,
                    user: user,
                    name: self.name!,
                    color: HabitMO.Color.green, // TODO: Use a real enum value.
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
            try! context.save()
        }
        
        navigationController?.popViewController(
            animated: true
        )
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
    
    func didSelectFireDates(_ fireDates: [Date]) {
        // Associate the habit's fire dates with the fireDates selected by
        // the user.
        selectedNotificationFireTimes = fireDates
    }
}
