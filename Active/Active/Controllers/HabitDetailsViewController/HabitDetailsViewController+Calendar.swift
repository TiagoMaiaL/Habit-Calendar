//
//  HabitDetailsViewController+Calendar.swift
//  Active
//
//  Created by Tiago Maia Lopes on 22/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import JTAppleCalendar

/// Adds the calendar capabilities to the habit details controller.
extension HabitDetailsViewController: CalendarDisplaying {

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

        if cellState.dateBelongsTo == .thisMonth {
            cell.dayTitleLabel.text = cellState.text

            // Try to get the matching challenge for the current date.
            if let challenge = getChallenge(from: cellState.date) {
                // Get the habitDay associated with the cell's date.
                guard let habitDay = challenge.getDay(for: cellState.date) else {
                    // If there isn't a day associated with the date, there's a bug.
                    assertionFailure("Inconsistency: a day should be returned from the challenge.")
                    return
                }

                // If there's a challenge, show cell as being part of it.
                let habitColor = HabitMO.Color(rawValue: habit.color)?.getColor()

                cell.backgroundColor = habitDay.wasExecuted ? habitColor : habitColor?.withAlphaComponent(0.5)
                cell.dayTitleLabel.textColor = .white

                if cellState.date.isInToday {
                    cell.circleView.backgroundColor = .white
                    cell.dayTitleLabel.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
                } else if cellState.date.isFuture {
                    // Days to be completed in the future should have a less bright color.
                    cell.backgroundColor = cell.backgroundColor?.withAlphaComponent(0.3)
                }
            }
        } else {
            cell.dayTitleLabel.text = ""
            cell.backgroundColor = .white
        }
    }
}

extension HabitDetailsViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    // MARK: JTAppleCalendarViewDataSource Methods

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(
            startDate: startDate,
            endDate: finalDate
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

        guard let dayCell = cell as? CalendarDayCell else {
            assertionFailure("Couldn't get the expected details calendar cell.")
            return cell
        }
        handleAppearanceOfCell(dayCell, using: cellState)

        return dayCell
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        willDisplay cell: JTAppleCell,
        forItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
        ) {
        guard let dayCell = cell as? CalendarDayCell else {
            assertionFailure("Couldn't get the expected details calendar cell.")
            return
        }
        handleAppearanceOfCell(dayCell, using: cellState)
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        shouldSelectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
        ) -> Bool {
        return false
    }
}
