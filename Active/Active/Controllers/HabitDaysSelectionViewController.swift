//
//  HabitDaysSelectionViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 04/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The controller used to select the days in which the habit is
/// going to be tracked.
class HabitDaysSelectionViewController: UIViewController {

    // MARK: Properties

    /// The picker view used to select the day.
    @IBOutlet weak var dayPickerView: UIDatePicker!
    
    /// The button the user uses to tell when he's done.
    @IBOutlet weak var doneButton: UIButton!
    
    /// The delegate in charge of receiving days selected by the user.
    weak var delegate: HabitDaysSelectionViewControllerDelegate?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    
    @IBAction func selectDay(_ sender: UIButton) {
        // Get the picker's date and pass it to the delegate.
        let dayDate = dayPickerView.date
        delegate?.didSelectDays([dayDate])
        
        // Pop the current controller.
        navigationController?.popViewController(animated: true)
    }
    
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol HabitDaysSelectionViewControllerDelegate: class {
    
    /// Called when the habit days are done being selected by the user.
    func didSelectDays(_ daysDates: [Date])
    
}
