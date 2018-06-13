//
//  HabitStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 13/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Active

/// Class in charge of testing the HabitStorage methods.
class HabitStorageTests: StorageTestCase {
    
    // MARK: Properties
    
    var habitStorage: HabitStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize dayStorage using the persistent container created for tests.
        habitStorage = HabitStorage(container: memoryPersistentContainer)
    }
    
    override func tearDown() {
        // Remove the initialized storage class.
        habitStorage = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testHabitCreation() {
        // TODO:
        // Declare the habit's name.
        // Declare the habit's color.
        // Declare the habit's dates.
        
        let name = "Go jogging"
        let color = Habit.Color.blue
//        let dates = (0...7).map { dayNumber in
//            // Create and return a date by adding the number of days.
//            Date().byAddingNumberOfDays(dayNumber)
//        }
        
        // Create the habit.
        
        // Check the habit's id property.
        // Check the habit's name.
        // Check the habit's color property.
        // Check the habit's created property.
        
        // Check the habit's days.
    }
    
    func testHabitFetch() {
        // TODO:
        // Create a habit.
        // Try to fetch the created habit.
        // Check the ids.
    }
    
    func testHabitFetchedResultsControllerFactory() {
        // TODO:
    }
    
    func testHabitEditionWithNameProperty() {
        // TODO:
    }
    
    func testHabitEditionWithColorProperty() {
        // TODO:
    }
    
    func testHabitEditionWithDaysProperty() {
        // TODO:
    }
    
    func testHabitEditionWithNotificationProperty() {
        // TODO:
    }
    
    func testHabitDeletion() {
        // TODO:
        // Create a new habit.
        // Delete the created habit.
        // Try to fetch the previously created habit.
        // The result should be nil.
    }
}
