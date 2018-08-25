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

    /// Displays the passed fire times.
    func displayFireTimes(_ fireTimes: [FireTime])
}

extension FireTimesDisplayable {

    func displayFireTimes(_ fireTimes: [FireTime]) {
        if !fireTimes.isEmpty {
            // Set the text for the label displaying the amount of fire times.
            fireTimesAmountLabel.text = "\(fireTimes.count) fire time\(fireTimes.count == 1 ? "" : "s") selected."

            // Set the text for the label displaying some of the
            // selected fire times:
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

            fireTimesLabel.text = fireTimesText
        } else {
            fireTimesAmountLabel.text = "No fire times selected."
            fireTimesLabel.text = "--"
        }
    }
}
