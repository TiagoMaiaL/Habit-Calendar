//
//  OffensiveMO.swift
//  Active
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// The offensives a user has accomplished for a given habit.
/// - Note: Offensives are created whenever the user executes a habit on an
/// specific day and they continue until the user breaks a sequence of
/// consecutive days.
class OffensiveMO: NSManagedObject {

    // MARK: Imperatives

    /// Calculates the offensive's length
    /// (diffence between its boundary dates).
    /// - Returns: The offensive's length.
    func getLength() -> Int {
        // Get its from and to dates.
        guard let fromDate = fromDate, let toDate = toDate else {
            assertionFailure(
                "Inconsistency: Both the from and to dates must be set."
            )
            return 0
        }

        // Get the difference.
        let difference = fromDate.getDifferenceInDays(from: toDate)
        return difference > 0 ? difference : 1
    }
}
