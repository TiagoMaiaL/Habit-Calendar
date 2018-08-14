//
//  RoundedButton.swift
//  Active
//
//  Created by Tiago Maia Lopes on 07/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A custom rounded button.
@IBDesignable class RoundedButton: UIButton {

    // MARK: Properties

    override var isEnabled: Bool {
        didSet {
            // Set the button's alpha to show if it's enabled or not.
            UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.alpha = (self.isEnabled ? 1 : 0.3)
            }.startAnimation()
        }
    }

    // MARK: Life Cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Configure the button's corner radius.
        layer.cornerRadius = frame.size.height / 2
    }

}
