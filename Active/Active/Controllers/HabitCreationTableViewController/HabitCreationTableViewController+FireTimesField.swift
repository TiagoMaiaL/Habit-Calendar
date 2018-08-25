//
//  HabitCreationTableViewController+FireTimesField.swift
//  Active
//
//  Created by Tiago Maia Lopes on 24/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds the code to manage the fire times field.
extension HabitCreationTableViewController: FireTimesDisplayable {}

extension HabitCreationTableViewController: FireTimesSelectionViewControllerDelegate {

    // MARK: HabitNotificationsSelectionViewControllerDelegate Delegate Methods

    func didSelectFireTimes(_ fireTimes: [FireTimesDisplayable.FireTime]) {
        // Associate the selected fire times.
        self.fireTimes = fireTimes
        // Change the labels to display the selected fire times.
        displayFireTimes(fireTimes)
    }
}
