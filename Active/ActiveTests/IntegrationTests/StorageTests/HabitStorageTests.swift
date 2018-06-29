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
class HabitStorageTests: IntegrationTestCase {
    
    // MARK: Properties
    
    var dayStorage: DayStorage!
    
    var habitDayStorage: HabitDayStorage!
    
    var habitStorage: HabitStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize the DayStorage.
        dayStorage = DayStorage(container: memoryPersistentContainer)
        
        // Initialize the HabitDayStorage.
        habitDayStorage = HabitDayStorage(
            container: memoryPersistentContainer,
            calendarDayStorage: dayStorage
        )
        
        // Initialize dayStorage using the persistent container created for tests.
        habitStorage = HabitStorage(
            container: memoryPersistentContainer,
            habitDayStorage: habitDayStorage
        )
    }
    
    override func tearDown() {
        // Remove the initialized storages.
        habitStorage = nil
        habitDayStorage = nil
        dayStorage = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testHabitCreation() {
        // TODO: Test the Habit creation with a color argument.
        let name = "Go jogging"
        let days = (0...7).compactMap { dayNumber in
            // Create and return a date by adding the number of days.
            Date().byAddingDays(dayNumber)
        }
        
        // If there are no days in the array, the test shouldn't proceed.
        if days.isEmpty {
            XCTFail("FIX: The dates for the Habit creation can't be empty.")
        }
        
        // Create the habit.
        let joggingHabit = habitStorage.create(
            with: name,
            days: days
        )
        
        // Check the habit's id property.
        XCTAssertNotNil(
            joggingHabit.id,
            "Created Habit entities should have an id."
        )
        
        // Check the habit's name.
        XCTAssertEqual(
            joggingHabit.name,
            name
        )
        // Check the habit's created property.
        XCTAssertNotNil(
            joggingHabit.created,
            "Created habit should have the creation date."
        )
        
        // Check the habit's days.
        XCTAssertNotNil(
            joggingHabit.days,
            "Created habit should have the HabitDays property."
        )
        XCTAssert(
            joggingHabit.days!.count == days.count,
            "Created habit should have the expected amount of HabitDays."
        )
        
        guard let habitDays = joggingHabit.days as? Set<HabitDay> else {
            XCTFail("Couldn't cast the days property to a Set with HabitDay entities.")
            return
        }
        
        for habitDay in habitDays {
            // Check if the Day's date is in the provided dates.
            // If it isn't, the HabitDays creation went wrong.
            XCTAssertNotNil(
                habitDay.day,
                "The habitDay should have a valid Day relationship."
            )
            XCTAssertNotNil(
                habitDay.day!.date,
                "The habitDay's Day entity should have a valid date property."
            )
            XCTAssert(
                days.contains(habitDay.day!.date!),
                "The Day's date should have a valid date (matching with the provided ones in the Habit creation)."
            )
        }
    }
    
    func testHabitFetchedResultsControllerFactory() {
        // Get the fetched results controller.
        let fetchedResultsController = habitStorage.makeFetchedResultsController()
        
        // Assert on its fetch request.
        XCTAssertEqual(
            "Habit",
            fetchedResultsController.fetchRequest.entityName,
            "Only Habit entities should be fetched by the controller."
        )
        
        // Assert on its sort descriptors.
        guard let sortDescriptors = fetchedResultsController.fetchRequest.sortDescriptors else {
            XCTFail(
                "The fetched Habit entities should be sorted."
            )
            return
        }
        
        // The sort descriptors should sort in both
        // the created or score properties.
        XCTAssertEqual(
            2,
            sortDescriptors.count,
            "The Habits should be sorted by the created and score properties."
        )
        XCTAssertEqual(
            sortDescriptors[0].key,
            "created",
            "Should sort by the Habit entity's created property."
        )
        XCTAssertEqual(
            sortDescriptors[1].key,
            "score",
            "Should sort by the Habit entity's score property."
        )
    }
    
    func testHabitEditionWithNameProperty() {
        // Declare the name to be set.
        let habitName = "Fight Muay-Thai"
        
        // Declare a habit dummy.
        let habitDummy = factories.habit.makeDummy()
        
        // Edit the Habit to change the name.
        let editedHabit = habitStorage.edit(
            habit: habitDummy,
            withName: habitName
        )
        
        // Assert that the edited habit and the dummy one are the same.
        XCTAssertEqual(
            editedHabit,
            habitDummy,
            "The edition routine should return the same habit instance but with the edited properties.."
        )
        
        // Assert on the name property.
        XCTAssertEqual(
            habitDummy.name,
            habitName,
            "The dummy habit should now have the edited name."
        )
    }
    
    func testHabitEditionWithColorProperty() {
        // TODO: Define the possible colors as an enum.
        XCTFail("Not implemented.")
    }
    
    func testHabitEditionWithDaysProperty() {
        // 1. Declare a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // 2. Create a new array of days' dates.
        let daysDates = (1..<14).compactMap { dayIndex -> Date? in
            Date().byAddingDays(dayIndex)
        }
        
        // 3. Edit the days property.
        _ = habitStorage.edit(habit: dummyHabit, days: daysDates)
        
        // 4. Make assertions on the days:
        // 4.1. Assert on the days' count.
        XCTAssertEqual(
            dummyHabit.days?.count,
            daysDates.count,
            "The Habit days should be correclty set and have the expected count."
        )
        
        // 4.2. Assert on the days' dates.
        guard let habitDays = dummyHabit.days as? Set<HabitDay> else {
            XCTFail("Couldn't get the edited habit days.")
            return
        }
        for habitDay in habitDays {
            // 4.2.1. Check if the day's date is in the expected dates.
            XCTAssertTrue(
                daysDates.map { $0.description }.contains(
                    habitDay.day?.date?.description ?? ""
                ),
                "The new added day should have a correct day among the specified ones."
            )
        }
    }
    
    func testHabitEditionWithDaysPropertiesThatAreOnlyInTheFuture() {
        // TODO:
        XCTFail("Not implemented.")
    }
    
    func testHabitEditionWithNotificationProperty() {
        // TODO:
        XCTFail("Not implemented.")
    }
    
    func testHabitDeletion() {
        // TODO:
        XCTFail("Not implemented.")
        // Create a new habit.
        // Delete the created habit.
        // Try to fetch the previously created habit.
        // The result should be nil.
    }
}
