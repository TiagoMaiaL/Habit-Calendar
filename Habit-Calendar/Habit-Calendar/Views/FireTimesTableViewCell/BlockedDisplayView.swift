//
//  BlockedDisplayView.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 31/10/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

@IBDesignable class BlockedDisplayView: UIView {

    // MARK: Properties

    /// The line displayed on top of the fire time label, displayed if the fire time is blocked.
    private lazy var blockedLineView: UIView = {
        let blockedLine = UIView()
        blockedLine.translatesAutoresizingMaskIntoConstraints = false
        blockedLine.backgroundColor = .black

        return blockedLine
    }()

    /// The circle displayed in the end of the blocked line view.
    private lazy var blockedCircleView: RoundedView = {
        let circleView = RoundedView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = .black

        return circleView
    }()

    /// The color to be applied.
    @IBInspectable var color: UIColor? {
        didSet {
            if let color = color {
                blockedLineView.backgroundColor = color
                blockedCircleView.backgroundColor = color
            }
        }
    }

    /// A flag indicating if the layout was already applied.
    private var wasLayoutApplied = false

    // MARK: Initializers

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

    /// Configures the view before being used.
    private func setup() {
        backgroundColor = .clear
    }

    // MARK: Life cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        addSubviewsIfNeeded()
        applyLayoutIfNeeded()
    }

    // MARK: Imperatives

    /// Adds the subviews, if needed.
    private func addSubviewsIfNeeded() {
        guard blockedLineView.superview == nil, blockedCircleView.superview == nil else { return }

        addSubview(blockedLineView)
        addSubview(blockedCircleView)
    }

    /// Configures the layout of the subviews using autolayout.
    private func applyLayoutIfNeeded() {
        guard !wasLayoutApplied else { return }

        // Apply the layout using auto layout in the subviews.
        // Line view:
        blockedLineView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        blockedLineView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        blockedLineView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        blockedLineView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        // Circle view:
        blockedCircleView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        blockedCircleView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        blockedCircleView.centerYAnchor.constraint(equalTo: blockedLineView.centerYAnchor).isActive = true
        blockedCircleView.leadingAnchor.constraint(
            equalTo: blockedLineView.trailingAnchor,
            constant: -7
        ).isActive = true
        blockedCircleView.cornerRadius = 15 / 2

        // Since the auto layout was applied, set the flag to true.
        wasLayoutApplied = true
    }
}
