//
//  FireTimeMO.swift
//  Active
//
//  Created by Tiago Maia Lopes on 21/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// Entity representing the fire times for the user notifications
/// configured by the user.
class FireTimeMO: NSManagedObject {

    // MARK: Imperatives

    /// Gets the fire time hour and minute as date components.
    /// - Returns: The date components related to the fire time entity.
    func getFireTimeComponents() -> DateComponents {
        return DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone.current,
            hour: Int(hour),
            minute: Int(minute)
        )
    }
}
