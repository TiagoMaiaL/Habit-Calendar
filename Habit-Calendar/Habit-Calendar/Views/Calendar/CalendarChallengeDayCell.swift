//
//  CalendarChallengeDayCell.swift
//  Active
//
//  Created by Tiago Maia Lopes on 10/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Cell in charge of displaying the challenge's dates.
class CalendarChallengeDayCell: CalendarDayCell {

    // MARK: Types

    /// The kind of challenge day being displayed within the challenge's range of days.
    enum RangePosition {
        case begin, inBetween, end, none
    }

    // MARK: Properties

    /// The day's position within the challenge's days.
    /// Default value is none.
    var position: RangePosition = .none {
        didSet {
            setNeedsLayout()
        }
    }

    /// The background view displaying the day's position in the challenge.
    private(set) lazy var rangeBackgroundView: UIView = {
        let rangeView = UIView()
        rangeView.translatesAutoresizingMaskIntoConstraints = false
        rangeView.backgroundColor = .red

        return rangeView
    }()

    /// The range view's vertical constraint applied to all situations.
    private lazy var verticalConstraint: NSLayoutConstraint = {
        return rangeBackgroundView.centerYAnchor.constraint(equalTo: dayTitleLabel.centerYAnchor)
    }()

    /// The range view's height constraint applied to all situations.
    private lazy var heightConstraint: NSLayoutConstraint = {
        return rangeBackgroundView.heightAnchor.constraint(
            equalTo: dayTitleLabel.heightAnchor,
            multiplier: 1,
            constant: 10
        )
    }()

    /// The range view's width constraint applied to all situations.
    private lazy var widthConstraint: NSLayoutConstraint = {
        return rangeBackgroundView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 2, constant: 0)
    }()

    /// The range view's begin horizontal constraint.
    private lazy var beginHorizontalConstraint: NSLayoutConstraint = {
        return rangeBackgroundView.leadingAnchor.constraint(equalTo: dayTitleLabel.leadingAnchor, constant: -10)
    }()

    /// The range view's inBetween horizontal constraint.
    private lazy var inBetweenHorizontalConstraint: NSLayoutConstraint = {
        return rangeBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
    }()

    /// The range view's end horizontal constraint.
    private lazy var endHorizontalConstraint: NSLayoutConstraint = {
        return rangeBackgroundView.trailingAnchor.constraint(equalTo: dayTitleLabel.trailingAnchor, constant: 10)
    }()

    // MARK: Life Cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Deactivate all horizontal constraints (specific constraints for each position type).
        beginHorizontalConstraint.isActive = false
        inBetweenHorizontalConstraint.isActive = false
        endHorizontalConstraint.isActive = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        switch position {
        case .begin, .inBetween, .end:
            rangeBackgroundView.layer.cornerRadius = (dayTitleLabel.intrinsicContentSize.height + 10) / 2
        default:
            rangeBackgroundView.layer.cornerRadius = 0
        }
    }

    // MARK: Imperatives

    /// Handles the cell's views.
    override func handleSubviews() {
        super.handleSubviews()

        guard !contentView.subviews.contains(rangeBackgroundView) else { return }
        contentView.addSubview(rangeBackgroundView)
    }

    /// Applies the cell's layout.
    override func applyLayout() {
        super.applyLayout()

        bottomSeparator.isHidden = true

        // The circle view should always be in the front.
        contentView.bringSubviewToFront(circleView)
        contentView.bringSubviewToFront(dayTitleLabel)

        rangeBackgroundView.isHidden = false

        verticalConstraint.isActive = true
        heightConstraint.isActive = true
        widthConstraint.isActive = true

        // Apply the rangeBgView's layout, according to the current position.
        switch position {
        case .begin:
            beginHorizontalConstraint.isActive = true

        case .inBetween:
            inBetweenHorizontalConstraint.isActive = true

        case .end:
            endHorizontalConstraint.isActive = true

        case .none:
            rangeBackgroundView.isHidden = true
        }
    }
}
