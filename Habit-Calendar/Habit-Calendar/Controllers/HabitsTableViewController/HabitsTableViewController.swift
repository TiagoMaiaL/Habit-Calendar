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
class HabitsTableViewController: UITableViewController {

    // MARK: Types

    /// The segments displayed by this controller, which show habits in progress and habits that were completed.
    enum Segment: Int {
        case inProgress
        case completed
    }

    // MARK: Properties

    /// The identifier for the habit creation controller's segue.
    let newHabitSegueIdentifier = "Create a new habit"

    /// The identifier for the habit details controller's segue.
    let detailsSegueIdentifier = "Show habit details"

    /// The in progress habit cell's reuse identifier.
    let inProgressHabitCellIdentifier = "In progress habit table view cell"

    /// The completed habit cell's reuse identifier.
    let completedHabitCellIdentifier = "Completed habit table view cell"

    /// The used persistence container.
    var container: NSPersistentContainer!

    /// The Habit storage used to fetch the tracked habits.
    var habitStorage: HabitStorage!

    /// The user notification manager used to check or request the user's authorization.
    var notificationManager: UserNotificationManager!

    /// The segmented control used to change the habits being displayed, based on its stage (completed or in progress).
    @IBOutlet weak var habitsSegmentedControl: UISegmentedControl!

    /// The variable holding the current(related to today) fetchedResultsController
    /// for the habits that are in progress.
    /// - Note: To re-initialize this property, only set it to nil, and use the getter.
    private var _progressfetchedResultsController: NSFetchedResultsController<HabitMO>?

    /// The fetched results controller used to get the habits that are in progress and display them with the tableView.
    var progressfetchedResultsController: NSFetchedResultsController<HabitMO> {
        if _progressfetchedResultsController == nil {
            let fetchedController = habitStorage.makeFetchedResultsController(context: container.viewContext)
            fetchedController.delegate = self
            _progressfetchedResultsController = fetchedController
        }

        return _progressfetchedResultsController!
    }

    /// The variable holding the current(related to today) fetchedResultsController
    /// for the completed habits.
    /// - Note: To re-initialize this property, only set it to nil, and use the getter.
    private var _completedfetchedResultsController: NSFetchedResultsController<HabitMO>?

    /// The fetched results controller used to get the habits that are completed and display them with the tableView.
    var completedfetchedResultsController: NSFetchedResultsController<HabitMO> {
        if _completedfetchedResultsController == nil {
            let fetchedController = habitStorage.makeCompletedFetchedResultsController(context: container.viewContext)
            fetchedController.delegate = self
            _completedfetchedResultsController = fetchedController
        }

        return _completedfetchedResultsController!
    }

    /// The currently selected segment.
    var selectedSegment: Segment {
        return Segment(rawValue: habitsSegmentedControl.selectedSegmentIndex)!
    }

    /// The fetched results controller for the selected segment (in progress or completed habits).
    /// - Note: This is the fetched results controller used by the tableView's data source, which is chosen based
    ///         on the currently selected segmented.
    var selectedFetchedResultsController: NSFetchedResultsController<HabitMO> {
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
        stopObserving()
    }

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Assert if the dependencies were properly injected.
        assert(container != nil, "The persistent container must be injected.")
        assert(habitStorage != nil, "The habit storage must be injected.")
        assert(notificationManager != nil, "The notification manager must be injected.")

        startObserving()

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
        updateList()
    }

    @objc private func createNewHabit() {
        performSegue(withIdentifier: newHabitSegueIdentifier, sender: self)
    }

    // MARK: Imperatives

    /// Updates the controller's list of habits.
    private func updateList() {
        // TODO: Alert the user in case of errors.
        try? selectedFetchedResultsController.performFetch()
        displayEmptyStateIfNeeded()
        tableView.reloadData()
    }

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
    func displayEmptyStateIfNeeded() {
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
                emptyStateView.callToActionButton.isHidden = false
            case .completed:
                emptyStateView.emptyLabel.text = "You don't have any completed habits yet."
                emptyStateView.callToActionButton.isHidden = true
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
}

extension HabitsTableViewController: NotificationObserver {
    func startObserving() {
        // Register to possible notifications thrown by changes in other managed contexts.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContextChanges(_:)),
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActivationEvent(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHabitReminderSelection(_:)),
            name: Notification.Name.didSelectHabitReminder,
            object: nil
        )
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HabitsTableViewController: AppActiveObserver {
    func handleActivationEvent(_ notification: Notification) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            // Reset the current fetched results controller, so its predicate always takes today into account.
            switch self.selectedSegment {
            case .inProgress:
                self._progressfetchedResultsController = nil
            case .completed:
                self._completedfetchedResultsController = nil
            }

            self.updateList()
        }
    }
}

extension HabitsTableViewController: ManagedContextChangeObserver {
    /// Listens to any saved changes happening in other contexts and refreshes
    /// the viewContext.
    /// - Parameter notification: The thrown notification
    @objc internal func handleContextChanges(_ notification: Notification) {
        // If the changes were only updates, reload the tableView.
        if (notification.userInfo?["updated"] as? Set<NSManagedObject>) != nil {
            DispatchQueue.main.async {
                self.updateList()
            }
        }

        // Refresh the current view context by using the payloads in the notifications.
        container.viewContext.mergeChanges(fromContextDidSave: notification)

        DispatchQueue.main.async {
            self.displayEmptyStateIfNeeded()
        }
    }
}

extension HabitsTableViewController: HabitReminderSelectionObserver {
    /// Takes the user to the habit details controller.
    private func showHabitDetails(_ habit: HabitMO) {
        guard let detailsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: "HabitDetails"
            ) as? HabitDetailsViewController else {
                assertionFailure("Couldn't get the habit details controller.")
                return
        }

        detailsController.habit = habit
        detailsController.container = container
        detailsController.habitStorage = habitStorage
        detailsController.notificationManager = notificationManager
        detailsController.notificationStorage = NotificationStorage()
        detailsController.notificationScheduler = NotificationScheduler(
            notificationManager: notificationManager
        )

        navigationController?.pushViewController(detailsController, animated: true)
    }

    func handleHabitReminderSelection(_ notification: Notification) {
        guard let habit = notification.userInfo?["habit"] as? HabitMO else {
            assertionFailure("Couldn't get the user notification's habit.")
            return
        }
        showHabitDetails(habit)
    }
}
