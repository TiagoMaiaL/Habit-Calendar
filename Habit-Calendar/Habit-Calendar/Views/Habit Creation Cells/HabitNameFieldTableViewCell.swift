//
//  HabitNameFieldTableViewCell.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 13/12/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// This table view cell displays a field used to inform the names of new habits.
class HabitNameFieldTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The text field used to inform the habit name.
    @IBOutlet var nameTextField: UnderlinedTextField!

    /// The label displaying the title of the field.
    @IBOutlet var fieldTitleLabel: UILabel!

    /// The label displaying if the field is required or not.
    @IBOutlet var requiredIndicatorLabel: UILabel!

    /// The label displaying some information about this field.
    @IBOutlet var fieldInfoLabel: UILabel!

    /// Flag indicating if this field is required or not.
    var isRequired = true {
        didSet {
            requiredIndicatorLabel.isHidden = !isRequired
        }
    }

    /// The closure called every time the name text field is edited.
    var nameChangeHandler: ((String) -> Void)?

    // MARK: Life Cycle

    override func prepareForReuse() {
        nameTextField.text = ""
        isRequired = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if nameTextField.inputAccessoryView == nil {
            nameTextField.inputAccessoryView = makeToolbar()
        }
    }

    // MARK: Actions

    /// Finishes editing the name's textField.
    @objc private func endNameEdition() {
        nameTextField.resignFirstResponder()
    }

    /// Listens to the change events emmited by the name text field.
    /// - Paramter textField: The textField being edited.
    @IBAction func informNameChanged(_ sender: UnderlinedTextField) {
        nameChangeHandler?(sender.text ?? "")
    }

    // MARK: Imperatives

    /// Creates and configures a new UIToolbar with a done button to be
    /// used as the name field's accessoryView.
    /// - Returns: An UIToolbar.
    private func makeToolbar() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.setItems(
            [UIBarButtonItem(
                title: NSLocalizedString("Done", comment: "The title of the toolbar button."),
                style: .done,
                target: self,
                action: #selector(endNameEdition)
                )],
            animated: false
        )

        return toolBar
    }
}
