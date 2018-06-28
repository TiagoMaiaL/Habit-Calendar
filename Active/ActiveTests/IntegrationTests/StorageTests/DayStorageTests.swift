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
class DayStorageTests: IntegrationTestCase {
    
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
        XCTAssertEqual(
            day.date,
            dayDate,
            "The created Day entity should have the correct date property."
        )
        XCTAssertNotNil(
            day.id,
            "The created Day entity should have an id."
        )
    }
    
    // TODO: Creating a day twice should throw an exception.
    
    func testSpecificDayFetching() {
        // Create the dummy day and hold its date for comparision.
        guard let date = factories.day.makeDummy().date else {
            XCTFail("The day dummy lacks the date property.")
            return
        }
        
        // Fetch the generated dummy.
        let fetchedDay = dayStorage.day(for: date)
        
        // Assert that the fetched day's date is right.
        XCTAssertNotNil(
            fetchedDay,
            "The created day should be correctly fetched."
        )
        XCTAssertEqual(
            date,
            fetchedDay?.date, "The fetched Day's date should be correct."
        )
    }
    
    func testDayDeletion() {
        // Create a dummy day and hold its date for fetching.
        let dummyDay = factories.day.makeDummy()
        guard let date = dummyDay.date else {
            XCTFail("The day dummy lacks the date property.")
            return
        }
        
        // Fetch the dummy day and ensure it's returned.
        XCTAssertNotNil(
            dayStorage.day(for: date),
            "The created dummy should be correclty fetched before the deletion."
        )
        
        // Delete the created entity.
        dayStorage.delete(day: dummyDay)
        
        // Try to fetch the dummy day again, now it shouldn't be fetched.
        XCTAssertNil(
            dayStorage.day(for: date),
            "The deleted Day's fetch attempt should return nil."
        )
    }
    
}

