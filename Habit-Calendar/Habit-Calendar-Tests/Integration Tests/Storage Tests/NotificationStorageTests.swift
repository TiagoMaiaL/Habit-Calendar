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
import UserNotifications
@testable import Habit_Calendar

/// Class in charge of testing the HabitStorage methods.
class NotificationStorageTests: IntegrationTestCase {

    // MARK: Properties

    var notificationStorage: NotificationStorage!

    // MARK: setup/tearDown

    override func setUp() {
        super.setUp()

        // Initialize notificationStorage using the persistent container created for tests.
        notificationStorage = NotificationStorage()
    }

    override func tearDown() {
        // Remove the initialized storage class.
        notificationStorage = nil

        super.tearDown()
    }

    // MARK: Tests

    func testNotificationCreation() {
        // 1. Get a dummy fire time entity and remove its notification.
        guard let fireTimes = habitFactory.makeDummy().fireTimes as? Set<FireTimeMO>,
            let dummyFireTime = fireTimes.first else {
            XCTFail("Couldn't get the dummy fire time.")
            return
        }
        dummyFireTime.notification = nil

        // 2. Call the storage to create one associated to it.
        let notification = notificationStorage.create(using: context, andFireTime: dummyFireTime)

        // 3. Assert on the entities.
        XCTAssertNotNil(notification)
        XCTAssertNotNil(notification?.id)
        XCTAssertNotNil(notification?.userNotificationId)
        XCTAssertEqual(notification?.fireTime, dummyFireTime)
    }

    func testNotificationDeletion() {
        // 1. Declare a dummy fire time.
        let factory = FireTimeFactory(context: context)
        let dummyFireTime = factory.makeDummy()
        guard let notification = dummyFireTime.notification else {
            XCTFail("Couldn't get the notification entity out of the dummy fire time.")
            return
        }

        // 2. Delete its notification entity.
        notificationStorage.delete(notification, from: context)

        // 3. Assert the notification entity from the fire time was correctly deleted.
        XCTAssertNil(dummyFireTime.notification)
        XCTAssertTrue(notification.isDeleted)
    }
}
