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
        let habitHandler = makeHabitHandlingViewModel(habit: habitFactory.makeDummy())

        XCTAssertTrue(habitHandler.isEditing)
    }

    func testIfIsEditingHabitFlagIsFalse() {
        let habitHandler = makeHabitHandlingViewModel()

        XCTAssertFalse(habitHandler.isEditing, "The view model shouldn't be editing any habit, none was passed.")
    }

    func testIfHabitCanBeDeletedReturnsFalse() {
        let habitHandler = makeHabitHandlingViewModel()

        XCTAssertFalse(habitHandler.canDeleteHabit, "The habit can't be deleted, since there isn't one being edited.")
    }

    func testIfHabitCanBeDeleted() {
        let habitHandler = makeHabitHandlingViewModel(habit: habitFactory.makeDummy())

        XCTAssertTrue(habitHandler.canDeleteHabit, "The view model should be able to delete the habit")
    }

    func testGettingNameShouldReturnNothing() {
        let habitHandler = makeHabitHandlingViewModel()

        XCTAssertNil(
            habitHandler.getHabitName(),
            "The habit name should be nil, since there's no habit in the view model"
        )
    }

    func testGettingNameShouldReturnThePassedHabitName() {
        let dummyHabit = habitFactory.makeDummy()
        let habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)
        XCTAssertEqual(
            dummyHabit.name,
            habitHandler.getHabitName(),
            "The name returned from the view model should match the habit one."
        )
    }

    func testGettingNameShouldReturnThePassedOne() {
        var habitHandler = makeHabitHandlingViewModel()
        let name = "the name of the habit"
        habitHandler.setHabitName(name)

        XCTAssertEqual(name, habitHandler.getHabitName(), "The view model's name should match the setted one.")
    }

    func testSettingNameShouldOverrideTheHabitOne() {
        var habitHandler = makeHabitHandlingViewModel(habit: habitFactory.makeDummy())
        let name = "The new name of the habit"
        habitHandler.setHabitName(name)

        XCTAssertEqual(
            name,
            habitHandler.getHabitName(),
            "The view model's name should match the setted one, overriding the one from the associated habit."
        )
    }

    func testGettingColorShouldReturnNil() {
        let habitHandler = makeHabitHandlingViewModel()

        XCTAssertNil(habitHandler.getHabitColor(), "The habit view model is empty and shouldn't return the color.")
    }

    func testGettingColorShouldReturnTheHabitProperty() {
        let dummyHabit = habitFactory.makeDummy()
        let habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)

        XCTAssertEqual(
            dummyHabit.getColor(),
            habitHandler.getHabitColor(),
            "The view model color property should match the habit one."
        )
    }

    func testGettingColorShouldReturnTheSettedOne() {
        var habitHandler = makeHabitHandlingViewModel()
        let color = HabitMO.Color.systemBlue
        habitHandler.setHabitColor(color)

        XCTAssertEqual(color, habitHandler.getHabitColor(), "The color property should match the setted one.")
    }

    func testSettingColorShouldOverrideTheHabitOne() {
        var habitHandler = makeHabitHandlingViewModel(habit: habitFactory.makeDummy())
        let color = HabitMO.Color.systemPink
        habitHandler.setHabitColor(color)

        XCTAssertEqual(
            color,
            habitHandler.getHabitColor(),
            "Setting the color property should override the habit one."
        )
    }

    func testGettingDaysShouldReturnNil() {
        let habitHandler = makeHabitHandlingViewModel()
        XCTAssertNil(habitHandler.getSelectedDays(), "An empty habit handler shouldn't return any days.")
    }

    func testPassingHabitWontChangeTheDaysPropertyOfTheViewModel() {
        let dummyHabit = habitFactory.makeDummy()
        let habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)

        XCTAssertNil(
            habitHandler.getSelectedDays(),
            "The view model shouldn't take the habit days into account, in case the habit is being edited."
        )
    }

    func testGettingDaysShouldReturnTheSettedOnes() {
        var habitHandler = makeHabitHandlingViewModel()
        let days = [Date(), Date().byAddingDays(2), Date().byAddingDays(-5)].compactMap {$0}
        habitHandler.setDays(days)

        XCTAssertEqual(
            Set(habitHandler.getSelectedDays() ?? []),
            Set(days),
            "The view model should return the days previously setted."
        )
    }

    func testGettingFireTimeComponentsShouldReturnNil() {
        let habitHandler = makeHabitHandlingViewModel()
        XCTAssertNil(habitHandler.getFireTimeComponents(), "An empty view model shouldn't return any fire times.")
    }

    func testGettingFireTimeComponentsShouldReturnTheSettedOnes() {
        var habitHandler = makeHabitHandlingViewModel()
        let components = [DateComponents(hour: 15, minute: 30), DateComponents(hour: 16, minute: 0)]
        habitHandler.setSelectedFireTimes(components)

        XCTAssertEqual(
            habitHandler.getFireTimeComponents(),
            components,
            "The view model should return the previously setted fire times."
        )
    }

    func testGettingFireTimeComponentsShouldReturnTheHabitOnes() {
        let dummyHabit = habitFactory.makeDummy()
        guard let fireTimes = dummyHabit.fireTimes as? Set<FireTimeMO> else {
            XCTFail("Couldn't get the fire times from the dummy habit.")
            return
        }
        let habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)

        let components = fireTimes.map { $0.getFireTimeComponents() }

        XCTAssertEqual(
            Set(habitHandler.getFireTimeComponents() ?? []),
            Set(components),
            "The view model's components should match the ones from the passed habit."
        )
    }

    func testSettingFireTimeComponentsShouldOverrideTheHabitOnes() {
        let dummyHabit = habitFactory.makeDummy()
        var habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)

        let components = [DateComponents(hour: 12, minute: 0), DateComponents(hour: 12, minute: 30)]
        habitHandler.setSelectedFireTimes(components)

        XCTAssertEqual(
            habitHandler.getFireTimeComponents(),
            components,
            "The view model should override the habit fire time components by using the passed ones."
        )
    }

    // MARK: Imperatives

    /// Instantiates and returns an object conforming to the HabitHandlingViewModel protocol. This object is tested
    /// under the protocol interface.
    /// - Note: Any object conforming to the HabitHandlingViewModel protocol can be tested under this test suite.
    /// - Parameter habit: the habit entity associated with the view model.
    private func makeHabitHandlingViewModel(habit: HabitMO? = nil) -> HabitHandlingViewModel {
        return HabitHandlerViewModel(
            habit: habit,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer
        )
    }
}
