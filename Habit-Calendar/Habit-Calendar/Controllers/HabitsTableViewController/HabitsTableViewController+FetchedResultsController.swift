//
//  HabitsTableViewController+FetchedResultsController.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 15/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

extension HabitsTableViewController: NSFetchedResultsControllerDelegate {

    // MARK: NSFetchedResultsControllerDelegate implementation methods

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Begin the tableView updates.
        tableView.beginUpdates()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
        ) {
        // Only execute the updates if the segment being shown is handled by the passed controller.
        // There're two fetchedResultsController instances managing different segments of the table view,
        // One for the in progress habits and another for the completed ones. Only update the one being displayed.
        guard shouldUpdateSegmentFrom(controller: controller) else { return }

        // Add or remove rows based on the kind of changes:
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    /// Informs if the changed fetched results controller should update the current segment being displayed
    /// by the table view.
    /// - Parameter fetchedResultsController: The updated fetched results controller.
    /// - Returns: True if the update should be displayed by the segment, false otherwise.
    private func shouldUpdateSegmentFrom(controller: NSFetchedResultsController<NSFetchRequestResult>) -> Bool {
        switch selectedSegment {
        case .inProgress:
            return controller == progressfetchedResultsController
        case .completed:
            return controller == completedfetchedResultsController
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // End the tableView updates.
        tableView.endUpdates()

        displayEmptyStateIfNeeded()
    }
}
