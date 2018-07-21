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
    var notificationStorage: NotificationStorage!
    var notificationCenterMock: UserNotificationCenterMock!
    var notificationScheduler: NotificationScheduler!
    var habitStorage: HabitStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize the DayStorage.
        dayStorage = DayStorage()
        
        // Initialize the HabitDayStorage.
        habitDayStorage = HabitDayStorage(
            calendarDayStorage: dayStorage
        )
        
        // Initialize the notification manager used by the storage.
        notificationCenterMock = UserNotificationCenterMock(
            withAuthorization: false
        )
        notificationScheduler = NotificationScheduler(
            notificationManager: UserNotificationManager(
                notificationCenter: notificationCenterMock
            )
        )
        
        // Initialize the notification storage.
        notificationStorage = NotificationStorage()
        
        // Initialize dayStorage using the persistent container created for tests.
        habitStorage = HabitStorage(
            habitDayStorage: habitDayStorage,
            notificationStorage: notificationStorage,
            notificationScheduler: notificationScheduler
        )
    }
    
    override func tearDown() {
        // Remove the initialized storages.
        dayStorage = nil
        habitDayStorage = nil
        notificationScheduler = nil
        notificationStorage = nil
        habitStorage = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testHabitCreation() {
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
            using: context,
            user: factories.user.makeDummy(),
            name: name,
            color: HabitMO.Color.red,
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
            joggingHabit.createdAt,
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
        
        guard let habitDays = joggingHabit.days as? Set<HabitDayMO> else {
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
                days.map{
                    $0.getBeginningOfDay().description
                }.contains(habitDay.day!.date!.description),
                "The Day's date should have a valid date (matching with the provided ones in the Habit creation)."
            )
        }
    }
    
    func testHabitCreationByPassingFireTimes() {
        XCTMarkNotImplemented()
        
        // 1. Declare the fire times' components.
        let fireTimes = [
            DateComponents(
                hour: Int.random(0..<59),
                minute: Int.random(0..<59)
            ),
            DateComponents(
                hour: Int.random(0..<59),
                minute: Int.random(0..<59)
            ),
            DateComponents(
                hour: Int.random(0..<59),
                minute: Int.random(0..<59)
            )
        ]
        
        // 2. Create the habit.
        let habit = habitStorage.create(
            using: context,
            user: factories.user.makeDummy(),
            name: "exercise",
            color: .red,
            days: [Date().byAddingDays(15)!],
            and: fireTimes
        )
        
        // 3. Make assertions on the habit's fire times.
        XCTAssertNotNil(
            habit.fireTimes,
            "The habit should have fireTimes created with it."
        )
        XCTAssertTrue(
            habit.fireTimes?.count == fireTimes.count,
            "The habit should have notifications created with it."
        )
    }
    
    func testHabitFetchedResultsControllerFactory() {
        // Get the fetched results controller.
        let fetchedResultsController = habitStorage.makeFetchedResultsController(context: context)
        
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
            1,
            sortDescriptors.count,
            "The Habits should be sorted by the created and score properties."
        )
        XCTAssertEqual(
            sortDescriptors[0].key,
            "createdAt",
            "Should sort by the Habit entity's created property."
        )
    }
    
    func testHabitEditionWithNameProperty() {
        // Declare the name to be set.
        let habitName = "Fight Muay-Thai"
        
        // Declare a habit dummy.
        let habitDummy = factories.habit.makeDummy()
        
        // Edit the Habit to change the name.
        let editedHabit = habitStorage.edit(
            habitDummy,
            using: context,
            name: habitName
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
        // 1. Declare a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // 2. Edit it with the desired color.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            color: HabitMO.Color.purple
        )
        
        // 3. Assert the habit entity now has the passed color.
        XCTAssertEqual(
            dummyHabit.color,
            HabitMO.Color.purple.rawValue,
            "The editted habit should have the purple color."
        )
    }
    
    func testHabitEditionWithDaysProperty() {
        // 1. Declare a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // 2. Create a new array of days' dates.
        let daysDates = (1..<14).compactMap { dayIndex -> Date? in
            Date().byAddingDays(dayIndex)
        }
        
        // 3. Edit the days property.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            days: daysDates
        )
        
        // 4. Make assertions on the days:
        // 4.1. Assert on the days' count.
        XCTAssertEqual(
            dummyHabit.days?.count,
            daysDates.count,
            "The Habit days should be correclty set and have the expected count."
        )
        
        // 4.2. Assert on the days' dates.
        guard let habitDays = dummyHabit.days as? Set<HabitDayMO> else {
            XCTFail("Couldn't get the edited habit days.")
            return
        }
        for habitDay in habitDays {
            // 4.2.1. Check if the day's date is in the expected dates.
            XCTAssertTrue(
                daysDates.map { $0.getBeginningOfDay().description }.contains(
                    habitDay.day?.date?.description ?? ""
                ),
                "The new added day should have a correct day among the specified ones."
            )
        }
    }
    
    func testHabitEditionWithDaysPropertiesThatAreOnlyInTheFuture() {
        // 1. Declare a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // 2. Add 3 past (The date is before than today) habit days to it.
        let pastDays = (1...3).compactMap {
            Date().byAddingDays($0 * -1)
        }
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            days: pastDays
        )
        
        // 3. Make the edition of habit days to replace the existing ones
        //    that are future.
        // 3.1. Edit the dummy habit.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            days: (1...10).compactMap({
                Date().byAddingDays($0)
            })
        )
        
        // 4. Make the assertions on the added days and on the past ones.
        // 4.1. The days should have the expected count (past + added).
        XCTAssertEqual(
            13,
            dummyHabit.days?.count,
            "The habit's days should have the expected count (past + added)."
        )
        
        // 4.2. The past days shouldn't be edited.
        // 4.2.1. Get the dummy habit's past days.
        let predicate = NSPredicate(format: "day.date < %@", Date() as NSDate)
        guard let pastHabitDays = dummyHabit.days?.filtered(using: predicate) as? Set<HabitDayMO> else {
            XCTFail("Couldn't get the past habit days.")
            return
        }
        
        // 4.2.1. Make the assertions.
        XCTAssertEqual(
            pastHabitDays.count,
            pastDays.count,
            "The edition shouldn't affect the past days. The count of the habit's past days is wrong."
        )
        for pastHabitDay in pastHabitDays {
            XCTAssertTrue(
                pastDays.map({ $0.getBeginningOfDay().description }).contains(
                    pastHabitDay.day?.date?.description ?? ""
                ),
                "The past day's date should be contained within the expected ones."
            )
        }
    }
    
    func testHabitEditionWithFireTimesPropertyShouldCreateFireTimeEntities() {
        // 1. Create a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // 2. Declare the fire times.
        let fireTimes = [
            DateComponents(hour: 02, minute: 30),
            DateComponents(hour: 12, minute: 15),
            DateComponents(hour: 15, minute: 45)
        ]
        
        // 3. Edit the habit by passing the fire times.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            and: fireTimes
        )
        
        // 4. Check if FireTimeMO entities were created.
        XCTAssertNotNil(
            dummyHabit.fireTimes,
            "The habit's edition should have created FireTimeMO entities."
        )
        XCTAssertTrue(
            dummyHabit.fireTimes?.count == fireTimes.count,
            "The habit's edition should have created FireTimeMO entities."
        )
    }
    
    func testHabitEditionWithFireTimesPropertyShouldCreateNotifications() {
        // 1. Create a dummy habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // 2. Declare the fire times.
        let fireTimes = [
            DateComponents(hour: 15, minute: 30),
            DateComponents(hour: 11, minute: 15),
        ]

        // 3. Create the notifications by providing the components.
        _ = habitStorage.edit(
            dummyHabit,
            using: context,
            and: fireTimes
        )
        
        // 4. Fetch the dummy's notifications and make assertions on it.
        // 4.1. Check if the count is the expected one.
        
        // Get only the future days for counting.
        guard let futureDays = (dummyHabit.days as? Set<HabitDayMO>)?.filter({ $0.day?.date?.isFuture ?? false }) else {
            XCTFail("Couldn't get the dummy habit's future days for comparision.")
            return
        }
        
        XCTAssertEqual(
            dummyHabit.notifications?.count,
            futureDays.count * fireTimes.count,
            "The added notifications should have the expected count of the passed fire times * days."
        )
    }
    
    func testHabitDeletion() {
        // Create a new habit.
        let dummyHabit = factories.habit.makeDummy()
        
        // Delete the created habit.
        habitStorage.delete(dummyHabit, from: context)
        
        // Assert it was deleted.
        XCTAssertTrue(
            dummyHabit.isDeleted,
            "The habit entity should be marked as deleted."
        )
    }
    
    func testCreatingHabitShouldScheduleUserNotifications() {
        notificationCenterMock.shouldAuthorize = true
        let scheduleExpectation = XCTestExpectation(
            description: "Create a new habit and create and schedule the notifications."
        )
        
        // 1. Declare the habit attributes needed for creation:
        let dummyUser = factories.user.makeDummy()
        let days = (1..<Int.random(2..<50)).compactMap {
            Date().byAddingDays($0)
        }
        let fireTimes = [
            DateComponents(hour: 18, minute: 30),
            DateComponents(hour: 12, minute: 15),
        ]
        
        // 2. Create the habit.
        let createdHabit = habitStorage.create(
            using: context,
            user: dummyUser,
            name: "Testing notifications",
            color: .red,
            days: days,
            and: fireTimes
        )
        
        // Use a timer to make the assertions on the scheduling of user
        // notifications. Scheduling notifications is an async operation.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {
            _ in
            // 3. Assert that the habit's notifications were scheduled:
            // - Assert on the count of notifications and user notifications.
            XCTAssertEqual(
                createdHabit.notifications?.count,
                days.count * fireTimes.count
            )
            self.notificationCenterMock.getPendingNotificationRequests {
                requests in
                XCTAssertEqual(
                    requests.count,
                    days.count * fireTimes.count
                )
                
                // - Assert on the identifiers of each notificationMO and
                //   user notifications.
                let identifiers = requests.map { $0.identifier }
                guard let notificationsSet = createdHabit.notifications as? Set<NotificationMO> else {
                    XCTFail("The notifications weren't properly created.")
                    return
                }
                let notifications = Array(notificationsSet)
                
                XCTAssertTrue(
                    notifications.filter {
                        return !identifiers.contains( $0.userNotificationId! )
                    }.count == 0,
                    "All notifications should have been properly scheduled."
                )
                
                // - Assert on the notifications' wasScheduled property.
                XCTAssertTrue(
                    notifications.filter { !$0.wasScheduled }.count == 0,
                    "All notifications should have been scheduled."
                )
                
                scheduleExpectation.fulfill()
            }
        }
        wait(for: [scheduleExpectation], timeout: 0.2)
    }
    
    func testEditingHabitDaysShouldRescheduleUserNotifications() {
        XCTMarkNotImplemented()
        
        let rescheduleExpectation = XCTestExpectation(
            description: "Reschedules the user notifications after changing the days dates."
        )
        
        // 1. Declare the dummy habit.
        
        // 2. Declare the new days dates.
        
        // 3. Edit the habit.
        
        // 4.
        
        wait(for: [rescheduleExpectation], timeout: 0.2)
    }
    
    func testEditingHabitFireDatesShouldRescheduleUserNotifications() {
        XCTMarkNotImplemented()
    }
    
    func testEditingDaysAndFireDatesShouldRescheduleUserNotifications() {
        XCTMarkNotImplemented()
    }
}
