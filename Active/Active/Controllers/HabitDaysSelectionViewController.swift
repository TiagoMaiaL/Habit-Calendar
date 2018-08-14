//
//  HabitDaysSelectionViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 04/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import JTAppleCalendar

/// The controller used to select the days in which the habit is
/// going to be tracked.
class HabitDaysSelectionViewController: UIViewController {

    // MARK: Properties

    /// The calendar's startDate.
    private lazy var calendarStartDate = Date().getBeginningOfMonth()?.getBeginningOfDay() ?? Date()

    /// The calendar's endDate.
    private lazy var calendarEndDate: Date = {
        return calendarStartDate.byAddingYears(2) ?? Date()
    }()

    /// The cell's reusable identifier.
    private let cellIdentifier = "day collection view cell"

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
            previousMonthButton.addTarget(self, action: #selector(goToPreviousMonth), for: .touchUpInside)
        }
    }

    /// The header's next month button.
    weak var nextMonthButton: UIButton! {
        didSet {
            nextMonthButton.addTarget(self, action: #selector(goToNextMonth), for: .touchUpInside)
        }
    }

    /// The label showing the number of currently selected days.
    @IBOutlet weak var selectedDaysNumberLabel: UILabel!

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
    private var shouldApplyRangeSelection = true

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
        if let days = preSelectedDays {
            // Temporarilly disable range selection.
            shouldApplyRangeSelection = false
            calendarView.selectDates(days)
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

    /// The user's first selected date.
    private var firstSelectedDay: Date?

    // MARK: Actions

    @IBAction func deselectDays(_ sender: UIBarButtonItem) {
        calendarView.deselectAllDates()
    }

    @IBAction func selectDays(_ sender: UIButton) {
        // Pass the selected dates to the delegate.
        delegate?.didSelectDays(calendarView.selectedDates)

        // Pop the current controller.
        navigationController?.popViewController(animated: true)
    }

    /// Goes to the previous month in the calendar.
    @objc private func goToPreviousMonth() {
        guard let previousMonth = getCurrentMonth().byAddingMonths(-1) else { return }
        if canGoToPreviousMonth() {
            calendarView.scrollToDate(previousMonth)
        }
    }

    /// Goes to the next month in the calendar.
    @objc private func goToNextMonth() {
        guard let nextMonth = getCurrentMonth().byAddingMonths(1) else { return }
        if canGoToNextMonth() {
            calendarView.scrollToDate(nextMonth)
        }
    }

    // MARK: Imperatives

    /// Handles the interaction of the done button according to
    /// the selected days.
    private func handleFooter() {
        // Enable/Disable the button if the dates are selected or not.
        doneButton.isEnabled = !calendarView.selectedDates.isEmpty

        // Display the number of selected days.
        selectedDaysNumberLabel.text = """
        \(calendarView.selectedDates.count) day\(calendarView.selectedDates.count == 1 ? "" : "s") selected
        """
    }

    /// Handles the title of the calendar's header view.
    private func handleCalendarHeader() {
        // Get the first month's date or today.
        let firstDate = calendarView.visibleDates().monthDates.first?.date ?? Date()

        // Declare a date formatter to get the month and year.
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMMM, yyyy"

        // Change the title label to reflect it.
        monthTitleLabel.text = formatter.string(from: firstDate)

        UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) {
            self.previousMonthButton.alpha = self.canGoToPreviousMonth() ? 1 : 0.3
            self.nextMonthButton.alpha = self.canGoToNextMonth() ? 1 : 0.3
        }.startAnimation()
    }

    /// Gets the calendar's current month.
    /// - Returns: the current month date.
    private func getCurrentMonth() -> Date {
        return calendarView.visibleDates().monthDates.first?.date ?? Date()
    }

    /// Informs if its possible to go the next month.
    private func canGoToPreviousMonth() -> Bool {
        // Get the date for the previous month.
        guard let previousMonth = getCurrentMonth().byAddingMonths(-1) else { return false }
        // Ensure the previousMonth is later (or the same) than the calendar's startDate.
        let comparison = calendarStartDate.compare(previousMonth)
        return comparison == .orderedAscending || comparison == .orderedSame
    }

    /// Informs if its possible to go the previous month.
    private func canGoToNextMonth() -> Bool {
        guard let nextMonth = getCurrentMonth().byAddingMonths(1) else { return false }
        // Ensure the nextMonth is before the calendar's endDate.
        return calendarEndDate.compare(nextMonth) == .orderedDescending
    }
}

extension HabitDaysSelectionViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    // MARK: JTAppleCalendarViewDataSource Methods

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(
            startDate: calendarStartDate,
            endDate: calendarEndDate,
            hasStrictBoundaries: true
        )
    }

    // MARK: JTAppleCalendarViewDelegate Methods

    func calendar(
        _ calendar: JTAppleCalendarView,
        cellForItemAt date: Date,
        cellState: CellState, indexPath: IndexPath
    ) -> JTAppleCell {
        // Dequeue the cell.
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath
        )

        // Configure its appearance.
        handleAppearanceOfCell(cell, using: cellState)

        return cell
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        willDisplay cell: JTAppleCell,
        forItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
    ) {
        // Configure its appearance.
        handleAppearanceOfCell(cell, using: cellState)
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        shouldSelectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
    ) -> Bool {
        // The user can only select a date in the future.
        return (date.isFuture || date.isInToday) && cellState.dateBelongsTo == .thisMonth
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        didSelectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
    ) {
        // Change the cell's appearance to show the selected state.
        if let cell = cell {
            handleAppearanceOfCell(cell, using: cellState)

            // Configure the range according to the tap.
            if shouldApplyRangeSelection {
                if let firstDay = firstSelectedDay {
                    // If the date is lesser than the first selected date, make it the new start of the range.
                    if date.compare(firstDay) == .orderedAscending {
                        firstSelectedDay = date
                    } else {
                        // If not, continue with the range selection.
                        calendar.selectDates(
                            from: firstDay,
                            to: date,
                            triggerSelectionDelegate: false,
                            keepSelectionIfMultiSelectionAllowed: true
                        )
                        // Begin a new range selection by removing the first selected day.
                        firstSelectedDay = nil
                    }
                } else {
                    firstSelectedDay = date
                }
            }
        }

        // Configure footer according to the current selection.
        handleFooter()
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        didDeselectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
    ) {
        // Change the cell's appearance to show the deselected state.
        if let cell = cell {
            handleAppearanceOfCell(cell, using: cellState)
        }

        // Configure footer according to the current selection.
        handleFooter()
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        didScrollToDateSegmentWith visibleDates: DateSegmentInfo
    ) {
        // Set the calendar's header's current state.
        handleCalendarHeader()
    }

    // MARK: Imperatives

    /// Configures the appearance of a given cell when
    /// it's about to be displayed.
    /// - Parameters:
    ///     - cell: The cell being displayed.
    ///     - cellState: The cell's state.
    private func handleAppearanceOfCell(
        _ cell: JTAppleCell,
        using cellState: CellState
    ) {
        // Cast it to the expected instance.
        guard let cell = cell as? CalendarDayCell else {
            assertionFailure("Couldn't cast the cell to a CalendarDayCell's instance.")
            return
        }

        // If the cell is not within the current month, don't display it.
        if cellState.dateBelongsTo != .thisMonth {
            cell.dayTitleLabel.text = ""
            cell.backgroundColor = .clear
            return
        }

        // Set the cell's date text.
        cell.dayTitleLabel.text = cellState.text

        // Change the appearance according to:
        // 1. selection
        // 2. date is in the past or present.
        // 3. is the date in the current day or not.
        // Change the cell's background color to match the selection state.
        if cellState.isSelected {
            cell.backgroundColor = themeColor
            cell.dayTitleLabel.textColor = .white
        } else {
            if cellState.date.isInToday {
                cell.dayTitleLabel.textColor = .black
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.05)
                return
            } else if cellState.date.isPast {
                cell.dayTitleLabel.textColor = UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1)
            } else {
                cell.dayTitleLabel.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
            }

            cell.backgroundColor = .white
        }
    }
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol HabitDaysSelectionViewControllerDelegate: class {

    /// Called when the habit days are done being selected by the user.
    func didSelectDays(_ daysDates: [Date])
}
