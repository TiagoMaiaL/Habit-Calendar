//
//  ProgressView.swift
//  Active
//
//  Created by Tiago Maia Lopes on 03/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A progress bar view.
@IBDesignable class ProgressView: UIView {

    // MARK: Properties

    /// The main color of the progress view.
    @IBInspectable public var tint: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// A float from 0 to 1 indicating the progress being displayed
    /// by the view.
    @IBInspectable public var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The rect used for drawing the progress shapes.
    private var drawableRect: CGRect {
        return CGRect(
            x: 0,
            y: 0,
            width: frame.size.width,
            height: frame.size.height
        )
    }

    override var intrinsicContentSize: CGSize {
        // The minimum view's height is 10 points.
        var minimumHeight = frame.size.height
        if minimumHeight < 10 {
            minimumHeight = 10
        }
        return CGSize(width: frame.size.width, height: minimumHeight)
    }

    // MARK: Life cycle

    override func draw(_ rect: CGRect) {
        drawProgress()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        drawProgress()
    }

    // MARK: Imperatives

    /// Draws the progress bar taking into account the color and
    /// the progress amount.
    private func drawProgress() {
        guard let tint = tint else { return }

        // Create a RectPath for the view's background bar.
        let barPath = UIBezierPath(
            roundedRect: drawableRect,
            cornerRadius: 10
        )
        tint.withAlphaComponent(0.5).setFill()
        barPath.fill()

        // Create another rectPath for the view's progress bar.
        var progressPathRect = drawableRect
        progressPathRect.size.width *= progress

        let progressBarPath = UIBezierPath(
            roundedRect: progressPathRect,
            cornerRadius: 10
        )
        tint.setFill()
        progressBarPath.fill()
    }

}
