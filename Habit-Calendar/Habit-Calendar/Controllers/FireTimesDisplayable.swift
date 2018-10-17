//
//  FireTimesDisplayable.swift
//  Active
//
//  Created by Tiago Maia Lopes on 24/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Defines the main interface for displaying habit fire times.
protocol FireTimesDisplayable {

    typealias FireTime = DateComponents

    // MARK: Properties

    /// The label displaying the available fire times.
    var fireTimesAmountLabel: UILabel! { get }
    var fireTimesLabel: UILabel! { get }

    // MARK: Imperatives

    /// Generates the text associated with the fire times.
    /// - Parameter fireTimes: The fire times to be described.
    /// - Returns: The fire times' text.
    func getText(from fireTimes: [FireTime]) -> String

    /// Displays the passed fire times.
    func displayFireTimes(_ fireTimes: [FireTime])
}

extension FireTimesDisplayable {

    func getText(from fireTimes: [FireTime]) -> String {
        guard !fireTimes.isEmpty else {
            return "--"
        }

        // Set the text for the label displaying some of the selected fire times:
        let fireTimeFormatter = DateFormatter.makeFireTimeDateFormatter()
        let fireDates = fireTimes.compactMap {
            Calendar.current.date(from: $0)
        }.sorted()
        var fireTimesText = ""

        for fireDate in fireDates {
            fireTimesText += fireTimeFormatter.string(from: fireDate)

            // If the current fire time isn't the last one,
            // include a colon to separate it from the next.
            if fireDates.index(of: fireDate)! != fireDates.endIndex - 1 {
                fireTimesText += ", "
            }
        }

        return fireTimesText
    }

    func displayFireTimes(_ fireTimes: [FireTime]) {
        // Set the text for the label displaying the amount of fire times.
        fireTimesAmountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString(
                "%d fire time(s) selected.",
                comment: "The number of fire times selected by the user."
            ),
            fireTimes.count
        )
        fireTimesLabel.text = getText(from: fireTimes)
    }
}
