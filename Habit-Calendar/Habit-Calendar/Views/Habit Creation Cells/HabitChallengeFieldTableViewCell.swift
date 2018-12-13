//
//  HabitChallengeFieldTableViewCell.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 13/12/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// This table view cell displays a field used to inform the user about the challenge
/// of days of the habit being created.
class HabitChallengeFieldTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The label displaying the title of the field.
    @IBOutlet var titleLabel: UILabel!

    /// The label displaying additional information about the field.
    @IBOutlet var infoLabel: UILabel!

    /// The label displaying how many days are selected.
    @IBOutlet var daysCountLabel: UILabel!

    /// The label displaying the first date of the challenge.
    @IBOutlet var fromDateLabel: UILabel!

    /// The label displaying the last date of the challenge.
    @IBOutlet var toDateLabel: UILabel!

    /// The theme color applied to the mains labels of the cell.
    var themeColor: UIColor? {
        didSet {
            if let color = themeColor {
                daysCountLabel.textColor = color
                fromDateLabel.textColor = color
                toDateLabel.textColor = color
            }
        }
    }

    // MARK: Life Cycle

    override func prepareForReuse() {
        super.prepareForReuse()

        daysCountLabel.text = ""
        fromDateLabel.text = ""
        toDateLabel.text = ""
    }
}
