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

    // MARK: Initializers

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        startObserving()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startObserving()
    }

    deinit {
        stopObserving()
    }

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
    /// - Parameter controller: The controller to be presented as the root one.
    func displayRootController(_ controller: UIViewController) {
        controller.transitioningDelegate = self
        present(controller, animated: true)
    }
}

extension SplashViewController: UIViewControllerTransitioningDelegate {

    // MARK: UIViewControllerTransitioningDelegate implementation methods

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension SplashViewController: UIViewControllerAnimatedTransitioning {

    // MARK: UIViewControllerAnimatedTransitioning implementation methods

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

import os.log
extension SplashViewController: DataLoadingErrorObserver {

    // MARK: DataLoadingErrorObserver implementation methods

    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataLoadingError(_:)),
            name: NSNotification.Name.didFailLoadingData,
            object: nil
        )
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    func handleDataLoadingError(_ notification: Notification) {
        // Present the unrecoverable error. Also make sure the controller is on screen by putting off the presentation.
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.present(
                UIAlertController.make(
                    title: "Error",
                    message: """
An unrecoverable error happened while trying to load the app. Please contact the app developer.
""",
                    mainButtonTitle: "Exit",
                    buttonHandler: {
                        if let error = notification.userInfo?["error"] as? NSError {
                            os_log(
                                "Failed to load the data controller: %@\n%@",
                                error.localizedDescription,
                                error.userInfo
                            )
                        }
                        abort()
                    }
                ),
                animated: true
            )
        }
    }
}
