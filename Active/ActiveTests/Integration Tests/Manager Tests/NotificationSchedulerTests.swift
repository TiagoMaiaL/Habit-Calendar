//
//  NotificationSchedulerTests.swift
//  JTAppleCalendar
//
//  Created by Tiago Maia Lopes on 19/07/18.
//

import XCTest
import UserNotifications
@testable import Active

/// Class in charge of testing the NotificationScheduler struct.
class NotificationSchedulerTests: IntegrationTestCase {
    
    // MARK: Properties
    
    /// The notification center mock used to test the scheduler.
    var notificationCenterMock: UserNotificationCenterMock!
    
    /// The scheduler being tested. It takes NotificationMO entities and
    /// schedules tbe user notifications related to each entity.
    var notificationScheduler: NotificationScheduler!
    
    // MARK: Setup/TearDown
    
    override func setUp() {
        super.setUp()
        
        // Instantiate the scheduler by using a notification center mock.
        notificationCenterMock = UserNotificationCenterMock(
            withAuthorization: true
        )
        notificationScheduler = NotificationScheduler(notificationManager: UserNotificationManager(notificationCenter: notificationCenterMock)
        )
    }
    
    override func tearDown() {
        super.tearDown()
        
        // Remove the instantiated entity.
        notificationCenterMock = nil
        notificationScheduler = nil
    }
    
    // MARK: Tests
    
    func testContentAndTriggerFactory() {
        // Test the factories for the user notification's trigger and content
        // options when a Notification entity is passed and the authorization
        // was fully granted by the user.
        
        // Declare the notification (associated with a Habit dummy)
        // that needs to be passed.
        let dummyNotification = makeNotification()
        
        // Make the content and trigger options out of the passed habit.
        let userNotificationOptions = notificationScheduler.makeNotificationOptions(
            for: dummyNotification
        )
        
        // Check on the content properties(texts).
        XCTAssertNotNil(
            userNotificationOptions.content,
            "The generated user notification should be set."
        )
        XCTAssertEqual(
            userNotificationOptions.content.title,
            dummyNotification.habit!.getTitleText(),
            "The user notification content should have the correct title text."
        )
        XCTAssertEqual(
            userNotificationOptions.content.subtitle,
            dummyNotification.habit!.getSubtitleText(),
            "The user notification content should have the correct subtitle text."
        )
        XCTAssertEqual(
            userNotificationOptions.content.body,
            dummyNotification.habit!.getDescriptionText(),
            "The user notification content should have the correct description text."
        )
        
        // Declare the trigger as a UNTitmeIntervalNotificationTrigger.
        guard let dateTrigger = userNotificationOptions.trigger as? UNTimeIntervalNotificationTrigger else {
            XCTFail("The generated notification's trigger is nil.")
            return
        }
        
        XCTAssertNotNil(dateTrigger.nextTriggerDate(), "The notification trigger should have a valid trigger date.")
        XCTAssertEqual(
            dateTrigger.nextTriggerDate()!.description,
            dummyNotification.getFireDate().description,
            "The user notification trigger should have the correct next trigger date."
        )
    }
    
    func testSchedulingANotification() {
        XCTMarkNotImplemented()
        
        // Declare the expectation to be fullfilled.
        let scheduleExpectation = XCTestExpectation(
            description: "Schedules an user notification related to a NotificationMO."
        )
        
        // 1. Declare a dummy notification.
        
        // 2. Schedule it.
        
        // 3. Try fetching it using the mock.
    }
    
    func testUnschedulingANotification() {
        XCTMarkNotImplemented()
        
        // Declare the expectation to be fullfilled.
        
        // 1. Declare a dummy notification.
        
        // 2. Schedule it.
        
        // 3. Unschedule it.
        
        // 4. Assert it was deleted by fetching it using the mock.
    }
    
    func testSchedulingManyNotifications() {
        XCTMarkNotImplemented()
    }
    
    func testUnschedulingManyNotifications() {
        XCTMarkNotImplemented()
    }
}
