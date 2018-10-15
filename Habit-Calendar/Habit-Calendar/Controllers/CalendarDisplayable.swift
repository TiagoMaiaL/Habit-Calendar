//
//  CalendarDisplayable.swift
//  Active
//
//  Created by Tiago Maia Lopes on 19/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import JTAppleCalendar

/// Protocol defining the capability to display a calendar.
protocol CalendarDisplayable: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {

    // MARK: Properties

    /// The initial calendar's date.
    var startDate: Date! { get }

    /// The calendar's final date.
    var finalDate: Date! { get }

    /// The cell's reusable identifier.
    var cellIdentifier: String { get }

    /// The calendar view to be displayed.
    var calendarView: JTAppleCalendarView! { get }

    /// THe calendar's header view displaying month information.
    var monthHeaderView: MonthHeaderView! { get }

    /// The title of the month being displayed by the calendar.
    var monthTitleLabel: UILabel! { get }

    /// The header's previous month button.
    var previousMonthButton: UIButton! { get }

    /// The header's next month button.
    var nextMonthButton: UIButton! { get }

    // MARK: Imperatives

    /// Gets the calendar's current month.
    /// - Returns: the current month date.
    func getCurrentMonth() -> Date

    /// Informs if its possible to go the next month.
    func canGoToPreviousMonth() -> Bool

    /// Goes to the previous month in the calendar.
    func goToPreviousMonth()

    /// Informs if its possible to go the previous month.
    func canGoToNextMonth() -> Bool

    /// Goes to the next month in the calendar.
    func goToNextMonth()

    /// Handles the title of the calendar's header view.
    func handleCalendarHeader()

    /// Configures the appearance of a given cell when it's about to be displayed.
    /// - Parameters:
    ///     - cell: The cell being displayed.
    ///     - cellState: The cell's state.
    func handleAppearanceOfCell(_ cell: JTAppleCell, using cellState: CellState)
}

extension CalendarDisplayable {

    func getCurrentMonth() -> Date {
        return calendarView.visibleDates().monthDates.first?.date ?? Date()
    }

    func canGoToPreviousMonth() -> Bool {
        // Get the date for the previous month.
        guard let previousMonth = getCurrentMonth().byAddingMonths(-1) else { return false }
        // Ensure the previousMonth is later (or the same) than the calendar's startDate.
        let comparison = startDate.compare(previousMonth)
        return comparison == .orderedAscending || comparison == .orderedSame
    }

    /// Goes to the previous month in the calendar.
    func goToPreviousMonth() {
        guard let previousMonth = getCurrentMonth().byAddingMonths(-1) else { return }
        if canGoToPreviousMonth() {
            calendarView.scrollToDate(previousMonth)
        }
    }

    func canGoToNextMonth() -> Bool {
        guard let nextMonth = getCurrentMonth().byAddingMonths(1) else { return false }
        // Ensure the nextMonth is before the calendar's endDate.
        return finalDate.compare(nextMonth) == .orderedDescending
    }

    /// Goes to the next month in the calendar.
    func goToNextMonth() {
        guard let nextMonth = getCurrentMonth().byAddingMonths(1) else { return }
        if canGoToNextMonth() {
            calendarView.scrollToDate(nextMonth)
        }
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        didScrollToDateSegmentWith visibleDates: DateSegmentInfo
    ) {
        // Set the calendar's header's current state.
        handleCalendarHeader()
    }

    /// Handles the title of the calendar's header view.
    func handleCalendarHeader() {
        // Get the first month's date or today.
        let firstDate = calendarView.visibleDates().monthDates.first?.date ?? Date()

        // Declare a date formatter to get the month and year.
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM, yyyy")

        // Change the title label to reflect it.
        monthTitleLabel.text = formatter.string(from: firstDate)

        UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) {
            self.previousMonthButton.alpha = self.canGoToPreviousMonth() ? 1 : 0.3
            self.nextMonthButton.alpha = self.canGoToNextMonth() ? 1 : 0.3
        }.startAnimation()
    }
}
