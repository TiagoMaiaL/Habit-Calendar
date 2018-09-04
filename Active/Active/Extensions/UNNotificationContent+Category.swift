//
//  UNNotificationContent+Category.swift
//  Active
//
//  Created by Tiago Maia Lopes on 04/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UserNotifications

extension UNNotificationContent {

    // MARK: Types

    /// The possible categories of an user notification.
    enum Category {
        case dayPrompt(String)
    }

    // MARK: Imperatives

    /// Gets the content's associated category.
    func getCategory() -> Category? {
        if let identifier = userInfo["habitIdentifier"] as? String {
            // The default is the day prompt.
            return Category.dayPrompt(identifier)
        } else {
            return nil
        }
    }
}
