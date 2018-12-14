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
        // Clear the shortcuts.
        UIApplication.shared.shortcutItems = []

        // Create a new item for a dummy habit.
        let dummyHabit = habitFactory.makeDummy()
        shortcutsManager.addApplicationShortcut(for: dummyHabit)

        guard !(UIApplication.shared.shortcutItems ?? []).isEmpty else {
            XCTFail("The shorcuts manager didn't add the expected item. It's impossible to continue this test.")
            return
        }

        // Remove the habit.
        let habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)
        habitHandler.deleteHabit()

        // Assert that its shortcut item was removed as well.
        XCTAssertTrue(
            UIApplication.shared.shortcutItems?.isEmpty ?? true,
            "The shortcut should be removed with the habit."
        )
    }

    func testIsValidShouldBeFalseWhenEmpty() {
        XCTAssertFalse(makeHabitHandlingViewModel().isValid)
    }

    func testIsValidShouldBeFalseWhenOnlyNameIsProvided() {
        var habitHandler = makeHabitHandlingViewModel()
        habitHandler.setHabitName("testing validation")

        XCTAssertFalse(habitHandler.isValid)
    }

    func testIsValidShouldBeFalseWhenOnlyColorIsProvided() {
        var habitHandler = makeHabitHandlingViewModel()
        habitHandler.setHabitColor(HabitMO.Color.systemGreen)

        XCTAssertFalse(habitHandler.isValid)
    }

    func testIsValidShouldBeTrueWhenColorAndNameAreProvided() {
        var habitHandler = makeHabitHandlingViewModel()
        habitHandler.setHabitName("testing validation")
        habitHandler.setHabitColor(HabitMO.Color.systemGreen)

        XCTAssertTrue(habitHandler.isValid)
    }

    func testCreatingHabit() {
        let creationExpectation = XCTestExpectation(description: "Test the creation of the habit.")

        // Create an app user and save it.
        _ = userFactory.makeDummy()
        try? context.save()

        // Create the habit handler view model without a habit (it's going to create a new one).
        let name = "Swim"
        let color = HabitMO.Color.systemBlue

        var habitHandler = makeHabitHandlingViewModel()
        habitHandler.setHabitName(name)
        habitHandler.setHabitColor(color)

        habitHandler.saveHabit()

        // Ensure it was created and assert on its properties.
        // Since the save operation is async, use a timer to make the assertions.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            guard let createdHabit = self.fetchFirstHabit() else {
                XCTFail("The habit should have been created.")
                creationExpectation.fulfill()
                return
            }

            XCTAssertEqual(createdHabit.name, name)
            XCTAssertEqual(createdHabit.color, color.rawValue)

            creationExpectation.fulfill()
        }

        wait(for: [creationExpectation], timeout: 0.2)
    }

    func testCreatingHabitShouldAddShortcutItem() {
        let shortcutExpectation = XCTestExpectation(description: "Shortcut items need to be added for the habit.")

        // Clear the application shortcut items.
        UIApplication.shared.shortcutItems = []

        // Add the main user to the app.
        _ = userFactory.makeDummy()
        try? context.save()

        var habitHandler = makeHabitHandlingViewModel()
        habitHandler.setHabitName("test")
        habitHandler.setHabitColor(.systemBlue)

        habitHandler.saveHabit()

        // Ensure a new shortcut item was added.
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
            XCTAssertTrue((UIApplication.shared.shortcutItems?.count ?? 0) == 1)
            shortcutExpectation.fulfill()
        }

        wait(for: [shortcutExpectation], timeout: 0.2)
    }

    func testCreatingHabitWithChallenge() {
        let creationExpectation = XCTestExpectation(
            description: "Test the creation of a habit with a challenge of days."
        )

        // Add the main user to the app.
        _ = userFactory.makeDummy()
        try? context.save()

        var habitHandler = makeHabitHandlingViewModel()
        habitHandler.setHabitColor(.systemGreen)
        habitHandler.setHabitName("testing challenge creation")
        let days = (0...5).compactMap { Date().byAddingDays($0)?.getBeginningOfDay() }
        habitHandler.setDays(days)

        habitHandler.saveHabit()

        // Ensure the challenge was correclty created.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            guard let createdHabit = self.fetchFirstHabit() else {
                XCTFail("The habit should have been created.")
                creationExpectation.fulfill()
                return
            }

            guard let challenge = createdHabit.getCurrentChallenge() else {
                XCTFail("The challenge should have been created.")
                creationExpectation.fulfill()
                return
            }

            XCTAssertEqual(days.count, challenge.days?.count)

            creationExpectation.fulfill()
        }

        wait(for: [creationExpectation], timeout: 0.2)
    }

    func testCreatingHabitWithFireTimes() {
        let creationExpectation = XCTestExpectation(
            description: "Test the creation of a habit with the selected fire times."
        )

        // Add the main user to the app.
        _ = userFactory.makeDummy()
        try? context.save()

        var habitHandler = makeHabitHandlingViewModel()
        habitHandler.setHabitName("name")
        habitHandler.setHabitColor(.systemRed)
        let fireTimes = [
            DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, hour: 12, minute: 0),
            DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, hour: 23, minute: 30)
        ]
        habitHandler.setSelectedFireTimes(fireTimes)

        habitHandler.saveHabit()

        // Ensure the fire times were correclty added.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            guard let createdHabit = self.fetchFirstHabit() else {
                XCTFail("The habit should have been created.")
                creationExpectation.fulfill()
                return
            }

            guard let fireTimeEntities = createdHabit.fireTimes as? Set<FireTimeMO>,
                !fireTimeEntities.isEmpty else {
                    XCTFail("The fire times should have been created.")
                    creationExpectation.fulfill()
                    return
            }
            let components = fireTimeEntities.map { $0.getFireTimeComponents() }

            XCTAssertEqual(Set(fireTimes), Set(components))

            creationExpectation.fulfill()
        }

        wait(for: [creationExpectation], timeout: 0.2)
    }

    func testIfEditionIsNotValidWithEmptyViewModel() {
        XCTAssertFalse(makeHabitHandlingViewModel(habit: habitFactory.makeDummy()).isValid)
    }

    func testIfEditionIsValidWhenOnlyNameChanges() {
        var habitHandler = makeHabitHandlingViewModel(habit: habitFactory.makeDummy())
        habitHandler.setHabitName("new name test")

        XCTAssertTrue(habitHandler.isValid)
    }

    func testIfEditionIsValidWhenOnlyColorChanges() {
        var habitHandler = makeHabitHandlingViewModel(habit: habitFactory.makeDummy())
        habitHandler.setHabitColor(.systemOrange)

        XCTAssertTrue(habitHandler.isValid)
    }

    func testIfEditionIsValidWhenOnlyDaysChange() {
        var habitHandler = makeHabitHandlingViewModel(habit: habitFactory.makeDummy())
        habitHandler.setDays([Date().getBeginningOfDay()])

        XCTAssertTrue(habitHandler.isValid)
    }

    func testIfEditionIsValidWhenOnlyFireTimesChange() {
        var habitHandler = makeHabitHandlingViewModel(habit: habitFactory.makeDummy())
        habitHandler.setSelectedFireTimes([DateComponents()])

        XCTAssertTrue(habitHandler.isValid)
    }

    func testEditingHabitName() {
        let nameEditionExpectation = XCTestExpectation(description: "Editing name")

        let dummyHabit = habitFactory.makeDummy()
        var habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)
        let newName = "new name"
        habitHandler.setHabitName(newName)

        habitHandler.saveHabit()

        // Assert that the name was changed.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            XCTAssertEqual(
                dummyHabit.name?.lowercased(),
                newName,
                "The habit name should have been edited."
            )
            nameEditionExpectation.fulfill()
        }

        wait(for: [nameEditionExpectation], timeout: 0.2)
    }

    func testEditingHabitColor() {
        let colorEditionExpectation = XCTestExpectation(description: "Editing color")

        let dummyHabit = habitFactory.makeDummy()
        var habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)
        let newColor = HabitMO.Color.systemTeal
        habitHandler.setHabitColor(newColor)

        habitHandler.saveHabit()

        // Assert that the color was changed.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            XCTAssertEqual(
                dummyHabit.color,
                newColor.rawValue,
                "The habit color should have been edited."
            )
            colorEditionExpectation.fulfill()
        }

        wait(for: [colorEditionExpectation], timeout: 0.2)
    }

    func testEditingHabitChallenge() {
        let challengeEditionExpectation = XCTestExpectation(description: "Editing challenge of days")

        let dummyHabit = habitFactory.makeDummy()
        // Remove the challenges and days from the dummy.
        if let challenges = dummyHabit.challenges, let days = dummyHabit.days {
            dummyHabit.removeFromChallenges(challenges)
            dummyHabit.removeFromDays(days)
        }

        var habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)

        let newChallengeDays = (0...5).compactMap { Date().getBeginningOfDay().byAddingDays($0) }
        habitHandler.setDays(newChallengeDays)

        habitHandler.saveHabit()

        // Assert that the challenge was changed.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            guard let challenge = dummyHabit.getCurrentChallenge() else {
                XCTFail("Couldn't get the challenge that should have been added.")
                challengeEditionExpectation.fulfill()
                return
            }
            guard let days = challenge.days as? Set<HabitDayMO> else {
                XCTFail("Couldn't get the days of the challenge.")
                challengeEditionExpectation.fulfill()
                return
            }
            let challengeDates = days.compactMap { $0.day?.date }

            XCTAssertEqual(
                Set(challengeDates),
                Set(newChallengeDays),
                "The dates of the challenge entity don't match with the added ones."
            )

            challengeEditionExpectation.fulfill()
        }

        wait(for: [challengeEditionExpectation], timeout: 0.2)
    }

    func testEditingHabitFireTimes() {
        let fireTimesEditionExpectation = XCTestExpectation(description: "Editing challenge of days")

        let dummyHabit = habitFactory.makeDummy()
        // Remove the fire times from the dummy.
        if let fireTimes = dummyHabit.fireTimes {
            dummyHabit.removeFromFireTimes(fireTimes)
        }

        var habitHandler = makeHabitHandlingViewModel(habit: dummyHabit)
        let newFireTimeComponents = [
            DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, hour: 08, minute: 0),
            DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, hour: 12, minute: 0)
        ]
        habitHandler.setSelectedFireTimes(newFireTimeComponents)

        habitHandler.saveHabit()

        // Assert on the fire times.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            guard let fireTimesEntities = dummyHabit.fireTimes as? Set<FireTimeMO> else {
                XCTFail("The challenge should have some fire times.")
                fireTimesEditionExpectation.fulfill()
                return
            }
            let fireTimeComponents = fireTimesEntities.map { $0.getFireTimeComponents() }

            XCTAssertEqual(
                Set(fireTimeComponents),
                Set(newFireTimeComponents),
                "The fire times of the habit entity don't match with the edited ones."
            )

            fireTimesEditionExpectation.fulfill()
        }

        wait(for: [fireTimesEditionExpectation], timeout: 0.2)

    }

    // MARK: Imperatives

    /// Instantiates and returns an object conforming to the HabitHandlerViewModelContract protocol. This object is tested
    /// under the protocol interface.
    /// - Note: Any object conforming to the HabitHandlerViewModelContract protocol can be tested under this test suite.
    /// - Parameter habit: the habit entity associated with the view model.
    private func makeHabitHandlingViewModel(habit: HabitMO? = nil) -> HabitHandlerViewModelContract {
        return HabitHandlerViewModel(
            habit: habit,
            habitStorage: habitStorage,
            userStorage: UserStorage(),
            container: memoryPersistentContainer,
            shortcutsManager: shortcutsManager
        )
    }

    /// Fetches the first habit from the data store.
    /// - Returns: the habit, if one exists.
    private func fetchFirstHabit() -> HabitMO? {
        let request: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()

        do {
            let results = try self.context.fetch(request)
            guard !results.isEmpty else {
                return nil
            }
            return results.first!
        } catch {
            return nil
        }
    }
}
