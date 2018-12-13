//
//  RoundedButton.swift
//  Active
//
//  Created by Tiago Maia Lopes on 07/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A custom rounded button.
@IBDesignable class RoundedButton: UIButton, TouchAnimatable {

    // MARK: Properties

    override var isEnabled: Bool {
        didSet {
            // Set the button's alpha to show if it's enabled or not.
            UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.alpha = (self.isEnabled ? 1 : 0.3)
            }.startAnimation()
        }
    }

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

    private func setup() {
        layer.cornerRadius = self.frame.height / 2
        adjustsImageWhenHighlighted = false
    }

    // MARK: Life Cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
        layoutIfNeeded()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateBeginOfTouch()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateEndOfTouch()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateEndOfTouch()
    }
}
