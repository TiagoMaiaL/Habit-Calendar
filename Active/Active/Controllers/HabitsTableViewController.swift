//
//  HabitsTableViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 06/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

/// Controller in charge of displaying the list of tracked habits.
class HabitsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: Types

    /// The segments displayed by this controller, which show habits in progress and habits that were completed.
    enum Segment: Int {
        case inProgress
        case completed
    }

    // MARK: Properties

    /// The identifier for the habit creation controller's segue.
    private let newHabitSegueIdentifier = "Create a new habit"

    /// The identifier for the habit details controller's segue.
    private let detailsSegueIdentifier = "Show habit details"

    /// The in progress habit cell's reuse identifier.
    private let inProgressHabitCellIdentifier = "In progress habit table view cell"

    /// The completed habit cell's reuse identifier.
    private let completedHabitCellIdentifier = "Completed habit table view cell"

    /// The used persistence container.
    var container: NSPersistentContainer!

    /// The Habit storage used to fetch the tracked habits.
    var habitStorage: HabitStorage!

    /// The user notification manager used to check or request the user's authorization.
    var notificationManager: UserNotificationManager!

    /// The segmented control used to change the habits being displayed, based on its stage (completed or in progress).
    @IBOutlet weak var habitsSegmentedControl: UISegmentedControl!

    /// The fetched results controller used to get the habits that are in progress and display them with the tableView.
    private lazy var progressfetchedResultsController: NSFetchedResultsController<HabitMO> = {
        let fetchedController = habitStorage.makeFetchedResultsController(context: container.viewContext)
        fetchedController.delegate = self

        return fetchedController
    }()

    /// The fetched results controller used to get the habits that are completed and display them with the tableView.
    private lazy var completedfetchedResultsController: NSFetchedResultsController<HabitMO> = {
        let fetchedController = habitStorage.makeCompletedFetchedResultsController(context: container.viewContext)
        fetchedController.delegate = self

        return fetchedController
    }()

    /// The currently selected segment.
    private var selectedSegment: Segment {
        return Segment(rawValue: habitsSegmentedControl.selectedSegmentIndex)!
    }

    /// The fetched results controller for the selected segment (in progress or completed habits).
    /// - Note: This is the fetched results controller used by the tableView's data source, which is chosen based
    ///         on the currently selected segmented.
    private var selectedFetchedResultsController: NSFetchedResultsController<HabitMO> {
        switch selectedSegment {
        case .inProgress:
            return progressfetchedResultsController

        case .completed:
            return completedfetchedResultsController
        }
    }

    /// The empty state view showing the controller's initial states (no habits, or no habits in the segments)
    private var emptyStateView: EmptyStateView!

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
        assert(notificationManager != nil, "The notification manager must be injected.")

        // Register to possible notifications thrown by changes in other managed contexts.
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

        // Load the empty state view and add it as the tableView's background view.
        emptyStateView = makeEmptyStateView()
        emptyStateView.callToActionButton.addTarget(self, action: #selector(createNewHabit), for: .touchUpInside)

        tableView.backgroundView = emptyStateView

        displayPresentationIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Start fetching for the habits.
        // TODO: Check what errors are thrown by the fetch. Every error should be reported to the user.
        do {
            displayEmptyStateIfNeeded()
            try selectedFetchedResultsController.performFetch()
        } catch {
            assertionFailure("Error: Couldn't fetch the user's habits.")
        }
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
                habitCreationController.notificationManager = notificationManager
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
                habitDetailsController.notificationManager = notificationManager
                habitDetailsController.notificationStorage = NotificationStorage()
                habitDetailsController.notificationScheduler = NotificationScheduler(
                    notificationManager: notificationManager
                )

                // Get the selected habit for injection.
                guard let indexPath = tableView.indexPathForSelectedRow else {
                    assertionFailure("Error: couldn't get the user's selected row.")
                    return
                }
                let selectedHabit = selectedFetchedResultsController.object(at: indexPath)

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

    // MARK: Actions

    @IBAction func switchSegment(_ sender: UISegmentedControl) {
        // TODO: Alert the user in case of errors.
        try? selectedFetchedResultsController.performFetch()
        displayEmptyStateIfNeeded()
        tableView.reloadData()
    }

    @objc private func createNewHabit() {
        performSegue(withIdentifier: newHabitSegueIdentifier, sender: self)
    }

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

        // Refresh the current view context by using the payloads in the notifications.
        container.viewContext.mergeChanges(fromContextDidSave: notification)
    }

    // MARK: Imperatives

    /// Instantiates a new EmptyStateView for usage.
    /// - Returns: The instantiated EmptyStateView.
    private func makeEmptyStateView() -> EmptyStateView {
        // Load the nib, get its root view and return it.
        let nibContents = Bundle.main.loadNibNamed("EmptyStateView", owner: nil, options: nil)

        guard let emptyStateView = nibContents!.first as? EmptyStateView else {
            assertionFailure("Couldn't load the empty state view from the nib file.")
            return EmptyStateView()
        }

        return emptyStateView
    }

    /// Display the controller's empty state depending on the user's added habits.
    private func displayEmptyStateIfNeeded() {
        // Check if the user has any habits, if he doesn't, display the empty state.
        if let count = try? container.viewContext.count(for: HabitMO.fetchRequest()), count == 0 {
            habitsSegmentedControl.isHidden = true
            emptyStateView.isHidden = false
            emptyStateView.callToActionButton.isHidden = false
            emptyStateView.emptyLabel.text = "You don't have any habits yet. Let's begin by adding a new one!"

            return
        }

        // Check if the selected segment has habits, if it doesn't, display an appropriated message.
        if selectedFetchedResultsController.fetchedObjects?.count == 0 {
            habitsSegmentedControl.isHidden = false
            emptyStateView.isHidden = false
            emptyStateView.callToActionButton.isHidden = true

            switch selectedSegment {
            case .inProgress:
                emptyStateView.emptyLabel.text = """
                You don't have any habits in progress at the moment, what do you think of new challenges?
                """
            case .completed:
                emptyStateView.emptyLabel.text = "You don't have any completed habits yet."
            }

            return
        }

        // If there're habits, just hide the empty state view.
        habitsSegmentedControl.isHidden = false
        emptyStateView.isHidden = true
    }

    /// Displays the onBoarding controllers if necessary (Is it first login? Is the environment dev?).
    private func displayPresentationIfNeeded() {
        guard UserDefaults.standard.isFirstLaunch else { return }
        // Get the controller from the storyboard.
        guard let presentationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: "On Boarding"
            ) as? OnBoardingViewController else {
                assertionFailure("Couldn't get the onBoarding controller.")
                return
        }
        presentationController.notificationManager = notificationManager

        UserDefaults.standard.setFirstLaunchPassed()
        // Present it on top of the window's root controller.
        present(presentationController, animated: true)
    }

    // MARK: DataSource Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return selectedFetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = selectedFetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        }

        return 0
    }
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil

        // Get the current habit object.
        let habit = selectedFetchedResultsController.object(at: indexPath)

        switch selectedSegment {
        case .inProgress:
            cell = tableView.dequeueReusableCell(
                withIdentifier: inProgressHabitCellIdentifier,
                for: indexPath
            )
            if let cell = cell as? HabitTableViewCell {
                // Display the habit properties:
                // Its name.
                cell.nameLabel?.text = habit.name
                // And its progress.
                var pastCount = habit.getCurrentChallenge()?.getPastDays()?.count ?? 0
                let daysCount = habit.getCurrentChallenge()?.days?.count ?? 1

                // If the current day was marked as executed, account it as a past day as well.
                if habit.getCurrentChallenge()?.getCurrentDay()?.wasExecuted ?? false {
                    pastCount += 1
                }

                cell.progressLabel?.text = "\(pastCount) / \(daysCount) completed days"
                cell.progressBar.tint = habit.getColor().uiColor
                // Change the bar's progress (past days / total).
                cell.progressBar.progress = CGFloat(Double(pastCount) / Double(daysCount))
            }
        case .completed:
            cell = tableView.dequeueReusableCell(
                withIdentifier: completedHabitCellIdentifier,
                for: indexPath
            )
            if let cell = cell as? CompletedHabitTableViewCell {
                // Display the habit's name and color.
                cell.nameLabel.text = habit.name
                cell.colorView.backgroundColor = habit.getColor().uiColor
            }
        }

        return cell!
    }

    // MARK: Delegate methods

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch selectedSegment {
        case .inProgress:
            return 145
        case .completed:
            return 100
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: detailsSegueIdentifier, sender: self)
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
