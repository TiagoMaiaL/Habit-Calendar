//
//  HabitCreationViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Controller used to allow the user to create/edit habits.
class HabitCreationTableViewController: UITableViewController {

    // MARK: Properties
    
    /// The text field used to give the habit a name.
    @IBOutlet weak var nameTextField: UITextField!
    
    /// The button used to store the habit.
    @IBOutlet weak var doneButton: UIButton!
    
    /// The habit storage used for this controller to
    /// create/edit the habit.
    var habitStorage: HabitStorage!
    
    /// The habit entity being editted.
    var habit: HabitMO?
    
    /// The habit's name being informed by the user.
    private var name: String? {
        didSet {
            // TODO: Update the done button enabled state.
        }
    }
    
    /// The habit's days the user has selected.
    // For now only one day is going to be added.
    private var days: [Date]?
    
    /// The habit's notification time the user has chosen.
    private var notificationFireDate: Date?
    
    // TODO: Declare the used habit's storage.
    
    // TODO: Show a cell indicating the user hasn't
    // enabled local notifications.
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Associate the event listener to the textField.
        nameTextField.addTarget(
            self,
            action: #selector(nameChanged(textField:)),
            for: .editingChanged
        )
        
        // Set the done button's initial state.
        doneButton.isEnabled = false
    }
    
    // MARK: Actions
    
    /// Creates the habit.
    @IBAction func storeHabit(_ sender: UIButton) {
        navigationController?.popViewController(
            animated: true
        )
        
        // TODO: Save the passed habit.
    }
    
    // MARK: Imperatives
    
    /// Listens to the change events emmited the name text field.
    /// - Paramter textField: The textField being editted.
    @objc private func nameChanged(textField: UITextField) {
        // Associate the name with the field's text.
        name = textField.text
    }
}
