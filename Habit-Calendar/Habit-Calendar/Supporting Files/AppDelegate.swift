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

    /// The manager in charge of adding / removing the dynamic shortcuts of the app.
    private lazy var shortcutsManager = HabitsShortcutItemsManager(application: UIApplication.shared)

    /// Flag indicating if the splash screen is still being displayed or not.
    private var isDisplayingSplashScreen: Bool {
        return AppDelegate.current.window?.rootViewController?.presentedViewController == nil
    }

    /// The app to be displayed when the user selects an user notification.
    /// - Note: This variable is used in the cases that the app is launching and the habits
    ///         controller can't be accessed. Setting this var will make the habits
    ///         controller to immediately display the habit after being loaded.
    private var habitToDisplay: HabitMO?

    /// Flag indicating if the habit creation controller should be displayed because the user selected the New habit
    /// quick action.
    private var shouldDisplayCreationController = false

    /// The review manager used to collect the feedback of the user.
    private var reviewManager = AppStoreReviewManager(userDefaults: UserDefaults.standard)

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

        // Always call the method to reset the review parameters if the app version has changed.
        let infoDictionaryKey = kCFBundleVersionKey as String
        if let version = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String {
            reviewManager.updateReviewParameters(usingAppVersion: version)
        } else {
            assertionFailure("Error: Couldn't get the app version.")
        }
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
            habitsController.shortcutsManager = shortcutsManager
            habitsController.reviewManager = reviewManager
        }

        splashController.displayRootController(navigationController)

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            DispatchQueue.main.async {
                // The user selected the habit from the user notification. Show it right after displaying
                // the root controller.
                if let habitToDisplay = self.habitToDisplay {
                    self.sendNotificationToDisplayHabit(habitToDisplay)

                // The user selected the "New habit" quick action.
                } else if self.shouldDisplayCreationController {
                    self.sendNewHabitQuickActionNotification()
                }
            }
        }
    }

    /// Sends a notification to display the passed habit.
    private func sendNotificationToDisplayHabit(_ habit: HabitMO) {
        NotificationCenter.default.post(
            name: Notification.Name.didChooseHabitToDisplay,
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

    /// Sends a notification about the selection of the "New habit" quick action.
    private func sendNewHabitQuickActionNotification() {
        NotificationCenter.default.post(name: Notification.Name.didSelectNewHabitQuickAction, object: self)
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
            title: "Yes, I did",
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
                if isDisplayingSplashScreen {
                    // If the splash screen is being displayed, show the details immediately after
                    // displaying the habits controller.
                    habitToDisplay = habit
                } else {
                    // If the habits listing controller is already being displayed, show the details.
                    sendNotificationToDisplayHabit(habit)
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

extension AppDelegate {

    // MARK: Type

    /// The type of quick action selected by the user.
    enum QuickActionType: String {
        case newHabit = "new-habit"
        case displayHabit = "display-habit"
    }

    // MARK: Shortcuts

    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let typeRawValue = shortcutItem.type.components(separatedBy: ".").last,
            let type = QuickActionType(rawValue: typeRawValue) else {
                assertionFailure("Couldn't get the type of the shortcut item.")
                return
        }

        switch type {
        case .newHabit:
            if isDisplayingSplashScreen {
                // Set a flag to present the creation controller right after displaying the list of habits.
                shouldDisplayCreationController = true
            } else {
                // The habits list is being displayed, present the creation controller on top of it.
                sendNewHabitQuickActionNotification()
            }
        case .displayHabit:
            // Get the habit to be displayed.
            guard let habitId = shortcutItem.userInfo?[HabitsShortcutItemsManager.habitIdentifierUserInfoKey]
                as? String,
                let habit = habitStorage.habit(
                    using: dataController.persistentContainer.viewContext,
                    and: habitId
                ) else {
                    assertionFailure("Couldn't get the habit to be displayed.")
                    return
            }

            if isDisplayingSplashScreen {
                habitToDisplay = habit
            } else {
                sendNotificationToDisplayHabit(habit)
            }
        }

        completionHandler(false)
    }
}
