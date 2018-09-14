//
//  FireTimeStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 21/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Habit_Calendar

/// Class in charge of testing the FireTimeStorage methods.
class FireTimeStorageTests: IntegrationTestCase {

    // MARK: Properties

    private var fireTimeStorage: FireTimeStorage!

    // MARK: Setup/TearDown

    override func setUp() {
        super.setUp()

        // Instantiate the storage.
        fireTimeStorage = FireTimeStorage()
    }

    override func tearDown() {
        // Remove the storage.
        fireTimeStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testFireTimeCreation() {
        // 1. Declare the fire time's dependencies used to create
        // the entity:
        // - the components
        // - the dummy habit
        let components = DateComponents(
            hour: Int.random(0..<59),
            minute: Int.random(0..<59)
        )
        let dummyHabit = habitFactory.makeDummy()

        // 2. Create the entity.
        let fireTime = fireTimeStorage.create(
            using: context,
            components: components,
            andHabit: dummyHabit
        )

        // 3. Assert on its properties:
        // id, createdAt, fireHour, fireMinute.
        XCTAssertNotNil(
            fireTime.id,
            "The id shouldn't be nil."
        )
        XCTAssertNotNil(
            fireTime.createdAt,
            "The createdAt shouldn't be nil."
        )
        XCTAssertEqual(
            Int(fireTime.hour),
            components.hour,
            "The FireTime's hour should be equal to the components' one."
        )
        XCTAssertEqual(
            Int(fireTime.minute),
            components.minute,
            "The FireTime's minute should be equal to the components' one."
        )

        // 4. Assert its habit is the dummy one.
        XCTAssertEqual(
            fireTime.habit,
            dummyHabit,
            "The fireTime's habit should be correclty associated."
        )
    }
}
