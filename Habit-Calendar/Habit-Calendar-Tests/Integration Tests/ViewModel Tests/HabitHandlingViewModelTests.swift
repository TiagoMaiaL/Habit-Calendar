//
//  HabitHandlingViewModelTests.swift
//  Habit-CalendarTests
//
//  Created by Tiago Maia Lopes on 05/12/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import XCTest
@testable import Habit_Calendar

class HabitHandlingViewModelTests: IntegrationTestCase {

    // MARK: Properties

    /// The habit storage used by the view model. This property needs to be initialized only once.
    var habitStorage: HabitStorage!

    // MARK: Setup/Teardown

    override func setUp() {
        // Initialize the habit storage.
        let habitDayStorage = HabitDayStorage(calendarDayStorage: DayStorage())
        let daysChallengeStorage = DaysChallengeStorage(habitDayStorage: habitDayStorage)

        let notificationCenter = UserNotificationCenterMock(withAuthorization: false)
        let notificationManager = UserNotificationManager(notificationCenter: notificationCenter)
        let notificationScheduler = NotificationScheduler(notificationManager: notificationManager)

        habitStorage = HabitStorage(
            daysChallengeStorage: daysChallengeStorage,
            notificationStorage: NotificationStorage(),
            notificationScheduler: notificationScheduler,
            fireTimeStorage: FireTimeStorage()
        )

        super.setUp()
    }

    override func tearDown() {
        // Clear the habit storage.
        habitStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testIfIsEditingHabitFlagIsTrue() {
        let habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: habitFactory.makeDummy(),
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )

        XCTAssertTrue(habitHandler.isEditing)
    }

    func testIfIsEditingHabitFlagIsFalse() {
        let habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: nil,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )

        XCTAssertFalse(habitHandler.isEditing, "The view model shouldn't be editing any habit, none was passed.")
    }

    func testIfHabitCanBeDeletedReturnsFalse() {
        // Declare the view model.
        let habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: nil,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )

        XCTAssertFalse(habitHandler.canDeleteHabit, "The habit can't be deleted, since there isn't one being edited.")
    }

    func testIfHabitCanBeDeleted() {
        // Declare the view model.
        let habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: habitFactory.makeDummy(),
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )

        XCTAssertTrue(habitHandler.canDeleteHabit, "The view model should be able to delete the habit")
    }
}
