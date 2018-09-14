//
//  CompletedHabitTableViewCell.swift
//  Active
//
//  Created by Tiago Maia Lopes on 29/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

class CompletedHabitTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The view displaying the habit's color.
    @IBOutlet weak var colorView: RoundedView!

    /// The label displaying the habit's name.
    @IBOutlet weak var nameLabel: UILabel!

    // MARK: Life cycle

    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.cornerRadius = colorView.frame.size.height / 2
    }
}
