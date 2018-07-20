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
    
    func testSchedulingANotification() {
        XCTMarkNotImplemented()
    }
    
    func testUnschedulingANotification() {
        XCTMarkNotImplemented()
    }
    
    func testSchedulingManyNotifications() {
        XCTMarkNotImplemented()
    }
    
    func testUnschedulingManyNotifications() {
        XCTMarkNotImplemented()
    }
}
