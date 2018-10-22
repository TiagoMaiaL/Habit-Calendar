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
            testDefaults.integer(forKey: AppStoreReviewManager.UserDefaultsKeys.countParameterKey.rawValue)
        )
    }

    func testUpdatingTheCountParameterUpdatesTheCountProperty() {
        // 1. Update the parameters a random amount of times and check that the count property changes accordingly.
        let randomCount = Int.random(in: 1...10)
        for _ in 0..<randomCount {
            reviewManager.updateReviewParameters()
        }

        XCTAssertEqual(randomCount, reviewManager.currentCountParameter)
        XCTAssertEqual(
            randomCount,
            testDefaults.integer(forKey: AppStoreReviewManager.UserDefaultsKeys.countParameterKey.rawValue)
        )
    }

    func testUpdatingTheParametersShouldNotGoOverLimit() {
        // 1. Update the parameters more than the allowed limit and check it doesn't go over it.
        let limit = AppStoreReviewManager.countParameterLimit
        for _ in 0...(limit + 10) {
            reviewManager.updateReviewParameters()
        }

        // 2. Assert that the count parameter didn't pass the limit.
        XCTAssertEqual(reviewManager.currentCountParameter, limit)
    }

    func testUpdatingParametersWontWorkBecauseTheRequestWasAlreadyMadeForTheVersion() {
        // 1. Configure the defaults with the flag indicating that the review
        // request was already made for the current version.
        testDefaults.set(
            true,
            forKey: AppStoreReviewManager.UserDefaultsKeys.wasReviewRequestedForThisVersion.rawValue
        )

        // 2. Call the method to update the parameters and check it didn't update.
        reviewManager.updateReviewParameters()

        XCTAssertEqual(0, reviewManager.currentCountParameter)
    }

    func testResetingTheParametersWontWorkBecauseVersionDidNotChange() {
        // 1. Configure the test defaults with the version, flag, and parameters.
        testDefaults.set(
            true,
            forKey: AppStoreReviewManager.UserDefaultsKeys.wasReviewRequestedForThisVersion.rawValue
        )
        testDefaults.set(
            AppStoreReviewManager.countParameterLimit,
            forKey: AppStoreReviewManager.UserDefaultsKeys.countParameterKey.rawValue
        )
        let version = "1.0.0"
        testDefaults.set(
            version,
            forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue
        )

        // 2. Call the reset with the same app version.
        reviewManager.resetParameters(withNewVersion: version)

        // 3. It shouldn't reset any of the contents in the test defaults.
        XCTAssertNotEqual(0, reviewManager.currentCountParameter)
        XCTAssertNotEqual(false, reviewManager.wasReviewRequested)
        // The version is the same as before.
        XCTAssertEqual(
            version,
            testDefaults.string(forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue)
        )
    }

    func testResetingParametersWithANewAppVersionWillWork() {
        // 1. Configure the test defaults with the version, flag, and parameters.
        testDefaults.set(
            true,
            forKey: AppStoreReviewManager.UserDefaultsKeys.wasReviewRequestedForThisVersion.rawValue
        )
        testDefaults.set(
            AppStoreReviewManager.countParameterLimit,
            forKey: AppStoreReviewManager.UserDefaultsKeys.countParameterKey.rawValue
        )
        testDefaults.set(
            "1.0.0",
            forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue
        )

        // 2. Call the reset with a new app version.
        reviewManager.resetParameters(withNewVersion: "1.0.1")

        // 3. It should reset all of the contents in the test defaults.
        XCTAssertEqual(0, reviewManager.currentCountParameter)
        XCTAssertEqual(false, reviewManager.wasReviewRequested)
        // The version is the same as before.
        XCTAssertEqual(
            "1.0.1",
            testDefaults.string(forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue)
        )
    }

    func testRequestReviewingShouldNotRequest() {
        XCTMarkNotImplemented()

        // 1. Call it with a test version.
        reviewManager.requestReviewIfAppropriate(usingAppVersion: "1.0.1")

        // 2. The version shouldn't be stored
        // (meaning that the request wasn't appropriate).
        XCTAssertNil(
            testDefaults.string(forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue)
        )
    }

    func testRequestReviewingShouldWorkAndSetAppVersion() {
        XCTMarkNotImplemented()

        // 1. Configure the testDefaults with the right parameters
        // to meet the request requirements.
        testDefaults.set(
            AppStoreReviewManager.countParameterLimit,
            forKey: AppStoreReviewManager.UserDefaultsKeys.countParameterKey.rawValue
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
            testDefaults.integer(forKey: AppStoreReviewManager.UserDefaultsKeys.countParameterKey.rawValue)
        )
    }

    func testRequestReviewingShouldNotWorkBecauseTheVersionDidNotChange() {
        XCTMarkNotImplemented()

        // 1. Configure the testDefaults with an app version and use it again
        // to request for a review.
        testDefaults.set(
            15,
            forKey: AppStoreReviewManager.UserDefaultsKeys.countParameterKey.rawValue
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
            testDefaults.integer(forKey: AppStoreReviewManager.UserDefaultsKeys.countParameterKey.rawValue)
        )
        XCTAssertEqual(
            version,
            testDefaults.string(forKey: AppStoreReviewManager.UserDefaultsKeys.lastPromptedAppVersionKey.rawValue)
        )
    }
}
