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
        let habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: habitFactory.makeDummy(),
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )

        XCTAssertTrue(habitHandler.canDeleteHabit, "The view model should be able to delete the habit")
    }

    func testGettingNameShouldReturnNothing() {
        let habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: nil,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )

        XCTAssertNil(
            habitHandler.getHabitName(),
            "The habit name should be nil, since there's no habit in the view model"
        )
    }

    func testGettingNameShouldReturnThePassedHabitName() {
        let dummyHabit = habitFactory.makeDummy()
        let habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: dummyHabit,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )
        XCTAssertEqual(
            dummyHabit.name,
            habitHandler.getHabitName(),
            "The name returned from the view model should match the habit one."
        )
    }

    func testGettingNameShouldReturnThePassedOne() {
        var habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: nil,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )
        let name = "the name of the habit"
        habitHandler.setHabitName(name)

        XCTAssertEqual(name, habitHandler.getHabitName(), "The view model's name should match the setted one.")
    }

    func testSettingNameShouldOverrideTheHabitOne() {
        var habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: habitFactory.makeDummy(),
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )
        let name = "The new name of the habit"
        habitHandler.setHabitName(name)

        XCTAssertEqual(
            name,
            habitHandler.getHabitName(),
            "The view model's name should match the setted one, overriding the one from the associated habit."
        )
    }

    func testGettingColorShouldReturnNil() {
        let habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: nil,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )

        XCTAssertNil(habitHandler.getHabitColor(), "The habit view model is empty and shouldn't return the color.")
    }

    func testGettingColorShouldReturnTheHabitProperty() {
        let dummyHabit = habitFactory.makeDummy()
        let habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: dummyHabit,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )

        XCTAssertEqual(
            dummyHabit.getColor(),
            habitHandler.getHabitColor(),
            "The view model color property should match the habit one."
        )
    }

    func testGettingColorShouldReturnTheSettedOne() {
        var habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: nil,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )
        let color = HabitMO.Color.systemBlue
        habitHandler.setHabitColor(color)

        XCTAssertEqual(color, habitHandler.getHabitColor(), "The color property should match the setted one.")
    }

    func testSettingColorShouldOverrideTheHabitOne() {
        var habitHandler: HabitHandlingViewModel = HabitHandlerViewModel(
            habit: habitFactory.makeDummy(),
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )
        let color = HabitMO.Color.systemPink
        habitHandler.setHabitColor(color)

        XCTAssertEqual(
            color,
            habitHandler.getHabitColor(),
            "Setting the color property should override the habit one."
        )
    }
}
