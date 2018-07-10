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
    }
    
    // MARK: Actions
    
    @IBAction func selectDay(_ sender: UIButton) {
        // TODO: Pass the selected array of dates.
        
        // Pop the current controller.
        navigationController?.popViewController(animated: true)
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
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        // TODO:
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        // TODO:
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
        
        // TODO: Set the appearance according to selection.
        
        switch cellState.dateBelongsTo {
        case .thisMonth:
            cell.dayTitleLabel.alpha = 1
        default:
            cell.dayTitleLabel.alpha = 0.5
        }
    }
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol HabitDaysSelectionViewControllerDelegate: class {
    
    /// Called when the habit days are done being selected by the user.
    func didSelectDays(_ daysDates: [Date])
}
