//
//  MonthHeaderView.swift
//  Active
//
//  Created by Tiago Maia Lopes on 09/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A header view used to display a calendar's month.
@IBDesignable class MonthHeaderView: UIView {

    // MARK: Properties

    /// The label's color.
    @IBInspectable var tint: UIColor?

    /// The header's previous month button.
    private(set) lazy var previousButton: UIButton = {
        let previousButton = UIButton(type: .custom)
        previousButton.setBackgroundImage(UIImage(named: "ic-previous"), for: .normal)
        previousButton.backgroundColor = .green

        return previousButton
    }()

    /// The header's next month button.
    private(set) lazy var nextButton: UIButton = {
        let nextButton = UIButton(type: .custom)
        nextButton.setBackgroundImage(UIImage(named: "ic-next"), for: .normal)
        nextButton.backgroundColor = .green

        return nextButton
    }()

    /// The header's month label.
    private(set) lazy var monthLabel: UILabel = {
        let monthLabel = UILabel()
        monthLabel.textAlignment = .center
        monthLabel.font = UIFont(name: "SFProText-Regular", size: 15)
        monthLabel.text = "August, 2018"

        return monthLabel
    }()

    /// The horizontal stack view containing the calendar's content.
    private(set) lazy var monthStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center

        return stackView
    }()

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    // MARK: Setup

    /// Creates and adds the month label with the next/back buttons.
    private func setup() {
        // Add the stackView items in the following order: previous button, label, nextButton.
        monthStackView.addArrangedSubview(previousButton)
        monthStackView.addArrangedSubview(monthLabel)
        monthStackView.addArrangedSubview(nextButton)

        // Add the stack view as a subview.
        addSubview(monthStackView)
    }

    // MARK: Life cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        monthLabel.textColor = tint ?? UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)

        monthStackView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)

        // Change the previous and next buttons to have an specific width by using auto layout.
        previousButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        previousButton.heightAnchor.constraint(equalTo: monthStackView.heightAnchor, multiplier: 1).isActive = true

        nextButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        nextButton.heightAnchor.constraint(equalTo: monthStackView.heightAnchor, multiplier: 1).isActive = true
    }
}
