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
        case habitDayExecutionCountKey = "NUMBER_OF_EXECUTED_DAYS_COUNT"
        case lastPromptedAppVersionKey = "LAST_PROMPT_APP_VERSION"
    }

    /// The number of days executed to ask for a review.
    static let daysCountParameter = 20

    // MARK: Properties

    /// The defaults holding the parameters to make the request for reviews.
    let userDefaults: UserDefaults

    // MARK: Imperatives

    /// Requests the review of the app to the user.
    /// - Note: The request is made only under certain requirements:
    ///         - The user must have marked a day (of any habit) as executed at least 20 times.
    ///         - There's a new version of the app that the user didn't review.
    func requestReviewIfAppropriate(usingAppVersion version: String) {
        let lastPromptedVersionParameter = userDefaults.string(
            forKey: UserDefaultsKeys.lastPromptedAppVersionKey.rawValue
        )
        let countParameter = userDefaults.integer(
            forKey: UserDefaultsKeys.habitDayExecutionCountKey.rawValue
        )

        if lastPromptedVersionParameter != version && countParameter >= AppStoreReviewManager.daysCountParameter {
            userDefaults.set(
                version, forKey:
                UserDefaultsKeys.lastPromptedAppVersionKey.rawValue
            )
            userDefaults.set(
                0,
                forKey: UserDefaultsKeys.habitDayExecutionCountKey.rawValue
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
        if let passedVersion = version {
            let lastPromptedVersion = userDefaults.string(
                forKey: UserDefaultsKeys.lastPromptedAppVersionKey.rawValue
            )

            // If there's a new version, reset the count.
            if passedVersion != lastPromptedVersion {
                userDefaults.set(
                    0,
                    forKey: UserDefaultsKeys.habitDayExecutionCountKey.rawValue
                )
                return
            }
        }

        // Update the count to += 1.
        let count = userDefaults.integer(
            forKey: UserDefaultsKeys.habitDayExecutionCountKey.rawValue
        )
        userDefaults.set(
            count + 1,
            forKey: UserDefaultsKeys.habitDayExecutionCountKey.rawValue
        )
    }
}
