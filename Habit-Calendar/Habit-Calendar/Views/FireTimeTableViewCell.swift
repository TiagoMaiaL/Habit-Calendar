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

    /// The view showing indicating that the fire time is blocked by another habit.
    /// - Note: this view is a line being displayed on top of the fire time label.
//    private(set) lazy var blockedFireTimeView: UIView = {
//        let baseView = UIView()
//        baseView.translatesAutoresizingMaskIntoConstraints = false
//        baseView.backgroundColor = .clear
//
//        baseView.addSubview(blockedLineView)
//        baseView.addSubview(blockedCircleView)
//
//        blockedLineView.widthAnchor.constraint(equalTo: baseView.widthAnchor, multiplier: 1).isActive = true
//        blockedLineView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
//        blockedLineView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
//        blockedLineView.heightAnchor.constraint(equalToConstant: 8).isActive = true
//
//        blockedCircleView.widthAnchor.constraint(equalToConstant: 15).isActive = true
//        blockedCircleView.heightAnchor.constraint(equalToConstant: 15).isActive = true
//        blockedCircleView.centerYAnchor.constraint(equalTo: blockedLineView.centerYAnchor).isActive = true
//        blockedCircleView.trailingAnchor.constraint(equalTo: blockedLineView.trailingAnchor, constant: 7)
//        blockedCircleView.cornerRadius = 15 / 2
//
//        return baseView
//    }()

    /// The line displayed on top of the fire time label, displayed if the fire time is blocked.
//    private lazy var blockedLineView: UIView = {
//        let blockedLine = UIView()
//        blockedLine.translatesAutoresizingMaskIntoConstraints = false
//
//        blockedLine.backgroundColor = .red
//
//        return blockedLine
//    }()

    /// The circle displayed in the end of the blocked line view.
//    private lazy var blockedCircleView: RoundedView = {
//        let circleView = RoundedView()
//        circleView.translatesAutoresizingMaskIntoConstraints = false
//
//        circleView.backgroundColor = .red
//
//        return circleView
//    }()

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
