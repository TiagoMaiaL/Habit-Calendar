//
//  NotificationStorageTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 19/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import XCTest
import CoreData
@testable import Active

/// Class in charge of testing the HabitStorage methods.
class NotificationStorageTests: StorageTestCase {
    
    // MARK: Properties
    
    var notificationManager: UserNotificationManager!
    var habitStorage: HabitStorage!
    var notificationStorage: NotificationStorage!
    
    // MARK: setup/tearDown
    
    override func setUp() {
        super.setUp()
        
        // Initialize habit storage.
        habitStorage = HabitStorage(container: memoryPersistentContainer)
        
        // Initialize notification manager.
        notificationManager = UserNotificationManager()
        
        // Initialize notificationStorage using the persistent container created for tests.
        notificationStorage = NotificationStorage(
            container: memoryPersistentContainer,
            manager: notificationManager
        )
    }
    
    override func tearDown() {
        // Remove the initialized storage class.
        notificationStorage = nil
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testNotificationCreation() {
        let swimmingHabit = habitStorage.create(
            with: "Go swimming",
            days: [Date()]
        )
        
        let fireDate = Date()
        let notification = notificationStorage.create(
            withFireDate: fireDate,
            habit: swimmingHabit
        )
        
        // Check for id
        XCTAssertNotNil(notification.id, "Notification id shouldn't be nil.")
        // Check for the correct fire date.
        XCTAssertEqual(fireDate, notification.fireDate, "Notification should have the correct fire date.")
        // Check for the habits property
        XCTAssert(notification.habits != nil && notification.habits!.count > 0, "Notification should have an associated habit entity with it.")
        
        guard let habits = notification.habits as? Set<Active.Habit> else {
            XCTFail("The created notification should have a correct set of habit instances.")
            return
        }
        
        XCTAssertEqual(swimmingHabit, habits.first!, "The created notification has an invalid habit.")
        
        // TODO: Check if the entity has a user notification associated with it.
        
        XCTAssertNotNil(notification.userNotificationId, "The created notification should have an associated and scheduled user notification.")
        XCTAssertNotNil(notification.request, "The created notification should have the associated user notification request object.")
    }
    
    // TODO: Trying to create the same notification entity should throw an error.
    
    func testNotificationFetch() {
        // Create a new habit
        // Create a new notification
        // Try to fetch the created notification
        
        // Check if method fetches the created notification.
        // Check if notification's id is right.
    }
    
    func testNotificationDeletion() {
        // Create a new habit
        // Create a new notification
        
        // Delete the created notification
        
        // Try to fetch the previously created notification.
        // Method shouldn't fetch any notification.
    }
}
