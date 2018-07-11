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
    
    /// The title of the month being displayed by the calendar.
    @IBOutlet weak var monthTitleLabel: UILabel!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configute the calendar's header initial state.
        handleCalendarHeader()
    }
    
    /// The user's first selected date.
    private var firstSelectedDay: Date?
    
    // MARK: Actions
    
    @IBAction func selectDays(_ sender: UIButton) {
        // Pass the selected dates to the delegate.
        delegate?.didSelectDays(calendarView.selectedDates)
        
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
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
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
        
        // Set the cell's date text.
        cell.dayTitleLabel.text = cellState.text
        
        // Change the appearance according to:
        // 1. selection
        // 2. date is in the past or present.
        // 3. is the date in the current day or not.
        
        // Change the cell's background color to match the selection state.
        if cellState.isSelected {
            cell.backgroundColor = .green
        } else {
            cell.backgroundColor = .white
            
            switch cellState.dateBelongsTo {
            case .thisMonth:
                cell.dayTitleLabel.alpha = 1
            default:
                // Not in the month.
                cell.dayTitleLabel.alpha = 0.5
            }
            
            if cellState.date.isInToday {
                cell.backgroundColor = .purple
            } else if cellState.date.isPast {
                cell.backgroundColor = .gray
                cell.alpha = 0.2
            }
        }
    }
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol HabitDaysSelectionViewControllerDelegate: class {
    
    /// Called when the habit days are done being selected by the user.
    func didSelectDays(_ daysDates: [Date])
}
