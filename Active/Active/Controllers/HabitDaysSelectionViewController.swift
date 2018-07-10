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
    
    // The cell's reusable identifier.
    private let cellIdentifier = "day collection view cell"

    /// The calendar view with the days to be selected.
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    /// The button the user uses to tell when he's done.
    @IBOutlet weak var doneButton: UIButton!
    
    /// The delegate in charge of receiving days selected by the user.
    weak var delegate: HabitDaysSelectionViewControllerDelegate?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the calendar view.
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
    }
    
    /// The user's first selected date.
    private var firstSelectedDay: Date?
    
    // MARK: Actions
    
    @IBAction func selectDays(_ sender: UIButton) {
        // TODO: Pass the selected array of dates.
        
        // Pop the current controller.
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Imperatives
    
    /// Handles the interaction of the done button according to
    /// the selected days.
    private func handleDoneButton() {
        // Enable/Disable the button if the dates are selected or not.
        doneButton.isEnabled = !calendarView.selectedDates.isEmpty
    }
}

extension HabitDaysSelectionViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    // MARK: JTAppleCalendarViewDataSource Methods
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let now = Date()
        guard let endDate = now.byAddingYears(2) else {
            assertionFailure(
                "Couldn't get the date by adding two years from now."
            )
            return ConfigurationParameters(
                startDate: now,
                endDate: now
            )
        }
        
        let parameters = ConfigurationParameters(
            startDate: now,
            endDate: endDate,
            hasStrictBoundaries: true
        )
        return parameters
    }
    
    // MARK: JTAppleCalendarViewDelegate Methods
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        // Dequeue the cell.
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath
        )
        
        // Configure its appearance.
        handleAppearanceOfCell(cell, using: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // Configure its appearance.
        handleAppearanceOfCell(cell, using: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        // The user can only select a date in the future.
        return date.isFuture || date.isInToday
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        // Change the cell's appearance to show the selected state.
        if let cell = cell {
            handleAppearanceOfCell(cell, using: cellState)
            
            // Configure the range according to the tap.
            if let firstDay = firstSelectedDay {
                calendar.selectDates(
                    from: firstDay,
                    to: date,
                    triggerSelectionDelegate: false,
                    keepSelectionIfMultiSelectionAllowed: true
                )
            } else {
                firstSelectedDay = date
            }
        }
        
        // Handle the done button's state.
        handleDoneButton()
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        // Change the cell's appearance to show the deselected state.
        if let cell = cell {
            handleAppearanceOfCell(cell, using: cellState)
        }
        
        // Handle the done button's state.
        handleDoneButton()
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
        
        // Set the cell's date text.
        cell.dayTitleLabel.text = cellState.text
        
        // Change the appearance according to selection and if the
        // date is within the month or not.
        
        // Change the cell's background color to match the selection state.
        if cellState.isSelected {
            cell.backgroundColor = .green
        } else {
            cell.backgroundColor = nil
        }
        
        switch cellState.dateBelongsTo {
        case .thisMonth:
            cell.dayTitleLabel.alpha = 1
        default:
            cell.dayTitleLabel.alpha = 0.3
        }
    }
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol HabitDaysSelectionViewControllerDelegate: class {
    
    /// Called when the habit days are done being selected by the user.
    func didSelectDays(_ daysDates: [Date])
}
