//
//  UserStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 11/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Active

/// Class in charge of testing the UserStorage methods.
class UserStorageTests: StorageTestCase {

    // MARK: Properties
    
    var userStorage: UserStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize userStorage using the persistent container created for tests.
        userStorage = UserStorage(container: memoryPersistentContainer)
    }
    
    override func tearDown() {
        // Remove the initialized storage class.
        userStorage = nil
        
        super.tearDown()
    }
    
    // MARK: Tests

    func testUserCreation() {
        let user = userStorage.create()
        XCTAssertNotNil(user.created, "Failed: User creation.")
        XCTAssertNotNil(user.id, "Failed: User should have an id.")
    }
    
    func testUserRetrieval() {
        var user = userStorage.getUser()
        
        // Since there isn't a created user, it should return nil.
        XCTAssertNil(user, "Failed: No user shoud be fetched, since no user was created.")
        
        // Create a new user and Hold the userId to compare
        // with the retrieved user's one.
        let userId = userStorage.create().id
        
        // Get the previously created user.
        user = userStorage.getUser()
        // Get the retrieved user's id for comparision purposes.
        let fetchedUserId: String? = user?.id
        
        // The previously created user should now be returned:
        XCTAssertNotNil(user, "Failed: A user should be fetched from the getUser() method.")
        // Check if the retrieved user is the same
        // as the previously created one.
        XCTAssertEqual(userId, fetchedUserId, "Failed: The fetched user's id should be equal to the id of the previously created user.")
    }
    
    func testUserDeletion() {
        // Create the user to be deleted.
        _ = userStorage.create()
        // Delete the user.
        userStorage.delete()
        // Check the return of the fetch method.
        let user = userStorage.getUser()
        
        XCTAssertNil(user ?? nil, "Failed: The created user should be deleted.")
    }
    
    // TODO: Consider adding a new test to test the relationship with Habit entities.
}
