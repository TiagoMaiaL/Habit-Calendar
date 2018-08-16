//
//  HabitsTableViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 06/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

/// Controller in charge of displaying the list of tracked habits.
class HabitsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: Properties

    /// The identifier for the habit creation controller's segue.
    private let newHabitSegueIdentifier = "Create a new habit"

    /// The identifier for the habit details controller's segue.
    private let detailsSegueIdentifier = "Show habit details"

    /// The Habit cell's reuse identifier.
    private let habitCellIdentifier = "Habit table view cell"

    /// The used persistence container.
    var container: NSPersistentContainer!

    /// The Habit storage used to fetch the tracked habits.
    var habitStorage: HabitStorage!

    /// The fetched results controller used to get the habits and
    /// display them with the tableView.
    private lazy var fetchedResultsController: NSFetchedResultsController<HabitMO> = {
        let fetchedController = habitStorage.makeFetchedResultsController(
            context: container.viewContext
        )
        fetchedController.delegate = self

        return fetchedController
    }()

    /// The label displaying the number of the user's habits.
    @IBOutlet weak var habitsCountLabel: UILabel!

    // MARK: Deinitialization

    deinit {
        // Remove the registered observers.
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Assert if the dependencies were properly injected.
        assert(container != nil, "The persistent container must be injected.")
        assert(habitStorage != nil, "The habit storage must be injected.")

        // Register to possible notifications thrown by changes in
        // other managed contexts.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContextChanges(notification:)),
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil
        )

        // Configure the nav bar.
        navigationController?.navigationBar.prefersLargeTitles = true

        // Remove the empty separators from the table view.
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Start fetching for the habits.
        // TODO: Check what errors are thrown by the fetch. Every error should be reported to the user.
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Error: Couldn't fetch the user's habits.")
        }

        displayHabitsCount()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case newHabitSegueIdentifier:
            // Inject the controller's habit storage, user storage,
            // and persistent container.
            if let habitCreationController = segue.destination as? HabitCreationTableViewController {
                habitCreationController.container = container
                habitCreationController.habitStore = habitStorage
                habitCreationController.userStore = AppDelegate.current.userStorage
            } else {
                assertionFailure(
                    "Error: Couldn't get the habit creation controller."
                )
            }
        case detailsSegueIdentifier:
            // Inject the controller's habit, habit storage and container.
            if let habitDetailsController = segue.destination as? HabitDetailsViewController {
                habitDetailsController.container = container
                habitDetailsController.habitStorage = habitStorage

                // Get the selected habit for injection.
                guard let indexPath = tableView.indexPathForSelectedRow else {
                    assertionFailure("Error: couldn't get the user's selected row.")
                    return
                }
                let selectedHabit = fetchedResultsController.object(at: indexPath)

                // Inject the selected habit.
                habitDetailsController.habit = selectedHabit
            } else {
                assertionFailure(
                    "Error: Couldn't get the habit details controller."
                )
            }
        default:
            break
        }
    }

    // MARK: Imperatives

    /// Displays the current amount of the user's habits in the table header
    /// view.
    private func displayHabitsCount() {
        // Display the current amount of habits in the header.
        let countRequest: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
        do {
            let count = try container.viewContext.count(for: countRequest)
            // TODO: Localize this.
            habitsCountLabel.text = "\(count) habit\(count > 1 ? "s" : "")"
        } catch {
            // TODO: Any errors should be reported to the user.
            habitsCountLabel.text = nil
        }
    }

    // MARK: DataSource Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        }

        return 0
    }
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: habitCellIdentifier,
            for: indexPath
        )

        // Get the current habit object.
        let habit = fetchedResultsController.object(at: indexPath)

        if let cell = cell as? HabitTableViewCell {
            // Display the habit properties:
            // Its name.
            cell.nameLabel?.text = habit.name
            // And its progress.
            var pastCount = habit.getCurrentChallenge()?.getPastDays()?.count ?? 0
            let daysCount = habit.getCurrentChallenge()?.days?.count ?? 1

            // If the current day was marked as executed, account it as a past
            // day as well.
            if habit.getCurrentChallenge()?.getCurrentDay()?.wasExecuted ?? false {
                pastCount += 1
            }

            cell.progressLabel?.text = "\(pastCount) / \(daysCount) completed days"
            cell.progressBar.tint = HabitMO.Color(rawValue: habit.color)?.getColor()
            // Change the bar's progress (past days / total).
            cell.progressBar.progress = CGFloat(Double(pastCount) / Double(daysCount))
        }

        return cell
    }

    // MARK: Actions

    /// Listens to any saved changes happening in other contexts and refreshes
    /// the viewContext.
    /// - Parameter notification: The thrown notification
    @objc private func handleContextChanges(notification: Notification) {
        // If the changes were only updates, reload the tableView.
        if (notification.userInfo?["updated"] as? Set<NSManagedObject>) != nil {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        // Refresh the current view context by using the payloads
        // in the notifications.
        container.viewContext.mergeChanges(fromContextDidSave: notification)
    }
}

extension HabitsTableViewController {

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

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // End the tableView updates.
        tableView.endUpdates()

        // Update the header.
        displayHabitsCount()
    }

}
