//
//  FireTimeTableViewCell.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 30/10/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// TableViewCell displaying a fire time, which might be blocked or not.
/// - Note: This cell has a default state showing the free fire time and it also has a state showing a blocked
///         fire time. If the fire time is blocked, the name of the habit is displayed, with a line on top of
///         the fire time label.
@IBDesignable class FireTimeTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The label displaying the fire time.
    @IBOutlet weak var fireTimeLabel: UILabel!

    /// The label displaying the habit name, in case the fire time is already blocked by it.
    @IBOutlet weak var habitNameLabel: UILabel!

    /// The flag indicating if the fire time is blocked or not.
    var isFireTimeBlocked = false {
        didSet {
            isUserInteractionEnabled = !isFireTimeBlocked
            habitNameLabel?.isHidden = !isFireTimeBlocked
        }
    }

    /// The color applied to the habit name label, to the blocked state view, and to the background view,
    /// in case the cell is selected or not.
    var habitColor: UIColor? {
        didSet {
            if let color = habitColor {
                habitNameLabel.textColor = color
            } else {
                habitNameLabel.textColor = .black
            }
        }
    }

    // MARK: Life Cycle

    override func prepareForReuse() {
        super.prepareForReuse()

        habitNameLabel.text = ""
        fireTimeLabel.text = ""
        isFireTimeBlocked = false
        habitColor = nil
        showDefaultState()
    }

    // MARK: Imperatives

    private func showDefaultState() {
        fireTimeLabel.textColor = .black
        contentView.backgroundColor = .white
    }

    /// Shows the selected state for the current cell.
    func select() {
        isFireTimeBlocked = false
        contentView.backgroundColor = habitColor
        fireTimeLabel.textColor = .white
    }

    /// Deselects the view and shows the default state of the cell.
    func deselect() {
        showDefaultState()
    }
}
