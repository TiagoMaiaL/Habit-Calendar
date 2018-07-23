//
//  HabitTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 25/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import XCTest
@testable import Active

/// Class in charge of testing the Habit core data entity methods.
class HabitTests: IntegrationTestCase {
    
    // MARK: Properties
    
    var habitDayStorage: HabitDayStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize the habitDayStorage.
        habitDayStorage = HabitDayStorage(calendarDayStorage: DayStorage())
    }
    
    override func tearDown() {
        // Remove the HabitDayStorage.
        habitDayStorage = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
 
    func testTitleText() {
        // Declare the expected habit name which should be presented as the title.
        let habitName = "Read more"
        
        // Create a dummy Habit.
        let dummyHabit = factories.habit.makeDummy()
        dummyHabit.name = habitName
        
        // Get the title text.
        let title = dummyHabit.getTitleText()
        
        // Assert it's the expected title.
        XCTAssertEqual(title, habitName)
    }
    
    func testSubtitleText() {
        // Declare the expected subtitle message.
        let expectedSubtitle = "Have you practiced this activity?"
        
        // Create a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // Assert the habit's subtitle is the expected one.
        XCTAssertEqual(dummyHabit.getSubtitleText(), expectedSubtitle)
    }
    
    func testFetchForExecutedDays() {
        // 1. Declare a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // 2. Declare the habitDays to be added to the habit.
        let dates = (1...63).compactMap { dayIndex -> Date? in
            Date().byAddingDays(dayIndex)
        }
        
        XCTAssert(
            dates.count == 63,
            "Couldn't correctly generate the dates."
        )
        
        let habitDays = habitDayStorage.createDays(
            using: context,
            dates: dates,
            and: dummyHabit
        )
        
        // 3. Mark some of them as executed and add them
        //    to a set.
        var executedDays = Set<HabitDayMO>()
        
        for index in 0..<37 {
            let habitDay = habitDays[index]
            habitDay.markAsExecuted()
            executedDays.insert(habitDay)
        }
        
        // 4. Check to see if the fetch returns the correct
        //    amount of habitDays.
        XCTAssertEqual(
            dummyHabit.executedCount,
            executedDays.count,
            "The habit's count of the executed days is incorrect."
        )
    }
    
    func testPercentageExecutionProperty() {
        // 1. Declare the number of days.
        let numberOfDays = Int.random(2..<26)
        // 1.1. Declare the number of executed days.
        let numberOfExecutedDays = Int.random(0..<numberOfDays)
        // 1.2. Declare the expected percentage.
        let executionPercentage = (Double(numberOfExecutedDays) / Double(numberOfDays)) * 100
        
        // 2. Declare a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        // 2.1. Clear the dummy days that come with the habit.
        if let days = dummyHabit.days as? Set<HabitDayMO> {
            for habitDay in days {
                dummyHabit.removeFromDays(habitDay)
            }
        }
        
        // 3. Declare the habitDays to be added to the habit.
        let dates = (1...numberOfDays).compactMap { dayIndex -> Date? in
            Date().byAddingDays(dayIndex)
        }
        XCTAssert(
            dates.count == numberOfDays,
            "Couldn't correctly generate the dates."
        )
        
        let habitDays = habitDayStorage.createDays(
            using: context,
            dates: dates,
            and: dummyHabit
        )
        
        // 3.1. Declare 10 of the habit Days as executed.
        for index in 0..<numberOfExecutedDays {
            let habitDay = habitDays[index]
            habitDay.markAsExecuted()
        }
        
        // 4. Assert the returned percentage from the
        //    model is correct.
        XCTAssertEqual(
            executionPercentage,
            dummyHabit.executionPercentage,
            "The execution percentage is not the expected one."
        )
    }
    
    func testDescriptionText() {
        XCTMarkNotImplemented()
    }
    
    func testGettingCurrentHabitDay() {
        // Create an empty dummy habit.
        let dummyHabit = makeEmptyDummy()
        
        // Add a habit day to it.
        let dummyDay = factories.day.makeDummy()
        let dummyHabitDay = factories.habitDay.makeDummy()
        
        dummyHabitDay.day = dummyDay
        dummyHabitDay.habit = dummyHabit
        
        // Check if it returns the current habit day (corresponding to today).
        XCTAssertNotNil(
            dummyHabit.getCurrentDay(),
            "There should be a current habit day being tracked."
        )
    }
    
    func testGettingCurrentHabitDayShouldReturnNil() {
        // Create an empty dummy habit.
        let dummyHabit = makeEmptyDummy()
        
        // Check if it returns the current habit day (corresponding to today).
        XCTAssertNil(
            dummyHabit.getCurrentDay(),
            "There shouldn't be a current habit day being tracked."
        )
    }
    
    func testFetchingFutureDays() {
        // Declare a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // Get its future days by filtering through them.
        guard let futureDays = (dummyHabit.days as? Set<HabitDayMO>)?.filter({ $0.day?.date?.isFuture ?? false }) else {
            XCTFail("Couldn't get the future days only.")
            return
        }
        
        // Compare the count with the one returned by
        // the entity's method (getFutureDays).
        XCTAssertEqual(
            futureDays.count,
            dummyHabit.getFutureDays().count,
            "The method should return the correct amount of future habit day entities."
        )
    }
    
    func testGettingCurrentSequenceShouldReturnNil() {
        // 1. Declare an empty habit.
        let emptyHabit = makeEmptyDummy()
        
        // 2. Assert is current sequence is nil.
        XCTAssertNil(
            emptyHabit.getCurrentSequence(),
            "An empty habit shouldn't return any current sequence."
        )
    }
    
    func testGettingTheOnlyCurrentSequence() {
        // 1. Declare an empty habit.
        let emptyHabit = makeEmptyDummy()
        
        // 2. Add a DaysSequence to it.
        let sequenceFactory = DaysSequenceFactory(context: context)
        let sequence = sequenceFactory.makeDummy()
        emptyHabit.addToDaysSequences(sequence)
        
        // 3. Assert it's returned when getting the current sequence.
        XCTAssertEqual(
            emptyHabit.getCurrentSequence(),
            sequence,
            "The current sequence should be correctly returned."
        )
    }
    
    func testGettingTheCurrentSequenceAmongMany() {
        // 1. Declare an empty habit.
        let emptyHabit = makeEmptyDummy()
        
        // 2. Add 3 DaysSequence entities to it.
        let sequence1 = DaysSequenceMO(context: context)
        sequence1.fromDate = Date().byAddingDays(-60)!.getBeginningOfDay()
        sequence1.toDate = Date().byAddingDays(-50)!.getBeginningOfDay()
        
        let sequence2 = DaysSequenceMO(context: context)
        sequence2.fromDate = Date().byAddingDays(-48)!.getBeginningOfDay()
        sequence2.toDate = Date().byAddingDays(-30)!.getBeginningOfDay()
        
        let currentSequence = DaysSequenceMO(context: context)
        currentSequence.fromDate = Date().getBeginningOfDay()
        currentSequence.toDate = Date().byAddingDays(10)!.getBeginningOfDay()
        
        emptyHabit.addToDaysSequences(
            [sequence1, sequence2, currentSequence]
        )
        
        // 3. Assert it returns the current and correct one.
        XCTAssertEqual(
            emptyHabit.getCurrentSequence(),
            currentSequence,
            "The habit should return its current sequence among all of the added ones."
        )
    }
    
    // MARK: Imperatives
    
    private func makeEmptyDummy() -> HabitMO {
        let habit = HabitMO(context: context)
        // Associate it's properties (id, created, name, color).
        habit.id = UUID().uuidString
        habit.createdAt = Date()
        habit.name = "Random habit name"
        habit.color = HabitMO.Color.blue.rawValue
        
        return habit
    }
    
}
