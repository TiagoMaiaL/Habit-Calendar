//
//  HabitDayStorage.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 26/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
import CoreData
@testable import Active

/// Class in charge of testing the HabitDayStorage methods.
class HabitDayStorageTests: IntegrationTestCase {
    
    // MARK: Properties
    
    /// The day storage to be used.
    var dayStorage: DayStorage!
    
    /// The habit day storage to be tested.
    var habitDayStorage: HabitDayStorage!
    
    // MARK: setup/teardown
    
    override func setUp() {
        super.setUp()
        
        // Initialize the Day storage.
        dayStorage = DayStorage(
            container: memoryPersistentContainer
        )
        
        // Initialize the HabitDay storage.
        habitDayStorage = HabitDayStorage(
            container: memoryPersistentContainer,
            calendarDayStorage: dayStorage
        )
    }
    
    override func tearDown() {
        // Remove the initialized storage class.
        habitDayStorage = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testDaysCreationByPassingTheDaysDatesAndHabit() {
        // 1. Test the creation of HabitDay entities by passing the habits and days.
        XCTFail("Not implemented.")
        
        
    }
    
    func testCreationByPassingTheDayAndHabit() {
        // 1.1 Test the creation of a new HabitDay entity by passing a Day and Habit entity.
        XCTFail("Not implemented.")
    }
    
    func testEditionToMarkHabitAsExecutedAtTheDay() {
        // 2. Test the edition to mark the habit as executed at the specific HabitDay.
        XCTFail("Not implemented.")
    }
    
    func testEditionToMarkHabitAsNotExecutedAtTheDay() {
        // 2.1 Test the edition to mark the habit as not executed at the specific HabitDay.
        XCTFail("Not implemented.")
    }
    
    func testRemovalFromHabit() {
        // 3. Test the removal of a HabitDay from a habit.
        XCTFail("Not implemented.")
    }
}
