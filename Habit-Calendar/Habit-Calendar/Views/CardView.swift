//
//  CardView.swift
//  Active
//
//  Created by Tiago Maia Lopes on 03/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import QuartzCore

/// A view used to contain other views in a card based design.
@IBDesignable class CardView: RoundedView {

    // MARK: Properties

    /// The card's shadow's color.
    @IBInspectable public var shadowColor: UIColor = .black

    /// The card's shadow's offset.
    @IBInspectable public var shadowOffset: CGSize = CGSize(width: -15, height: 20)

    /// The card's shadow's radius.
    @IBInspectable public var shadowRadius: CGFloat = 5

    /// The card's shadow's opacity.
    @IBInspectable public var shadowOpacity: Float = 0.5

    // MARK: InitializerC

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShadow()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShadow()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupShadow()
    }

    // MARK: Life cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupShadow()
    }

    // MARK: Imperatives

    /// Configures the card's shadow according to the inspectable properties.
    private func setupShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowColor = shadowColor.cgColor
    }
}
