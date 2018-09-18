//
//  AppDelegate.swift
//  Active
//
//  Created by Tiago Maia Lopes on 27/05/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties

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
        using: persistentContainer.viewContext
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

    // MARK: Delegate methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        /// Flag indicating if the tests are being executed or not.
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

        if !isTesting {
            // Declare the seeder to be used based on the environemnt.
            var seeder: Seeder!

            #if DEVELOPMENT
            seeder = DevelopmentSeeder(container: persistentContainer)
            // Only erase in the development evironment.
            seeder.erase()
            #else
            seeder = Seeder(container: persistentContainer)
            #endif

            // Seed the approriate procedures.
            seeder.seed()
        }

        // Register the user notification categories.
        registerNotificationCategories()

        // Register the app for any UserNotification's events.
        UNUserNotificationCenter.current().delegate = self

        // Inject the main dependencies into the initial HabitTableViewController:
        if let habitsListingController = window?.rootViewController?.contents as? HabitsTableViewController {
            habitsListingController.container = persistentContainer
            habitsListingController.habitStorage = habitStorage
            habitsListingController.notificationManager = notificationManager
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Close any past challenges that are open.
        persistentContainer.performBackgroundTask { context in
            self.daysChallengeStorage.closePastChallenges(using: context)
            try? context.save()
        }

        // Reset the app icon's badge number.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Save the view context.
        self.saveContext()
    }

    // MARK: - Core Data stack

    /// The container used by the app.
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Active")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data
                 * protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    /// Convenient access to the app's persistent container.
    static var persistentContainer: NSPersistentContainer {
        return AppDelegate.current.persistentContainer
    }

    /// Convenient access to the app's used view context.
    static var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support

    /// Saves the app's view context.
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: UserNotifications extension
extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: Imperatives

    /// Registers the user notifications' categories with its corresponding actions.
    private func registerNotificationCategories() {
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

    /// Takes the user to the habit details controller.
    private func showHabitDetails(_ habit: HabitMO) {
        guard let navigationController = window?.rootViewController as? UINavigationController else { return }

        guard let detailsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: "HabitDetails"
        ) as? HabitDetailsViewController else {
            return
        }

        detailsController.habit = habit
        detailsController.container = persistentContainer
        detailsController.habitStorage = habitStorage
        detailsController.notificationManager = notificationManager

        navigationController.pushViewController(detailsController, animated: true)
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
            guard let habit = habitStorage.habit(using: persistentContainer.viewContext, and: habitId) else {
                assertionFailure("Couldn't get the habit using the passed identifier.")
                return
            }
            let (yesAction, noAction) = category.getActionIdentifiers()

            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                showHabitDetails(habit)

            case yesAction:
                habit.getCurrentChallenge()?.markCurrentDayAsExecuted()
                saveContext()

            case noAction:
                habit.getCurrentChallenge()?.markCurrentDayAsExecuted(false)
                saveContext()

            default:
                break
            }
        }

        completionHandler()
    }
}
