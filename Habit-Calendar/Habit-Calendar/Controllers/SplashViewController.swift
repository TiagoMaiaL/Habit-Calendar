//
//  SplashViewController.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 24/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Controller used to show that the app is being loaded. It also displays
/// any errors that might occur while loading the core data stack.
class SplashViewController: UIViewController {

    // MARK: Properties

    /// Loading view indicating progress.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Life Cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }
    }

    // MARK: Imperatives

    /// Displays the passed controller as the root one.
    func displayRootController(_ controller: UIViewController) {
        controller.transitioningDelegate = self
        present(controller, animated: true)
    }
}

extension SplashViewController: UIViewControllerTransitioningDelegate {

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension SplashViewController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else {
                assertionFailure("Couldn't get the controllers.")
                return
        }

        transitionContext.containerView.addSubview(toView)
        toView.isHidden = false
        toView.alpha = 1

        transitionContext.containerView.bringSubviewToFront(fromView)

        let propertyAnimator = UIViewPropertyAnimator(duration: 0.29, curve: .easeIn) {
            fromView.alpha = 0
            fromView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        propertyAnimator.addCompletion { _ in
            transitionContext.completeTransition(true)
        }

        propertyAnimator.startAnimation()
    }
}
