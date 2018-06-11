//
//  UserStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 11/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import XCTest
import CoreData
@testable import Active

/// In charge of testing the UserStorage methods.
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
    
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    func testUserCreation() {
        let user = userStorage.create()
        XCTAssertNotNil(user.created, "Failed: User creation.")
        XCTAssertNotNil(user.id, "Failed: User should have an id.")
    }
    
    func testUserRetrieval() {
        var user = try? userStorage.getUser()
        
        // FIXME: XCTAssertions don't work well with optionals. find a better alternative to test these values.
        
        // Since there isn't a created user, it should return nil.
        XCTAssertNil(user ?? nil, "Failed: No user shoud be fetched, since no user was created.")
        
        // Create a new user.
        _ = userStorage.create()
        user = try? userStorage.getUser()
        
        // The previously created user should now be returned:
        XCTAssertNotNil(user ?? nil, "Failed: A user should be fetched from the getUser() method.")
    }
    
    func testUserDeletion() {
        // Create the user to be deleted.
        _ = userStorage.create()
        // Delete the user.
        userStorage.delete()
        // Check the return of the fetch method.
        let user = try? userStorage.getUser()
        
        XCTAssertNil(user ?? nil, "Failed: The created user should be deleted.")
    }
    
}
