//
//  HabitDaysSelectionViewController+Calendar.swift
//  Active
//
//  Created by Tiago Maia Lopes on 26/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import JTAppleCalendar

/// Adds the code to handle the selection of dates.
extension HabitDaysSelectionViewController {

    /// Handles the selection of dates within the calendar.
    /// - Parameter date: the Date being selected.
    func select(_ date: Date) {
        if shouldApplyRangeSelection {
            // The range should continue from the last selected date.
            var lastDate = firstSelectedDay
            if calendarView.selectedDates.count > 1 {
                lastDate = calendarView.selectedDates.sorted()[calendarView.selectedDates.endIndex - 2]
            }
            calendarView.selectDates(
                from: lastDate,
                to: date,
                triggerSelectionDelegate: false,
                keepSelectionIfMultiSelectionAllowed: true
            )
        }
    }

    /// Checks if the passed date should be deselected or not.
    /// - Parameter date: The date to be deselected.
    /// - Returns: a Bool indicating if the date should be deselected.
    func shouldDeselect(_ date: Date) -> Bool {
        // Only allow deselection if the date isn't today.
        return !date.isInToday
    }

    /// Deselects all dates, except today (which must be always the first challenge's day).
    func clearSelection() {
        calendarView.deselectAllDates()
    }

    /// Checks if the current selected dates in the calendar are valid dates for the challenge to be created.
    /// - Returns: a Bool indicating if the selection is a valid one.
    func isCurrentSelectionValid() -> Bool {
        return calendarView.selectedDates.count >= 2
    }
}

extension HabitDaysSelectionViewController: CalendarDisplayable {

    // MARK: Imperatives

    /// Configures the appearance of a given cell when it's about to be displayed.
    /// - Parameters:
    ///     - cell: The cell being displayed.
    ///     - cellState: The cell's state.
    internal func handleAppearanceOfCell(
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

            if cellState.date.isInToday {
                cell.circleView.backgroundColor = .white
                cell.dayTitleLabel.textColor = .black
            }
        } else {
            if cellState.date.isPast {
                cell.dayTitleLabel.textColor = UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1)
            } else {
                cell.dayTitleLabel.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
            }

            cell.backgroundColor = .white
        }
    }
}

extension HabitDaysSelectionViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    // MARK: JTAppleCalendarViewDataSource Methods

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(
            startDate: startDate,
            endDate: finalDate,
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
        shouldDeselectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
    ) -> Bool {
        return shouldDeselect(date)
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        didSelectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
        ) {
        // Change the cell's appearance to show the selected state.
        if let cell = cell {
            select(date)
            handleAppearanceOfCell(cell, using: cellState)
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
}
