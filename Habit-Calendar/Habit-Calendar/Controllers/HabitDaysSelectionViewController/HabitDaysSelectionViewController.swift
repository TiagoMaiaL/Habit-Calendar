//
//  HabitDaysSelectionViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 04/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import JTAppleCalendar

/// The controller used to select the days in which the habit is going to be tracked.
class HabitDaysSelectionViewController: UIViewController {

    // MARK: Properties

    /// The calendar's startDate.
    internal lazy var startDate: Date! = Date().getBeginningOfMonth()?.getBeginningOfDay() ?? Date()

    /// The calendar's endDate.
    internal lazy var finalDate: Date! = {
        return startDate.byAddingYears(2) ?? Date()
    }()

    /// The cell's reusable identifier.
    internal let cellIdentifier = "day collection view cell"

    /// The pre-selected days to be displayed after the controller appears on screen.
    var preSelectedDays: [Date]?

    /// The calendar view with the days to be selected.
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    /// The calendar's header view.
    @IBOutlet weak var monthHeaderView: MonthHeaderView! {
        didSet {
            // Hold each used view that comes with the header.
            monthTitleLabel = monthHeaderView.monthLabel
            previousMonthButton = monthHeaderView.previousButton
            nextMonthButton = monthHeaderView.nextButton
        }
    }

    /// The title of the month being displayed by the calendar.
    weak var monthTitleLabel: UILabel!

    /// The header's previous month button.
    weak var previousMonthButton: UIButton! {
        didSet {
            previousMonthButton.addTarget(self, action: #selector(goPrevious), for: .touchUpInside)
        }
    }

    /// The header's next month button.
    weak var nextMonthButton: UIButton! {
        didSet {
            nextMonthButton.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        }
    }

    /// The label showing the number of currently selected days.
    @IBOutlet weak var selectedDaysNumberLabel: UILabel!

    /// The label showing the selected range of days.
    @IBOutlet weak var selectedDaysRangeLabel: UILabel!

    /// The button the user uses to tell when the selection is done.
    @IBOutlet weak var doneButton: UIButton!

    /// The delegate in charge of receiving days selected by the user.
    weak var delegate: HabitDaysSelectionViewControllerDelegate?

    /// The controller's theme color.
    var themeColor: UIColor!

    /// Flag indicating if the range selection between two dates should be applied.
    /// - Note: The range selection normally takes place when an user selects one date and than
    ///         another later than the first one. This flag controls the usage of this behavior.
    ///         When pre-selecting dates, this behavior should be disabled.
    private(set) var shouldApplyRangeSelection = true

    /// The user's first selected date.
    let firstSelectedDay = Date().getBeginningOfDay()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make assertions on the properties to be injected.
        assert(themeColor != nil, "The controller's theme color should be properly injected.")

        // Configure the calendar view.
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Disable the pop gesture recognizer. It might conflict with the calendar's scroll gesture.
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Apply the theme color to the controller.
        doneButton.backgroundColor = themeColor
        monthTitleLabel.textColor = themeColor

        // Display the pre-selected days.
        if let days = preSelectedDays?.sorted() {
            // Assert the first date is today.
            assert(days.first == firstSelectedDay, "Error: the first selected date must be today.")

            // Temporarilly disable range selection.
            shouldApplyRangeSelection = false
            calendarView.selectDates(days)
        } else {
            calendarView.selectDates([firstSelectedDay])
        }

        // Configute the calendar's header initial state.
        handleCalendarHeader()

        // Configure the footer's initial state.
        handleFooter()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if !shouldApplyRangeSelection {
            shouldApplyRangeSelection = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Re-enable the navigationController's pop gesture recognizer.
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    // MARK: Actions

    @IBAction func deselectDays(_ sender: UIBarButtonItem) {
        clearSelection()
    }

    @IBAction func selectDays(_ sender: UIButton) {
        // Pass the selected dates to the delegate.
        delegate?.didSelectDays(calendarView.selectedDates)

        // Pop the current controller.
        navigationController?.popViewController(animated: true)
    }

    /// Makes the calendar display the previous month.
    @objc private func goPrevious() {
        goToPreviousMonth()
    }

    /// Makes the calendar display the next month.
    @objc private func goNext() {
        goToNextMonth()
    }

    // MARK: Imperatives

    /// Handles the interaction of the done button according to the selected days.
    func handleFooter() {
        // Enable/Disable the button if the dates are selected or not.
        doneButton.isEnabled = calendarView.selectedDates.count > 1

        // Declare the number of selected dates.
        let datesCount = calendarView.selectedDates.count
        // Display the number of selected days.
        selectedDaysNumberLabel.text = String.localizedStringWithFormat(
            NSLocalizedString(
                "%d day(s) selected.",
                comment: "The label showing how many days were selected for the challenge."
            ),
            datesCount
        )

        // Display the range label.
        let formatter = DateFormatter.shortCurrent

        var firstDescription = ""
        var lastDescription = ""

        // Display the first selected day (from label).
        firstDescription = formatter.string(from: firstSelectedDay)

        // If there's a last selected date, display it. Otherwise show a placeholder.
        if let last = calendarView.selectedDates.last {
            lastDescription = formatter.string(from: last)
        } else {
            lastDescription = "--"
        }

        selectedDaysRangeLabel.text = String.localizedStringWithFormat(
            NSLocalizedString(
                "From: %@, to: %@",
                comment: "Label displaying the duration of the challenge of days."
            ),
            firstDescription,
            lastDescription
        )
    }
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol HabitDaysSelectionViewControllerDelegate: class {

    /// Called when the habit days are done being selected by the user.
    func didSelectDays(_ daysDates: [Date])
}
