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
        let notification = try? notificationStorage.create(
            withFireDate: fireDate,
            habit: swimmingHabit
        )
        
        XCTAssertNotNil(notification, "The Notification entity shouldn't be nil.")
        // Check for id
        XCTAssertNotNil(notification!.id, "Notification id shouldn't be nil.")
        // Check for the correct fire date.
        XCTAssertEqual(fireDate, notification!.fireDate, "Notification should have the correct fire date.")
        // Check for the habits property
        XCTAssertEqual(swimmingHabit, notification!.habit, "The created notification has an invalid habit.")
        
        // Check if the entity has a user notification associated with it.
        XCTAssertNotNil(notification!.userNotificationId, "The created notification should have an associated and scheduled user notification id.")
        XCTAssertNotNil(notification!.request, "The created notification should have the associated user notification request object.")
    }
    
    func testNotificationFetch() {
        // Create a new habit
        let habit = habitStorage.create(
            with: "walk every day",
            days: [Date()]
        )
        
        // Create a new notification
        let fireDate = Date()
        let notification = try? notificationStorage.create(
            withFireDate: fireDate,
            habit: habit
        )
        
        // Try to fetch the created notification
        let fetchedNotification = notificationStorage.notification(
            forHabit: habit,
            andDate: fireDate
        )
        
        XCTAssertNotNil(notification, "The Notification entity shouldn't be nil.")
        // Check if method fetches the created notification.
        XCTAssertNotNil(fetchedNotification, "Created notification should be fetched by using the notification method in the storage class.")
        // Check if notification's id matches.
        XCTAssertEqual(notification!.id, fetchedNotification?.id, "Created notification should have the correct attributes.")
    }
    
    func testNotificationCreationTwiceShouldThrow() {
        // Trying to create the same notification entity should throw an error.
        
        // Create a new habit.
        let habit = habitStorage.create(
            with: "Play the guitar",
            days: [Date()]
        )
        
        // Create a new notification
        let fireDate = Date()
        _ = try? notificationStorage.create(
            withFireDate: fireDate,
            habit: habit
        )
        
        // Try to create another notification with the same data
        // and check to see if it throws the expected exception.
        XCTAssertThrowsError(
            _ = try notificationStorage.create(
                withFireDate: fireDate,
                habit: habit
            ), "Trying to create the same notification twice should throw an error.")
    }
    
    func testNotificationDeletion() {
        // Create a new habit
        let habit = habitStorage.create(
            with: "walk every day",
            days: [Date()]
        )
        
        // Create a new notification
        let fireDate = Date()
        let notification = try? notificationStorage.create(
            withFireDate: fireDate,
            habit: habit
        )
        
        XCTAssertNotNil(notification, "The Notification entity shouldn't be nil.")
        // The new notification should be correctly fetched.
        XCTAssertNotNil(notificationStorage.notification(
            forHabit: habit,
            andDate: fireDate
        ), "The previously created notification should be fetched.")
        
        // Delete the created notification
        notificationStorage.delete(notification!)
        
        // Try to fetch the previously created notification.
        // Method shouldn't fetch any notification.
        XCTAssertNil(notificationStorage.notification(
            forHabit: habit,
            andDate: fireDate
        ), "The deleted notification shouldn't be fetched.")
    }
}
