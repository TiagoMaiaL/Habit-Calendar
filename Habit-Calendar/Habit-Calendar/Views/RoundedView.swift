//
//  RoundedView.swift
//  Active
//
//  Created by Tiago Maia Lopes on 29/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

protocol Rounded {

    /// The View's corner radius.
    var cornerRadius: CGFloat { get set }
}

/// A designable view with getters and setters for its corner radius.
@IBDesignable class RoundedView: UIView, Rounded {

    // MARK: Imperatives

    /// The card's corner radius.
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
