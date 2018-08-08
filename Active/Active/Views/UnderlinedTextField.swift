//
//  UnderlinedTextField.swift
//  Active
//
//  Created by Tiago Maia Lopes on 06/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A text field with an underline only.
@IBDesignable class UnderlinedTextField: UITextField {

    // MARK: Properties

    /// The underline thickness.
    @IBInspectable var thickness: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The underline color.
    @IBInspectable var underlineColor: UIColor = UIColor(red: 47/255, green: 64/255, blue: 54/255, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }

    /// The underline layer.
    private var underlineLayer: CALayer? = nil {
        didSet {
            setNeedsLayout()
        }
    }

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

    /// Configures the textField initial appearance.
    private func setup() {
        borderStyle = .none
    }

    // MARK: Life Cycle

    override func layoutSubviews() {
        super.layoutSubviews()

        if underlineLayer == nil {
            // Declare the underline CALayer.
            underlineLayer = CALayer()

            // Add it as a sublayer.
            layer.addSublayer(underlineLayer!)
        }

        // Configure it to have the right color and the right thickness.
        underlineLayer?.backgroundColor = underlineColor.cgColor

        // Add it to the view and position it at the bottom.
        underlineLayer?.frame = CGRect(
            x: 0,
            y: frame.size.height,
            width: frame.size.width,
            height: thickness
        )
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsLayout()
        setNeedsDisplay()
    }

}
