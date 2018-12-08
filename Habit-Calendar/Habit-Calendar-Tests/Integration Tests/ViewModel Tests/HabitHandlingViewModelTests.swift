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
    private var habitStorage: HabitStorage!

    /// The manager used to test the adition, removal or edition of shortcuts related to the habits.
    private var shortcutsManager: HabitsShortcutItemsManager!

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

        // Initialize the shortcuts manager.
        shortcutsManager = HabitsShortcutItemsManager(application: UIApplication.shared)

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

    func testGettingTextDescribingNoDaysWereSelected() {
        let habitHandler = makeHabitHandlingViewModel()
        XCTAssertEqual(
            habitHandler.getDaysDescriptionText(),
            "No days were selected.",
            "The text should inform that no days were selected."
        )
    }

    func testGettingTextDescribingHowManyDaysWereSelected() {
        var habitHandler = makeHabitHandlingViewModel()
        let days = (0...Int.random(2..<8)).compactMap { Date().byAddingDays($0)?.getBeginningOfDay() }
        habitHandler.setDays(days)

        XCTAssertEqual(habitHandler.getDaysDescriptionText(), "\(days.count) days selected.")
    }

    func testGettingInitialDateDescriptionText() {
        var habitHandler = makeHabitHandlingViewModel()
        let days = [Date().getBeginningOfDay(), Date().getBeginningOfDay().byAddingDays(1)].compactMap {$0}
        habitHandler.setDays(days)

        XCTAssertEqual(
            habitHandler.getFirstDateDescriptionText(),
            DateFormatter.shortCurrent.string(from: days.first!),
            "View model should return the correct date description in the beginning of the range."
        )
    }

    func testGettingInitialDateDescriptionTextShouldReturnNil() {
        let habitHandler = makeHabitHandlingViewModel()
        XCTAssertNil(habitHandler.getFirstDateDescriptionText())
    }

    func testGettingFinalDateDescriptionText() {
        var habitHandler = makeHabitHandlingViewModel()
        let days = [Date().getBeginningOfDay(), Date().getBeginningOfDay().byAddingDays(5)].compactMap {$0}
        habitHandler.setDays(days)

        XCTAssertEqual(
            habitHandler.getLastDateDescriptionText(),
            DateFormatter.shortCurrent.string(from: days.last!)
        )
    }

    func testGettingLastDateDescriptionTextShouldReturnNil() {
        let habitHandler = makeHabitHandlingViewModel()
        XCTAssertNil(habitHandler.getLastDateDescriptionText())
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

    func testGettingTextDescribingFireTimesReturnsNoneWereSelected() {
        let habitHandler = makeHabitHandlingViewModel()
        XCTAssertEqual(habitHandler.getFireTimesAmountDescriptionText(), "0 fire times selected.")
    }

    func testGettingTextDescribingHowManyFireTimesWereSelected() {
        var habitHandler = makeHabitHandlingViewModel()
        let fireTimes = [DateComponents(hour: 12, minute: 0),
                         DateComponents(hour: 12, minute: 30),
                         DateComponents(hour: 13, minute: 0)]
        habitHandler.setSelectedFireTimes(fireTimes)

        XCTAssertEqual(
            habitHandler.getFireTimesAmountDescriptionText(),
            "\(fireTimes.count) fire times selected."
        )
    }

    func testGettingTextDescribingHowManyFireTimesWereSelectedShouldReturnNil() {
        let habitHandler = makeHabitHandlingViewModel()
        XCTAssertNil(habitHandler.getFireTimesDescriptionText())
    }

    func testGettingTextDescribingHowManyFireTimesWereSelectedForHabit() {
        var habitHandler = makeHabitHandlingViewModel()
        let fireTimes = [DateComponents(hour: 8, minute: 0),
                         DateComponents(hour: 13, minute: 0)]
        habitHandler.setSelectedFireTimes(fireTimes)
        XCTAssertEqual(habitHandler.getFireTimesDescriptionText(), "08:00, 13:00")
    }

    func testDeletingHabit() {
        let dummyHabit = habitFactory.makeDummy()
        dummyHabit.user = userFactory.makeDummy()

        do {
            try context.save()
        } catch {
            print(error)
            XCTFail("Couldn't save the context.")
        }

        let habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)
        habitHandler.deleteHabit()

        XCTAssertTrue(dummyHabit.isDeleted)
    }

    func testDeletingHabitShouldRemoveItsShortcut() {
        UIApplication.shared.shortcutItems = []

        let dummyHabit = habitFactory.makeDummy()
        shortcutsManager.addApplicationShortcut(for: dummyHabit)

        guard !(UIApplication.shared.shortcutItems ?? []).isEmpty else {
            XCTFail("The shorcuts manager didn't add the expected item. It's impossible to continue this test.")
            return
        }

        let habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)
        habitHandler.deleteHabit()

        XCTAssertTrue(
            UIApplication.shared.shortcutItems?.isEmpty ?? true,
            "The shortcut should be removed with the habit."
        )
    }

    func testCreatingHabit() {
        XCTMarkNotImplemented()
    }

    func testCreatingHabitWithChallenge() {
        XCTMarkNotImplemented()
    }

    func testCreatingHabitWithFireTimes() {
        XCTMarkNotImplemented()
    }

    func testEditingHabitName() {
        XCTMarkNotImplemented()
    }

    func testEditingHabitColor() {
        XCTMarkNotImplemented()
    }

    func testEditingHabitChallenge() {
        XCTMarkNotImplemented()
    }

    func testEditingHabitFireTimes() {
        XCTMarkNotImplemented()
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
            container: memoryPersistentContainer,
            shortcutsManager: shortcutsManager
        )
    }
}
