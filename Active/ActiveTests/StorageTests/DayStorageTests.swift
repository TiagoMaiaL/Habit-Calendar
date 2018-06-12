//
//  DayStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 12/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Active

/// Class in charge of testing the DayStorage methods.
class DayStorageTests: StorageTestCase {
    
    // MARK: Properties
    
    var dayStorage: DayStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize dayStorage using the persistent container created for tests.
        dayStorage = DayStorage(container: memoryPersistentContainer)
    }
    
    override func tearDown() {
        // Remove the initialized storage class.
        dayStorage = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testDayCreation() {
        // Declare the date to be represented by the day entity.
        let dayDate = Date()
        // Create the day by passing the declared date.
        let day = dayStorage.create(withDate: dayDate)
        
        // Assert the day isn't nil and has the correct date.
        XCTAssertEqual(day.date, dayDate, "The created Day entity should have the correct date property.")
        XCTAssertNotNil(day.id, "The created Day entity should have an id.")
    }
    
    func testSpecificDayFetching() {
        // Declare the date to be used to create an
        // entity and fetch the created entity.
        let dayDate = Date()
        
        // Create the day entity.
        _ = dayStorage.create(withDate: dayDate)
        
        // Fetch the created entity.
        let fetchedDay = dayStorage.day(for: dayDate)
        
        // Assert that the fetched day's date is right.
        XCTAssertNotNil(fetchedDay, "The created day should be correctly fetched.")
        XCTAssertEqual(dayDate, fetchedDay?.date, "The fetched Day's date should be correct.")
    }
    
    func testDayDeletion() {
        // Declare the day's date for creation and fetching.
        let dayDate = Date()
        
        // Create a Day entity.
        let createdDay = dayStorage.create(withDate: dayDate)
        // Delete the created entity.
        dayStorage.delete(day: createdDay)
        
        // Try to fetch it.
        let fetchedDay = dayStorage.day(for: dayDate)
        
        // Assert that nothing was fetched.
        XCTAssertNil(fetchedDay, "The deleted Day's fetch attempt should return nil.")
    }
    
}

