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

    // MARK: Imperatives

    /// Animates the button to display the touch down event.
    private func animateBeginOfTouch() {
        UIViewPropertyAnimator(duration: 0.1, curve: .easeIn) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }.startAnimation()
    }

    /// Animates the button to display the touch up event.
    private func animateEndOfTouch() {
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.3) {
            self.transform = CGAffineTransform.identity
            self.layer.cornerRadius = self.frame.size.height / 2
        }.startAnimation()
    }
}
