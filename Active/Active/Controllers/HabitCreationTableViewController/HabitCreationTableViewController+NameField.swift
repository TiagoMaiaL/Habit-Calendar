//
//  HabitCreationTableViewController+NameField.swift
//  Active
//
//  Created by Tiago Maia Lopes on 24/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds the code to manage the name field.
extension HabitCreationTableViewController {

    // MARK: Imperatives

    /// Finishes editing the name's textField.
    @objc func endNameEdition() {
        nameTextField.resignFirstResponder()
    }

    /// Listens to the change events emmited the name text field.
    /// - Paramter textField: The textField being editted.
    @objc func nameChanged(textField: UITextField) {
        // Associate the name with the field's text.
        name = textField.text
    }

    /// Creates and configures a new UIToolbar with a done button to be
    /// used as the name field's accessoryView.
    /// - Returns: An UIToolbar.
    func makeToolbar() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.setItems(
            [UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(endNameEdition))],
            animated: false
        )

        return toolBar
    }
}
