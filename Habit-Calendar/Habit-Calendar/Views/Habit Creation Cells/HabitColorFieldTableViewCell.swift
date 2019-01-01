//
//  HabitColorFieldTableViewCell.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 13/12/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// This table view cell displays a field used to choose the color of the habits.
class HabitColorFieldTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The label displaying the title of the field.
    @IBOutlet var titleLabel: UILabel!

    /// The label informing if the field is required or not.
    @IBOutlet var requiredIndicatorLabel: UILabel!

    /// The picker view used to choose the habit color.
    @IBOutlet var colorPicker: ColorsPickerView!

    /// Flag indicating if the field is required or not.
    var isRequired = true {
        didSet {
            requiredIndicatorLabel.isHidden = !isRequired
        }
    }

    /// The handler fired when a color is selected.
    var colorChangeHandler: ((UIColor) -> Void)?

    /// The selected color to be displayed by the picker view.
    var selectedColor: UIColor? {
        didSet {
            if let color = selectedColor {
                colorPicker.selectedColor = color
            }
        }
    }

    // MARK: Life Cycle

    override func prepareForReuse() {
        super.prepareForReuse()

        isRequired = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let handler = colorChangeHandler, colorPicker.colorChangeHandler == nil {
            colorPicker.colorChangeHandler = handler
        }
    }
}
