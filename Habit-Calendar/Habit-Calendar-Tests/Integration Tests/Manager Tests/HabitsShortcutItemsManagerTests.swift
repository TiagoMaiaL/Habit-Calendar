//
//  HabitsShortcutItemsManagerTests.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 08/10/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
@testable import Habit_Calendar

/// Class in charge of testing the interface of the HabitsShortcutItemsManager.
class HabitsShortcutItemsManagerTests: IntegrationTestCase {

    // MARK: Properties

    /// The manager being tested.
    private var manager: HabitsShortcutItemsManager!

    // MARK: SetUp / Teardown

    override func setUp() {
        super.setUp()

        // Reset the shortcuts of the app.
        UIApplication.shared.shortcutItems = []

        // Instantiate the manager to be tested.
        manager = HabitsShortcutItemsManager(application: UIApplication.shared)
    }

    override func tearDown() {
        // Remove the manager.
        manager = nil

        super.tearDown()
    }

    // MARK: Tests

    func testAddingFirstApplicationShortcutItemForHabit() {
        // 1. Generate a dummy habit.
        let dummyHabit = habitFactory.makeDummy()

        // 2. Add a new shortcut assiciated with the dummy habit to the app by using the manager.
        manager.addApplicationShortcut(for: dummyHabit)

        // 3. Assert on the identifiers of the manager,
        //    and assert on the shortcut items of the application.
        XCTAssertEqual(manager.habitIdentifiers.count, 1)
        XCTAssertEqual(manager.habitIdentifiers.first, dummyHabit.id)

        guard let shortcuts = UIApplication.shared.shortcutItems else {
            XCTFail("Couldn't get the shortcut items of the application.")
            return
        }
        guard shortcuts.count == 1 else {
            XCTFail("The shortcut item didn't get registered.")
            return
        }
        let shortcut = shortcuts.first!

        XCTAssertEqual(shortcut.localizedTitle, dummyHabit.getTitleText())
        XCTAssertEqual(shortcut.type, AppDelegate.QuickActionType.displayHabit.rawValue)

        XCTAssertNotNil(shortcut.userInfo)
        XCTAssertEqual(
            shortcut.userInfo?[HabitsShortcutItemsManager.habitIdentifierUserInfoKey] as? String,
            dummyHabit.id
        )
    }

    func testAddingNewShortcutItemForHabitWhenOtherShortcutsDoAlreadyExist() {
        // 1. Configure the manager with a dummy habit.
        manager.addApplicationShortcut(for: habitFactory.makeDummy())

        // 2. Declare a new dummy, and add it to the manager.
        let dummyHabit = habitFactory.makeDummy()
        manager.addApplicationShortcut(for: dummyHabit)

        // 3. The first shortcut should be related to the last habit that was added.
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 2)
        XCTAssertEqual(UIApplication.shared.shortcutItems?.first?.localizedTitle, dummyHabit.getTitleText())
    }

    func testAddingNewShortcutShouldRespectTheLimitOfItems() {
        // 1. Configure the manager with 4 dummy habits (the maximum).
        let limit = HabitsShortcutItemsManager.shortcutItemsLimit
        for _ in 0..<limit {
            manager.addApplicationShortcut(for: habitFactory.makeDummy())
        }

        // 2. Declare a new dummy, add it to the manager.
        let dummyHabit = habitFactory.makeDummy()
        manager.addApplicationShortcut(for: dummyHabit)

        // 3. The habit should be added as the first item and the last item should be removed,
        // because the limit was reached.
        XCTAssertEqual(manager.habitIdentifiers.count, limit)
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, limit)
        XCTAssertEqual(manager.habitIdentifiers.first, dummyHabit.id)
        XCTAssertEqual(
            UIApplication.shared.shortcutItems?.first?.localizedTitle,
            dummyHabit.getTitleText()
        )
    }

    func testRemovingShortcutAssociatedWithHabit() {
        XCTMarkNotImplemented()
    }
}
