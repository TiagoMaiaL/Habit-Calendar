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
        defaults.removePersistentDomain(forName: "test_review_manager")

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

    func testRequestReviewingShouldNotRequest() {
        // 1. Call it with a test version.
        reviewManager.requestReviewIfAppropriate(usingAppVersion: "1.0.1")

        // 2. The version shouldn't be stored
        // (meaning that the request wasn't appropriate).
        XCTAssertNil(
            testDefaults.string(forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue)
        )
    }

    func testRequestReviewingShouldWorkAndSetAppVersion() {
        // 1. Configure the testDefaults with the right parameters
        // to meet the request requirements.
        testDefaults.set(
            AppStoreReviewManager.daysCountParameter,
            forKey: AppStoreReviewManager.UserDefaultsKeys.habitDayExecutionCountKey.rawValue
        )

        // 2. Call the request with an app version.
        let appVersion = "1.1.6"
        reviewManager.requestReviewIfAppropriate(usingAppVersion: appVersion)

        // 3. Check that the app version was saved and
        // (now the review can only be made in a new version).
        XCTAssertEqual(
            appVersion,
            testDefaults.string(forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue)
        )
        XCTAssertEqual(
            0,
            testDefaults.integer(forKey: AppStoreReviewManager.UserDefaultsKeys.habitDayExecutionCountKey.rawValue)
        )
    }

    func testRequestReviewingShouldNotWorkBecauseTheVersionDidNotChange() {
        // 1. Configure the testDefaults with an app version and use it again
        // to request for a review.
        testDefaults.set(
            15,
            forKey: AppStoreReviewManager.UserDefaultsKeys.habitDayExecutionCountKey.rawValue
        )
        let version = "2.1.1"
        testDefaults.set(
            version,
            forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue
        )

        // 2. Call the request with the same version.
        reviewManager.requestReviewIfAppropriate(usingAppVersion: version)

        // 3. Assert the version is the same and the count didn't change.
        XCTAssertEqual(
            15,
            testDefaults.integer(forKey: AppStoreReviewManager.UserDefaultsKeys.habitDayExecutionCountKey.rawValue)
        )
        XCTAssertEqual(
            version,
            testDefaults.string(forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue)
        )
    }
}
