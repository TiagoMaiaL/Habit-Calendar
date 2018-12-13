//
//  HabitFireTimesFieldTableViewCell.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 13/12/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// This table view cell displays a field informing the selected fire times for a habit.
class HabitFireTimesFieldTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The label displaying the title of the field.
    @IBOutlet var titleLabel: UILabel!

    /// The label displaying the number of selected fire times.
    @IBOutlet var fireTimesAmountLabel: UILabel!

    /// The label displaying the hour and minute of some fire times.
    @IBOutlet var fireTimesLabel: UILabel!

    // MARK: Impertives

    override func prepareForReuse() {
        super.prepareForReuse()

        fireTimesAmountLabel.text = ""
        fireTimesLabel.text = ""
    }
}
