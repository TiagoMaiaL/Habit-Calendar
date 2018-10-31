//
//  HabitNotificationsSelectionViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 04/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

/// The controller used to select the notifications fire times for the
/// habit being created/edited.
class FireTimesSelectionViewController: UIViewController {

    // MARK: Properties

    /// The container used to fetch fire times from.
    var container: NSPersistentContainer!

    /// The fire times storage used to list all app fire times.
    var fireTimesStorage: FireTimeStorage! {
        didSet {
            sortedFireTimes = fireTimesStorage.getAllSortedFireTimes(using: container.viewContext)
        }
    }

    /// All fire times from all habits.
    private var sortedFireTimes: [FireTimeMO] = [] {
        didSet {
            sortedFireTimeComponents = sortedFireTimes.map({ $0.getFireTimeComponents() })
        }
    }

    /// The fire time components generated from the sorted entities.
    private var sortedFireTimeComponents = [DateComponents]()

    /// The fire date cell's reusable identifier.
    private let cellIdentifier = "fire date selection cell"

    /// The static fire dates interval.
    private let interval = 30

    /// The formatter for each fire time option displayed to the user.
    private let fireDateFormatter = DateFormatter.fireTimeFormatter

    /// The fire times displayed to the user for selection.
    private lazy var fireTimeComponents = makeFireTimesProgression(
        minutesInterval: interval
    )

    /// The label displaying the number of fire times selected by the user.
    @IBOutlet weak var fireTimesAmountLabel: UILabel?

    /// The fire dates selected by the user.
    var selectedFireTimeComponents = Set<FireTimesDisplayable.FireTime>() {
        didSet {
            guard fireTimesAmountLabel != nil else { return }
            updateUI()
        }
    }

    /// The controller's theme color.
    weak var themeColor: UIColor! {
        didSet {
            // Reload the table view to update the selected style.
            tableView?.reloadData()
            // Change button's bg color.
            doneButton?.backgroundColor = themeColor
        }
    }

    /// The fire dates selection table view.
    @IBOutlet weak var tableView: UITableView!

    /// The button used to finish the selection.
    @IBOutlet weak var doneButton: UIButton!

    /// The delegate in charge of receiving the selected fire dates.
    weak var delegate: FireTimesSelectionViewControllerDelegate?

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make assertions on the required dependencies.
        assert(container != nil, "The persistent container must be injected.")
        assert(fireTimesStorage != nil, "The fire times storage must be injected")
        assert(themeColor != nil, "The controller's theme color must be injected.")

        // Configure the tableView's content insets.
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)

        // Configure the done button's theme color.
        doneButton.backgroundColor = themeColor

        // Set the initial state of the controller's views.
        updateUI()
    }

    // MARK: Actions

    @IBAction func selectFireTimes(_ sender: UIButton) {
        if selectedFireTimeComponents.isEmpty {
            let alert = UIAlertController(
                title: NSLocalizedString(
                    "No fire times selected",
                    comment: "Alert title displayed when the user didn't select any fire time."
                ),
                message: NSLocalizedString(
                    "Are you sure you don't want to be reminded about your habit?",
                    comment: "Alert message displayed when the user didn't select any fire time."
                ),
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("Yes", comment: ""),
                    style: .default
                ) { _ in self.endSelection() }
            )
            alert.addAction(
                UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default)
            )

            present(alert, animated: true)
        } else {
            endSelection()
        }
    }

    @IBAction func eraseSelection(_ sender: UIBarButtonItem) {
        selectedFireTimeComponents.removeAll()
        tableView.reloadData()
    }

    // MARK: Imperatives

    /// Passes the selected fire times to the delegate and pops the view controller.
    private func endSelection() {
        // Call the delegate passing the fire dates selected
        // by the user.
        delegate?.didSelectFireTimes(Array(selectedFireTimeComponents))
        navigationController?.popViewController(animated: true)
    }

    /// Displays the amount of fire times selected by the user.
    private func displayFireTimesAmount() {
        fireTimesAmountLabel?.text = String.localizedStringWithFormat(
            NSLocalizedString(
                "%d selected fire time(s).",
                comment: "The lable showing how many fire times were selected."
            ),
            selectedFireTimeComponents.count
        )
    }

    /// Updates the UI components according to the selection of fire times.
    private func updateUI() {
        displayFireTimesAmount()
    }
}

extension FireTimesSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: Imperatives

    /// Creates an array of successive fire times by adding
    /// the specified interval in minutes.
    /// - Note: The first date is 00:00 and the last date is 23:59 or
    ///         a time before.
    /// - Parameter minutesInterval: The minutes used to create the
    ///                              progression of dates.
    /// - Returns: An array of successive fire times within a day.
    private func makeFireTimesProgression(minutesInterval: Int) -> [FireTimesDisplayable.FireTime] {
        var fireTimes = [FireTimesDisplayable.FireTime]()

        let minutesInDay = 24 * 60
        let beginningDate = Date().getBeginningOfDay()

        // Generate the dates and append them to the array.
        // Declare the range to be used by determining the amount of
        // dates to be added.
        for index in 0..<Int(minutesInDay / minutesInterval) {
            // Get the next date in the progression.
            guard let nextDate = beginningDate.byAddingMinutes(
                minutesInterval * index
            ) else {
                assertionFailure("Inconsistency: the range can't be correclty generated.")
                return []
            }

            fireTimes.append(
                DateComponents(
                    calendar: Calendar.current,
                    timeZone: TimeZone.current,
                    hour: nextDate.components.hour,
                    minute: nextDate.components.minute
                )
            )
        }

        return fireTimes
    }

    // MARK: TableView DataSource methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fireTimeComponents.count
    }

    // MARK: TableView Delegate methods

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FireTimeTableViewCell else {
            assertionFailure("Couldn't get the fire time cell.")
            return UITableViewCell(
                style: .default,
                reuseIdentifier: cellIdentifier
            )
        }

        // Declare the current fire time to be displayed.
        let currentFireTime = fireTimeComponents[indexPath.row]

        // Set it's time text by using a date formatter.
        if let fireDate = Calendar.current.date(from: currentFireTime) {
            cell.fireTimeLabel?.text = fireDateFormatter.string(from: fireDate)
        }

        cell.isFireTimeBlocked = false

        // If this fire time is among the selected ones,
        // display the selected style in the cell.
        if selectedFireTimeComponents.contains(currentFireTime) {
            cell.habitColor = themeColor
            cell.select()
        } else if let index = sortedFireTimeComponents.lastIndex(of: currentFireTime) {
            // If this fire time spot is already taken, show the habit blocking it.
            let blockingFireTime = sortedFireTimes[index]
            let blockingHabit = blockingFireTime.habit!

            cell.habitColor = blockingHabit.getColor().uiColor
            cell.isFireTimeBlocked = true

            // For now we'll only display it differently and show the habit name.
            cell.habitNameLabel?.text = blockingHabit.name
        } else {
            cell.deselect()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected date.
        let selectedFireTime = fireTimeComponents[indexPath.row]

        if selectedFireTimeComponents.contains(selectedFireTime) {
            // Remove it from the selected ones.
            selectedFireTimeComponents.remove(selectedFireTime)
        } else {
            // Add it to the selected ones.
            selectedFireTimeComponents.insert(selectedFireTime)
        }

        // Reload the cell to display its selected state.
        tableView.reloadRows(at: [indexPath], with: .fade)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol FireTimesSelectionViewControllerDelegate: class {

    /// Called when the habit days are done being selected by the user.
    func didSelectFireTimes(
        _ fireTimes: [FireTimesDisplayable.FireTime]
    )
}
