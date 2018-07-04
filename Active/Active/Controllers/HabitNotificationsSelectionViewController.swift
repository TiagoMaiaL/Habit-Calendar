//
//  HabitNotificationsSelectionViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 04/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The controller used to select the notification fire dates for the
/// habit being created/edited.
class HabitNotificationsSelectionViewController: UIViewController {

    // MARK: Properties
    
    /// The picker the user uses to select the fire date.
    @IBOutlet weak var timePickerView: UIDatePicker!
    
    /// The delegate in charge of receiving the selected fire dates.
    weak var delegate: HabitNotificationsSelectionViewControllerDelegate?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Associate the event listener to the timePicker.
//        time
    }
    
    // MARK: Actions
    
    @IBAction func selectFireDates(_ sender: UIButton) {
        // Call the delegate passing the fire dates selected
        // by the user.
        delegate?.didSelectFireDates([timePickerView.date])
        
        navigationController?.popViewController(animated: true)
    }
}

/// The controller's delegate in charge of receiving the selected days dates.
protocol HabitNotificationsSelectionViewControllerDelegate: class {
    
    /// Called when the habit days are done being selected by the user.
    func didSelectFireDates(_ fireDates: [Date])
    
}
