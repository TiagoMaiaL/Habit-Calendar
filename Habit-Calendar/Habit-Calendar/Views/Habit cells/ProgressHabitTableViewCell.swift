//
//  InProgressHabitTableViewCell.swift
//  Active
//
//  Created by Tiago Maia Lopes on 03/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A TableViewCell used to display the details about a habit and its current challenge.
class ProgressHabitTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The card looking view displaying the habit's details.
    @IBOutlet weak var cardView: UIView!

    /// The habit's name label.
    @IBOutlet weak var nameLabel: UILabel!

    /// The habit's progress label.
    @IBOutlet weak var progressLabel: UILabel!

    /// The habit's days' progress view.
    @IBOutlet weak var progressBar: ProgressView!
}
