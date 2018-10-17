//
//  HabitCreationTableViewController+ColorField.swift
//  Active
//
//  Created by Tiago Maia Lopes on 24/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds the code to manage the colors field.
extension HabitCreationTableViewController {

    // MARK: Imperatives

    /// Applies the selected theme color to the controller's fields.
    func displayThemeColor() {
        let themeColor = habitColor?.uiColor ?? defaultThemeColor
        // Set the theme color of:
        // the days field.
        let daysFieldColor = ((days?.isEmpty ?? true) && habit == nil) ? UIColor.red : themeColor
        daysAmountLabel.textColor = daysFieldColor
        fromDayLabel.textColor = daysFieldColor
        toDayLabel.textColor = daysFieldColor

        // the Notifications field.
        fireTimesAmountLabel.textColor = themeColor
        fireTimesLabel.textColor = themeColor

        // the done button.
        doneButton.backgroundColor = themeColor
    }

    /// Configures the colors to be diplayed by the color picker view.
    func configureColorField() {
        // Set the field's title to show it isn't required in case of edition.
        if habit != nil {
            colorFieldTitleLabel.text = NSLocalizedString("Color", comment: "The title of the color field.")
        }

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
}
