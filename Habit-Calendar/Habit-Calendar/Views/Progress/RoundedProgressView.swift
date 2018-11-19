//
//  RoundedProgressView.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 19/11/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// View displaying a rounded progress bar.
@IBDesignable class RoundedProgressView: UIView, ProgressDisplayable {

    // MARK: Properties

    @IBInspectable var tint: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The label displaying the current progress.
    private(set) var progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var wasAutoLayoutApplied = false

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

    private func setup() {
        if progressLabel.superview == nil {
            addSubview(progressLabel)
        }
    }

    // MARK: Life Cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawProgress()
    }

    // MARK: Imperatives

    func drawProgress() {
        let tint = self.tint ?? UIColor.black

        if !wasAutoLayoutApplied {
            // TODO: Apply the auto layout.

            wasAutoLayoutApplied = true
        }

        // TODO: Draw the circle bars.
    }
}
