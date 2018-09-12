//
//  UserDefaults+Login.swift
//  Active
//
//  Created by Tiago Maia Lopes on 12/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// Adds login utilities to UserDefaults.
extension UserDefaults {

    // MARK: Properties

    /// A value indicating if it's the user first launch.
    var isFirstLaunch: Bool {
        return !bool(forKey: "did_launch_already")
    }

    // MARK: Imperatives

    /// Marks that the user already launched the app once.
    func setFirstLaunchPassed() {
        set(true, forKey: "did_launch_already")
    }
}
