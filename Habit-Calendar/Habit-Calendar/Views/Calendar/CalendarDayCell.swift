//
//  CalendarDayCell.swift
//  Active
//
//  Created by Tiago Maia Lopes on 09/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import JTAppleCalendar

/// Cell in charge of displaying the calendar's days.
@IBDesignable class CalendarDayCell: JTAppleCell {

    // MARK: Types

    /// The kind of challenge day being displayed within the challenge's range of days.
    enum RangePosition {
        case begin, inBetween, end, none
    }

    // MARK: Parameters

    /// The text's default color.
    let defaultTextColor = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1)

    /// The day's title label.
    lazy var dayTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "SFProText-Regular", size: 21)
        label.textColor = self.defaultTextColor
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    /// The circle view to be displayed.
    lazy var circleView: UIView = {
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false

        return circleView
    }()

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

    /// MARK: Life cycle

    override func layoutSubviews() {
        super.layoutSubviews()

        handleSubviews()
        applyLayout()

        switch position {
        case .begin, .inBetween, .end:
            rangeBackgroundView.layer.cornerRadius = (dayTitleLabel.intrinsicContentSize.height + 10) / 2
        default:
            rangeBackgroundView.layer.cornerRadius = 0
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layoutIfNeeded()
        dayTitleLabel.text = String(Int.random(0..<32))
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        backgroundColor = .white
        circleView.backgroundColor = .clear
        dayTitleLabel.textColor = defaultTextColor

        // Deactivate all horizontal constraints (specific constraints for each position type).
        beginHorizontalConstraint.isActive = false
        inBetweenHorizontalConstraint.isActive = false
        endHorizontalConstraint.isActive = false
    }

    // MARK: Imperatives

    /// Handles the cell's main views, if they should be added as a subview or not.
    func handleSubviews() {
        guard !contentView.subviews.contains(circleView),
            !contentView.subviews.contains(dayTitleLabel),
            !contentView.subviews.contains(rangeBackgroundView) else {
                return
        }
        contentView.addSubview(circleView)
        contentView.addSubview(dayTitleLabel)
        contentView.addSubview(rangeBackgroundView)
    }

    /// Applies the layout to the subviews, if appropriate.
    func applyLayout() {
        dayTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        dayTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        circleView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        circleView.layer.cornerRadius = 35 * 0.5

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
