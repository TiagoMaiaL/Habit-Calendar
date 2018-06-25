//
//  HabitTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 25/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData
import XCTest
@testable import Active

/// Class in charge of testing the Habit core data entity methods.
class HabitTests: IntegrationTestCase {
    
    // MARK: Tests
 
    func testHabitTitleText() {
        // Declare the expected habit name which should be presented as the title.
        let habitName = "Read more"
        
        // Create a dummy Habit.
        guard let dummyHabit = factories.habit.makeDummy() as? Habit else {
            XCTFail("Dummy habit couldn't be generated.")
            return
        }
        dummyHabit.name = habitName
        
        // Get the title text.
        let title = dummyHabit.getTitleText()
        
        // Assert it's the expected title.
        XCTAssertEqual(title, habitName)
    }
    
    func testHabitSubtitleText() {
        // Declare the expected subtitle message.
        let expectedSubtitle = "Have you practiced this activity?"
        
        // Create a dummy habit.
        guard let dummyHabit = factories.habit.makeDummy() as? Habit else {
            XCTFail("Dummy habit couldn't be generated.")
            return
        }
        
        // Assert the habit's subtitle is the expected one.
        XCTAssertEqual(dummyHabit.getSubtitleText(), expectedSubtitle)
    }
    
    func testHabitScoreMechanism() {
        XCTFail("Not implemented.")
    }
    
    func testHabitDescriptionText() {
        XCTFail("Not implemented.")
    }
}
