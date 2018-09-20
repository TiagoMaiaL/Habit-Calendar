//
//  StorageTestCase.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 11/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Habit_Calendar

/// The TestCase class used to test the app's storage layer.
/// - Note: TestCase class intended to be subclassed by each file testing the storage classes.
class IntegrationTestCase: XCTestCase {

    // MARK: - Properties

    /// The persistent container used to test the storage classes.
    var memoryPersistentContainer: NSPersistentContainer!

    /// The default context used by the tests.
    var context: NSManagedObjectContext {
        return memoryPersistentContainer.viewContext
    }

    /// The user factory used by the tests.
    var userFactory: UserFactory!

    /// The habit factory used by the tests.
    var habitFactory: HabitFactory!

    /// The notification factory used by the tests.
    var notificationFactory: NotificationFactory!

    /// The day factory used by the tests.
    var dayFactory: DayFactory!

    /// The habitDay factory used by the tests.
    var habitDayFactory: HabitDayFactory!

    /// The daysChallenge factory used by the tests.
    var daysChallengeFactory: DaysChallengeFactory!

    // MARK: setup/tearDown

    override func setUp() {
        super.setUp()

        /// Create a brand new in-memory persistent container.
        memoryPersistentContainer = makeMemoryPersistentContainer()

        // Instantiate all factories used in the tests.
        userFactory = UserFactory(context: context)
        habitFactory = HabitFactory(context: context)
        notificationFactory = NotificationFactory(context: context)
        dayFactory = DayFactory(context: context)
        habitDayFactory = HabitDayFactory(context: context)
        daysChallengeFactory = DaysChallengeFactory(context: context)
}

    override func tearDown() {
        /// Remove the factories created.
        userFactory = nil
        habitFactory = nil
        notificationFactory = nil
        dayFactory = nil
        habitDayFactory = nil
        daysChallengeFactory = nil

        /// Remove the used in-memory persistent container.
        memoryPersistentContainer.viewContext.rollback()
        memoryPersistentContainer = nil

        super.tearDown()
    }

    // MARK: Imperatives

    /// Creates an in-memory persistent container to be used by the tests.
    /// - Returns: The in-memory NSPersistentContainer.
    func makeMemoryPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Habit-Calendar")

        // Declare the in-memory Store description.
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores(completionHandler: { (description, error) in
            // Description's type should always be in-memory when testing.
            precondition(description.type == NSInMemoryStoreType)

            if error != nil {
                // If there's an error when loading the store, the storage tests shouldn't proceed.
                fatalError("There's an error when loading the persistent store for test (in-memory configurations).")
            }
        })

        return container
    }

    /// Helper method to create a dummy Notification entity
    /// from a dummy Habit.
    /// - Returns: the dummy notification.
    func makeNotification() -> NotificationMO {
        // Declare the dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // Declare the dummy notification out of the passed habit.
        guard let dummyNotification = (dummyHabit.notifications as? Set<NotificationMO>)?.first else {
            assertionFailure(
                "A notification object must be retrieved from a dummy Habit"
            )
            return notificationFactory.makeDummy()
        }

        // Make assertions to ensure that the habit and
        // fireDate properties are set.
        assert(
            dummyNotification.fireDate != nil,
            "The fireDate property from the generated notification dummy should be set."
        )
        assert(
            dummyNotification.habit != nil,
            "The habit property from the generated notification dummy should be set."
        )
        assert(dummyNotification.dayOrder > 0, "The notification should have an order.")

        return dummyNotification
    }
}
