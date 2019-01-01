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
            progressLabel.textColor = tint ?? .black
        }
    }

    @IBInspectable var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
            displayProgress()
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

    /// Configures the label text to display the current progress.
    private func displayProgress() {
        // Set the label text with attributed strings. The perctent sign should be smaller.
        let progressText = String(Int(progress * 100))
        let attributedString = NSMutableAttributedString(string: progressText + "%")

        attributedString.addAttributes(
            [.font: UIFont(name: "SFProText-Bold", size: 20)!],
            range: NSRange(location: 0, length: progressText.count)
        )
        attributedString.addAttributes(
            [.font: UIFont(name: "SFProText-Regular", size: 15)!],
            range: NSRange(location: progressText.count, length: 1)
        )

        progressLabel.attributedText = attributedString
    }

    func drawProgress() {
        let tint = self.tint ?? UIColor.black

        if !wasAutoLayoutApplied {
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

            wasAutoLayoutApplied = true
        }

        // Draw the progress circles.
        // There are two: one showing the progress and other showing the total circle.
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
