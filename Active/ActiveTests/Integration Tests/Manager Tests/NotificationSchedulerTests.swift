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
    
    func testSchedulingNotification() {
        // Schedule a notification.
        let scheduleExpectation = XCTestExpectation(
            description: "Schedules an user notification related to a NotificationMO."
        )
        
        // Declare a dummy notification to be used.
        let dummyNotification = makeNotification()
        
        // Schedule it by passing the dummy entity.
        notificationScheduler.schedule(dummyNotification) { notification in
            // It should have an user notification identifier.
            XCTAssertTrue(
                notification.wasScheduled,
                "The notification entity should've been scheduled."
            )
            
            // Check if the notification was indeed scheduled.
            self.notificationCenterMock.getPendingNotificationRequests { requests in
                for request in requests {
                    if request.identifier == notification.userNotificationId {
                        scheduleExpectation.fulfill()
                        return
                    }
                }
                
                XCTFail("Couldn't find the scheduled expectation.")
            }
        }
        
        wait(for: [scheduleExpectation], timeout: 0.1)
    }
    
    func testUnschedulingNotification() {
        // Declare the expectation to be fullfilled.
        let unscheduleExpectation = XCTestExpectation(
            description: "Unschedules an user notification associated with a NotificationMO."
        )
        
        // 1. Declare a dummy notification.
        let dummyNotification = makeNotification()
        
        // 2. Schedule it.
        notificationScheduler.schedule(dummyNotification) {
            notification in
            // 3. Unschedule it.
            self.notificationScheduler.unschedule(
                [dummyNotification]
            )
            
            // 4. Assert it was deleted by trying to fetch it
            // using the mock.
            self.notificationCenterMock.getPendingNotificationRequests {
                requests in
                XCTAssertTrue(
                    requests.filter {
                        $0.identifier == dummyNotification.userNotificationId
                    }.count == 0,
                    "The scheduled notification should have been deleted."
                )
                
                unscheduleExpectation.fulfill()
            }
        }
        
        wait(for: [unscheduleExpectation], timeout: 0.1)
    }
    
    func testSchedulingManyNotifications() {
        // 1. Declare the expectation to be fulfilled.
        let scheduleExpectation = XCTestExpectation(
            description: "Schedule a bunch of user notifications related to the NotificationMO entities."
        )
        
        // 2. Declare a dummy habit with n notifications.
        let dummyHabit = factories.habit.makeDummy()
        
        // 3. Schedule the notifications.
        let notifications = Array(dummyHabit.notifications as! Set<NotificationMO>)
        notificationScheduler.schedule(notifications)
        
        // 4. Fetch them by using the mock and assert on each value.
        self.notificationCenterMock.getPendingNotificationRequests {
            requests in
            
            let identifiers = requests.map { $0.identifier }
            
            // Setup a timer to get the notifications to be marked as
            // executed. Since they're marked within the managed object
            // context's thread, they aren't marked immediatelly,
            // that's why a timer is needed here.
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                for notification in notifications {
                    // Assert on the wasExecuted property.
                    XCTAssertTrue(
                        notification.wasScheduled,
                        "The notification should have been scheduled."
                    )
                    // Assert on the identifier.
                    XCTAssertTrue(
                        identifiers.contains(
                            notification.userNotificationId!
                        ),
                        "The notification wasn't properly scheduled."
                    )
                }
                scheduleExpectation.fulfill()
            }
        }
        
        wait(for: [scheduleExpectation], timeout: 0.2)
    }
    
    func testUnschedulingManyNotifications() {
        XCTMarkNotImplemented()
    }
}