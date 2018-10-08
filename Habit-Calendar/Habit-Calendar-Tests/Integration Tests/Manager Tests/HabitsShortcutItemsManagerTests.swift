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

        // Instantiate the manager to be tested.
        manager = HabitsShortcutItemsManager(application: UIApplication.shared)
    }

    override func tearDown() {
        // Remove the manager.
        manager = nil

        super.tearDown()
    }

    // MARK: Tests
}
