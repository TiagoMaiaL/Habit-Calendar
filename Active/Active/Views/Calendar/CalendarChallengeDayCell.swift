//
//  CalendarChallengeDayCell.swift
//  Active
//
//  Created by Tiago Maia Lopes on 10/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Cell in charge of displaying the challenge's dates.
@IBDesignable class CalendarChallengeDayCell: CalendarDayCell {

    // MARK: Types

    /// The kind of challenge day being displayed within the challenge's range of days.
    enum RangePosition {
        case begin, inBetween, end
    }

    // MARK: Properties

    /// The day's position within the challenge's days.
    /// Default value is inBetween.
    var position: RangePosition = .inBetween

    /// The background view displaying the day's position in the challenge.
    lazy var rangeBackgroundView: UIView = {
        return UIView()
    }()

    // MARK: Life Cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    // MARK: Imperatives

    /// Handles the cell's views.
    override func handleSubviews() {
        super.handleSubviews()

        guard !subviews.contains(rangeBackgroundView), !subviews.contains(dayTitleLabel) else {
            return
        }
        addSubview(rangeBackgroundView)
        addSubview(dayTitleLabel)
    }

    /// Applies the cell's layout.
    override func applyLayout() {
        super.applyLayout()

        bottomSeparator.isHidden = true

        // Apply the rangeBgView's layout, according to the current position.
        switch position {
        case .begin:
            break
        case .inBetween:
            break
        case .end:
            break
        }
    }
}
