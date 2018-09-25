//
//  AppDelegate.swift
//  Active
//
//  Created by Tiago Maia Lopes on 27/05/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties

    /// The controller holding the app's persistent container.
    var dataController: DataController! {
        didSet {
            // Close any past challenges that are open.
            dataController.persistentContainer.performBackgroundTask { context in
                self.daysChallengeStorage.closePastChallenges(using: context)
                try? context.save()
            }
        }
    }

    /// The app's main window.
    var window: UIWindow?

    /// Convenient access to the app's delegate instance.
    static var current: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("Error: Couldn't correclty get the app's delegate.")
            return AppDelegate()
        }
        return delegate
    }

    /// The app's UserMO storage.
    private(set) lazy var userStorage = UserStorage()

    /// The app's UserMO main entity.
    private(set) lazy var mainUser = userStorage.getUser(
        using: dataController.persistentContainer.viewContext
    )!

    /// The app's DayMO storage.
    private(set) lazy var dayStorage = DayStorage()

    /// The app's HabitDayMO storage.
    private(set) lazy var habitDayStorage = HabitDayStorage(
        calendarDayStorage: dayStorage
    )

    /// The app's DaysChallengeStorage.
    private (set) lazy var daysChallengeStorage = DaysChallengeStorage(
        habitDayStorage: habitDayStorage
    )

    /// The app's UserNotificationManager in charge of all local
    /// user notifications.
    private(set) lazy var notificationManager = UserNotificationManager(
        notificationCenter: UNUserNotificationCenter.current()
    )

    private lazy var notificationScheduler = NotificationScheduler(
        notificationManager: notificationManager
    )

    /// The app's NotificationMO storage.
    private(set) lazy var notificationStorage = NotificationStorage()

    /// The app's Habit storage that's going to be used by the controllers.
    private(set) lazy var habitStorage: HabitStorage = HabitStorage(
        daysChallengeStorage: daysChallengeStorage,
        notificationStorage: notificationStorage,
        notificationScheduler: notificationScheduler,
        fireTimeStorage: FireTimeStorage()
    )

    /// The app to be displayed when the user selects an user notification.
    /// - Note: This variable is used in the cases that the app is launching and the habits
    ///         controller can't be accessed. Setting this var will make the habits
    ///         controller to immediately display the habit after being loaded.
    private var habitToDisplay: HabitMO?

    // MARK: Delegate methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // If app is being tested, there's no need to continue the app's configuration
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return true }

        registerUserNotificationCategories()
        UNUserNotificationCenter.current().delegate = self

        // Try loading the core data stack.
        dataController = DataController { error in
            if error == nil {
                DispatchQueue.main.async {
                    // Continue with the app's launch flow.
                    self.seed()
                    self.displayRootNavigationController()
                }
            } else {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data
                 * protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                self.sendDataControllerLoadingErrorNotification(error: error!)
            }
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Reset the app icon's badge number.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Save the view context.
        dataController.saveContext()
    }

    // MARK: Imperatives

    /// Seeds the main entities needed to run the app.
    private func seed() {
        var seeder: Seeder!

        // In development, the seed includes habits that are in progress and finished.
        #if DEVELOPMENT
        seeder = DevelopmentSeeder(container: dataController.persistentContainer)
        // Only erase in the development evironment.
        seeder.erase()
        #else
        // Otherwise, the seed only includes the main user.
        seeder = Seeder(container: dataController.persistentContainer)
        #endif

        seeder.seed()
    }

    /// Displays the main navigation controller of the app.
    private func displayRootNavigationController() {
        guard let splashController = window?.rootViewController as? SplashViewController else {
            assertionFailure("Couldn't get the splash screen.")
            return
        }
        guard let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: "MainNavigationController"
            ) as? UINavigationController else {
                assertionFailure("Couldn't get the main navigation controller.")
                return
        }

        // Inject the main dependencies into the initial HabitsTableViewController
        if let habitsController = navigationController.contents as? HabitsTableViewController {
            habitsController.container = dataController.persistentContainer
            habitsController.habitStorage = habitStorage
            habitsController.notificationManager = notificationManager
        }

        splashController.displayRootController(navigationController)
    }

    /// Sends a notification about the receival of a habit user notification launch event.
    private func sendHabitReminderNotification(_ habit: HabitMO) {
        NotificationCenter.default.post(
            name: Notification.Name.didSelectHabitReminder,
            object: self,
            userInfo: ["habit": habit]
        )
    }

    /// Sends a notification about errors that happen while loading core data.
    /// - Note: Any controllers can then handle
    ///         these kind of errors in the best way.
    private func sendDataControllerLoadingErrorNotification(error: Error) {
        NotificationCenter.default.post(
            name: Notification.Name.didFailLoadingData,
            object: self,
            userInfo: ["error": error]
        )
    }
}

// MARK: UserNotifications extension
extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: Imperatives

    /// Registers the user notifications' categories with its corresponding actions.
    private func registerUserNotificationCategories() {
        let categoryKind = UNNotificationCategory.Kind.dayPrompt(habitId: nil)
        let (yesActionIdentifier, notActionIdentifier) = categoryKind.getActionIdentifiers()

        let yesAction = UNNotificationAction(
            identifier: yesActionIdentifier,
            title: "Yes, i did",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        let noAction = UNNotificationAction(
            identifier: notActionIdentifier,
            title: "No, not yet",
            options: UNNotificationActionOptions(rawValue: 0)
        )
        let dayPromptCategory = UNNotificationCategory(
            identifier: categoryKind.identifier,
            actions: [yesAction, noAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([dayPromptCategory])
    }

    // MARK: UserNotificationCenter Delegate methods

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let category = response.notification.request.content.getCategory() else { return }

        switch category {
        case .dayPrompt(let habitId):
            guard let habitId = habitId else {
                assertionFailure("Couldn't get the habit's id from the notification payload.")
                return
            }
            guard let habit = habitStorage.habit(
                using: dataController.persistentContainer.viewContext,
                and: habitId
                ) else {
                    assertionFailure("Couldn't get the habit using the passed identifier.")
                    return
            }
            let (yesAction, noAction) = category.getActionIdentifiers()

            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // If the habits listing controller is already being displayed, show the details.
                if window?.rootViewController is UINavigationController {
                    // Post a notification to the habits table view controller,
                    // so it can display the habit.
                    sendHabitReminderNotification(habit)
                } else {
                    // If not, the splash screen is being displayed, show the details immediately after
                    // displaying the habits controller.
                    habitToDisplay = habit
                }

            case yesAction:
                habit.getCurrentChallenge()?.markCurrentDayAsExecuted()
                dataController.saveContext()

            case noAction:
                habit.getCurrentChallenge()?.markCurrentDayAsExecuted(false)
                dataController.saveContext()

            default:
                break
            }
        }

        completionHandler()
    }
}
