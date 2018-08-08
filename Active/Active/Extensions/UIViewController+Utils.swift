//
//  UIViewController+Utils.swift
//  Active
//
//  Created by Tiago Maia Lopes on 03/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds utilities to the view controller class.
extension UIViewController {

    /// The contents (child controller) of this parent controller.
    /// - Note: If the controller is a navigation controller, it returns its
    ///         root vc, otherwise the returned entity is just the
    ///         controller itself.
    var contents: UIViewController {
        if self is UINavigationController {
            return (self as? UINavigationController)?.viewControllers.first ?? self
        } else {
            return self
        }
    }
}
