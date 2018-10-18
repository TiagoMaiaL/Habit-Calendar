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
struct AppStoreRequestManager {

    // MARK: Types

    /// The keys used by this instance to access the user defaults.
    private enum UserDefaultsKeys: String {
        case habitDayExecutionCountKey = "NUMBER_OF_EXECUTED_DAYS_COUNT"
        case lastPromptedAppVersionKey = "LAST_PROMPT_APP_VERSION"
    }

    // MARK: Imperatives

    /// Requests the review of the app to the user.
    /// - Note: The request is made only under certain requirements:
    ///         - The user must have marked a day (of any habit) as executed at least 20 times.
    ///         - There's a new version of the app that the user didn't review.
    func requestReviewIfAppropriate() {

    }

    /// Updates the review parameters.
    /// - Note: Every time this method is called, the internal count of executed days is increased by one.
    ///         Always make sure to call this in the right place of the application flow.
    func updateReviewParameters() {

    }

    /// Resets the review parameters if appropriate (the app was updated).
    /// - Note: This method should be called every time the app activates.
    func resetReviewParametersIfAppropriate() {

    }
}
