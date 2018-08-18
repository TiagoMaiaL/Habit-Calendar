//
//  HabitDetailsViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData
import JTAppleCalendar

class HabitDetailsViewController: UIViewController {

    // MARK: Properties

    /// The habit presented by this controller.
    var habit: HabitMO!

    /// The ordered days for the passed habit.
    /// - Note: This array mustn't be empty. The existence of days is ensured
    ///         in the habit's creation and edition process.
    private var orderedHabitDays: [HabitDayMO]!

    /// The habit storage used to manage the controller's habit.
    var habitStorage: HabitStorage!

    /// The persistent container used by this store to manage the
    /// provided habit.
    var container: NSPersistentContainer!

    /// The month header view, with the month label and next/prev buttons.
    @IBOutlet weak var monthHeader: MonthHeaderView! {
        didSet {
            monthTitleLabel = monthHeader.monthLabel
            nextMonthButton = monthHeader.nextButton
            previousMonthButton = monthHeader.previousButton
        }
    }

    /// The month title label in the calendar's header.
    private weak var monthTitleLabel: UILabel!

    /// The next month header button.
    private weak var nextMonthButton: UIButton!

    /// The previous month header button.
    private weak var previousMonthButton: UIButton!

    //    /// View holding the prompt to ask the user if the activity
//    /// was executed in the current day.
//    @IBOutlet weak var promptView: UIView!

//    /// The positive prompt button.
//    @IBOutlet weak var positivePromptButton: UIButton!

//    /// The negative prompt button.
//    @IBOutlet weak var negativePromptButton: UIButton!

    /// The cell's reusable identifier.
    private let cellIdentifier = "Habit day cell id"

    /// The calendar view showing the habit days.
    /// - Note: The collection view will show a range with
    ///         the Habit's first days until the last ones.
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Assert on the required properties to be injected
        // (habit, habitStorage, container and the calendar header views):
        assert(
            habit != nil,
            "Error: the needed habit wasn't injected."
        )
        assert(
            habitStorage != nil,
            "Error: the needed habitStorage wasn't injected."
        )
        assert(
            container != nil,
            "Error: the needed container wasn't injected."
        )
        assert(
            monthTitleLabel != nil,
            "Error: the month title label wasn't set."
        )
        assert(
            nextMonthButton != nil,
            "Error: the next month button wasn't set."
        )
        assert(
            previousMonthButton != nil,
            "Error: the previous month button wasn't set."
        )

        // Try to get the ordered days from the passed habit.
        let dateSorting = NSSortDescriptor(key: "day.date", ascending: true)

        guard let orderedDays = habit.getCurrentChallenge()?.days?.sortedArray(
            using: [dateSorting]
        ) as? [HabitDayMO] else {
            assertionFailure("Inconsistency: Couldn't sort the habit's days by the date property.")
            return
        }

        // All created habits must have associated habit days.
        assert(
            !orderedDays.isEmpty,
            "Inconsistency: the habit's days shouldn't be empty."
        )

        // Assign the fetched days.
        orderedHabitDays = orderedDays

        // Configure the calendar.
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self

        title = habit.name
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Configure the appearance of the prompt view.
//        handlePrompt()
    }

    // MARK: Actions

    @IBAction func deleteHabit(_ sender: UIButton) {
        // Alert the user to see if the deletion is really wanted:

        // Declare the alert.
        let alert = UIAlertController(
            title: "Delete",
            message: """
Are you sure you want to delete this habit? Deleting this habit makes all the history \
information unavailable.
""",
            preferredStyle: .alert
        )
        // Declare its actions.
        alert.addAction(UIAlertAction(title: "delete", style: .destructive) { _ in
            // If so, delete the habit using the container's viewContext.
            // Pop the current controller.
            self.habitStorage.delete(
                self.habit, from:
                self.container.viewContext
            )
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "cancel", style: .default))

        // Present it.
        present(alert, animated: true)
    }

    @IBAction func savePromptResult(_ sender: UIButton) {
        guard let currentHabitDay = habit.getCurrentDay() else {
            assertionFailure(
                "Inconsistency: There isn't a current habit day but the prompt is being displayed."
            )
            return
        }

        currentHabitDay.managedObjectContext?.perform {
//            if sender === self.positivePromptButton {
//                // Mark it as executed.
//                currentHabitDay.wasExecuted = true
//            } else if sender === self.negativePromptButton {
//                // Mark is as non executed.
//                currentHabitDay.wasExecuted = false
//            }

            // Save the result.
            try? currentHabitDay.managedObjectContext?.save()

            DispatchQueue.main.async {
                // Hide the prompt header.
                self.handlePrompt()
                // Reload calendar to show the executed day.
                self.calendarView.reloadData()
            }
        }
    }

    // MARK: Imperatives

    /// Show the prompt view if today is a day(HabitDayMO) being tracked
    /// by the app.
    private func handlePrompt() {
        // Try to get a habit day for today.
        if let currentDay = habit.getCurrentDay(),
            currentDay.wasExecuted == false {
            // Configure the appearance of the prompt.
//            promptView.isHidden = false
        } else {
//            promptView.isHidden = true
        }
    }
}

extension HabitDetailsViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    // MARK: JTAppleCalendarViewDataSource Methods

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // Get the oldest and newest habitDays.
        let oldestDay = orderedHabitDays.first!
        let newestDay = orderedHabitDays.last!

        // It'd be a bug if there wasn't valid days with the HabitDay.
        assert(
            oldestDay.day?.date != nil,
            "Inconsistency: Couldn't get the first day's date property."
        )
        assert(
            newestDay.day?.date != nil,
            "Inconsistency: Couldn't get the last day's date property."
        )

        return ConfigurationParameters(
            startDate: oldestDay.day!.date!,
            endDate: newestDay.day!.date!
        )
    }

    // MARK: JTAppleCalendarViewDelegate Methods

    func calendar(
        _ calendar: JTAppleCalendarView,
        cellForItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
    ) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath
        )

        guard let dayCell = cell as? DetailsCalendarDayCell else {
            assertionFailure("Couldn't get the expected details calendar cell.")
            return cell
        }

        if cellState.dateBelongsTo == .thisMonth {
            // Set the cell's color if the date represents a habit day.

            let predicate = NSPredicate(
                format: "day.date >= %@ AND day.date < %@",
                date.getBeginningOfDay() as NSDate,
                date.getEndOfDay() as NSDate
            )
            if let currentHabitDay = habit.getCurrentChallenge()?.days?.filtered(using: predicate).first as? HabitDayMO {
                cell.backgroundColor = currentHabitDay.wasExecuted ? .purple : .red
            } else {
                cell.backgroundColor = .white
            }

            dayCell.dayTitleLabel.text = cellState.text
        } else {
            dayCell.dayTitleLabel.text = ""
            dayCell.backgroundColor = .white
        }

        return dayCell
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        willDisplay cell: JTAppleCell,
        forItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
    ) {}
}
