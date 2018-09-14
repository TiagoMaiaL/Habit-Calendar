//
//  UserStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 11/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Habit_Calendar

/// Class in charge of testing the UserStorage methods.
class UserStorageTests: IntegrationTestCase {

    // MARK: Properties

    /// The storage to be tested.
    var userStorage: UserStorage!

    // MARK: setup/tearDown

    override func setUp() {
        super.setUp()

        // Initialize userStorage using the persistent container created for tests.
        userStorage = UserStorage()
    }

    override func tearDown() {
        // Remove the initialized storage class.
        userStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testUserCreation() {
        let user = userStorage.create(using: context)
        XCTAssertNotNil(
            user.createdAt,
            "The user created property should be declared."
        )
        XCTAssertNotNil(
            user.id,
            "User should have an id."
        )
    }

    func testUserRetrieval() {
        var user = userStorage.getUser(using: context)

        // Since there isn't a created user, it should return nil.
        XCTAssertNil(
            user,
            "No user shoud be fetched, since no user was created."
        )

        // Generate an user dummy and Hold the userId to compare
        // with the retrieved one.
        let userId = userFactory.makeDummy().id

        // Get the previously created user.
        user = userStorage.getUser(using: context)

        // The previously created user should now be returned:
        XCTAssertNotNil(
            user,
            "A user should be fetched from the getUser() method."
        )

        // Check if the retrieved user is the same
        // as the previously created one.
        XCTAssertEqual(
            user?.id,
            userId,
            "The fetched user's id should be equal to the id of the previously created user."
        )
    }

    func testUserDeletion() {
        // Create a dummy user to be deleted.
        _ = userFactory.makeDummy()

        // Delete the user.
        userStorage.delete(from: context)
        // Check the return of the fetch method.
        let user = userStorage.getUser(using: context)

        XCTAssertNil(
            user,
            "The created user should be deleted."
        )
    }
}
