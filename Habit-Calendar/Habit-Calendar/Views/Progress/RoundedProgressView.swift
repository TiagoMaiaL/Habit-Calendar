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
            // TODO: Change the title of the progress label.
        }
    }

    /// The label displaying the current progress.
    private(set) var progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "33%"
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
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

            wasAutoLayoutApplied = true
        }

        // TODO: Draw the circle bars.
        let center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let radius = (frame.size.height / 2) - 10

        let filledProgresseBar = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: (2 * .pi * progress) - .pi / 2,
            clockwise: true
        )
        tint.setStroke()
        filledProgresseBar.lineWidth = 7
        filledProgresseBar.lineCapStyle = .round
        filledProgresseBar.stroke()

        let placeHolderProgresseBar = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: 360,
            clockwise: true
        )
        tint.withAlphaComponent(0.5).setStroke()
        placeHolderProgresseBar.lineWidth = 7
        placeHolderProgresseBar.stroke()
    }
}
