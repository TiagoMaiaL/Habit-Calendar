//
//  DaysHeaderView.swift
//  Active
//
//  Created by Tiago Maia Lopes on 09/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

@IBDesignable class DaysHeaderView: UIView {

    // MARK: Properties

    // The color applied to each day label.
    @IBInspectable var tint: UIColor?

    /// The labels of each day, ordered by sunday to saturday.
    private var daysLabels: [UILabel] = {
        // Declare the localized days' texts to be used.
        let daysInitials = DateFormatter().weekdaySymbols.map { $0.uppercased()[$0.startIndex] }

        // Declare a temporary array to hold the labels for each day.
        var labels = [UILabel]()

        // Iterate over each text and create/configure its associated UILabel object.
        for initial in daysInitials {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont(name: "SFProText-Regular", size: 15)
            label.text = String(initial)

            labels.append(label)
        }

        return labels
    }()

    /// The horizontal stack view containing each day's label.
    private lazy var daysStackView: UIStackView = {
        // Create and configure the stack view.
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
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

    /// Creates and adds all days labels.
    private func setup() {
        for label in daysLabels {
            // Configure the label's attributes.
            label.textColor = tint ?? UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)

            // Arrange the label within the horizontal stackView.
            daysStackView.addArrangedSubview(label)
        }

        // Add the stack view as subview.
        addSubview(daysStackView)
    }

    // MARK: Life cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        daysStackView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }

}
