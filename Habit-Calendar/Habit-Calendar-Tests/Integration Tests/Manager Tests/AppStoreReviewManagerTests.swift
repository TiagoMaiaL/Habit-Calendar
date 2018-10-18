//
//  AppStoreReviewManagerTests.swift
//  Habit-CalendarTests
//
//  Created by Tiago Maia Lopes on 18/10/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import XCTest
@testable import Habit_Calendar

/// Class in charge of testing the interface of the AppStoreReviewManager.
class AppStoreReviewManagerTests: IntegrationTestCase {

    // MARK: Properties

    /// The review manager being tested.
    var reviewManager: AppStoreReviewManager!

    /// The user defaults used for the tests.
    var testDefaults: UserDefaults!

    // MARK: Setup / Teardown

    override func setUp() {
        super.setUp()

        guard let defaults = UserDefaults(suiteName: "test_review_manager") else {
            XCTFail("Couldn't get the user defaults for tests.")
            return
        }

        testDefaults = defaults
        reviewManager = AppStoreReviewManager(
            userDefaults: testDefaults
        )
    }

    override func tearDown() {
        reviewManager = nil
        testDefaults = nil

        super.tearDown()
    }

    // MARK: Tests

    func testUpdatingTheParametersToRequestTheReview() {
        // Updating the review parameters should increase the count to one.
        // 1. Update and make the assertions.
        reviewManager.updateReviewParameters()
        XCTAssertEqual(
            1,
            testDefaults.integer(forKey: AppStoreReviewManager.UserDefaultsKeys.habitDayExecutionCountKey.rawValue)
        )
    }
}
