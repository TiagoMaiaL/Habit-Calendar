//
//  AppStoreReviewManager.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 18/10/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import StoreKit

/// Object used to appropriatelly manage the request for reviews on the app store.
/// - Note: Reviews must be requested only under certain conditions:
///         - The user must have marked at least 20 days of the habits as executed.
struct AppStoreReviewManager {

    // MARK: Types

    /// The keys used by this instance to access the user defaults.
    enum UserDefaultsKeys: String {
        case countParameterKey = "NUMBER_OF_EXECUTED_DAYS_COUNT"
        case lastPromptedAppVersionKey = "LAST_PROMPT_APP_VERSION"
        case wasReviewRequestedForThisVersion = "WAS_REVIEW_REQUESTED"
    }

    /// The number of executed days needed in order to ask for a review.
    static let countParameterLimit = 20

    // MARK: Properties

    /// The defaults holding the parameters to make the request for an app store review.
    let userDefaults: UserDefaults

    /// The last version in which a review for feedback was requested.
    private var lastPromptedAppVersion: String {
        get {
            return userDefaults.string(forKey: UserDefaultsKeys.lastPromptedAppVersionKey.rawValue) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.lastPromptedAppVersionKey.rawValue)
        }
    }

    /// The current count parameter related to the current version.
    private(set) var currentCountParameter: Int {
        get {
            return userDefaults.integer(forKey: UserDefaultsKeys.countParameterKey.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.countParameterKey.rawValue)
        }
    }

    /// The flag indicating if the review was requested for the current version.
    var wasReviewRequested: Bool {
        get {
            return userDefaults.bool(forKey: UserDefaultsKeys.wasReviewRequestedForThisVersion.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.wasReviewRequestedForThisVersion.rawValue)
        }
    }

    // MARK: Imperatives

    /// Requests the review of the app to the user.
    /// - Note: The request is made only under certain requirements:
    ///         - The user must have marked a day (of any habit) as executed at least 20 times.
    ///         - There's a new version of the app that the user didn't review.
    func requestReviewIfAppropriate(usingAppVersion version: String) {
        let lastPromptedVersionParameter = userDefaults.string(
            forKey: UserDefaultsKeys.lastPromptedAppVersionKey.rawValue
        )

        if lastPromptedVersionParameter != version &&
            currentCountParameter >= AppStoreReviewManager.countParameterLimit {
            userDefaults.set(
                version,
                forKey: UserDefaultsKeys.lastPromptedAppVersionKey.rawValue
            )
            userDefaults.set(
                0,
                forKey: UserDefaultsKeys.countParameterKey.rawValue
            )
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
            }
        }
    }

    /// Updates the review parameters.
    /// - Note: Every time this method is called, the internal count of executed days is increased by one.
    ///         Always make sure to call this in the right place of the application flow.
    func updateReviewParameters(usingAppVersion version: String? = nil) {
//        if let passedVersion = version {
//            let lastPromptedVersion = userDefaults.string(
//                forKey: UserDefaultsKeys.lastPromptedAppVersionKey.rawValue
//            )
//
//            // If there's a new version and the count param is already greater than the limit, reset the count.
//            if lastPromptedVersion != nil &&
//                passedVersion != lastPromptedVersion &&
//                currentCountParameter > AppStoreReviewManager.countParameterLimit + 10 {
//                userDefaults.set(
//                    0,
//                    forKey: UserDefaultsKeys.countParameterKey.rawValue
//                )
//                return
//            }
//        }

        if wasReviewRequested == false && currentCountParameter < AppStoreReviewManager.countParameterLimit {
            // Update the count to += 1.
            userDefaults.set(
                currentCountParameter + 1,
                forKey: UserDefaultsKeys.countParameterKey.rawValue
            )
            print("Review parameter Count is now: \(currentCountParameter)")
        }
    }

    /// Resets the parameters for review.
    /// - Note: Only resets if the passed version is new.
    mutating func resetParameters(withNewVersion version: String) {
        if version != lastPromptedAppVersion {
            currentCountParameter = 0
            wasReviewRequested = false
            // The version gets updated, so reseting will only happen in the next version.
            lastPromptedAppVersion = version
        }
    }
}
