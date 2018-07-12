//
//  HabitDetailsViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

class HabitDetailsViewController: UIViewController {

    // MARK: Properties
    
    /// The habit presented by this controller.
    var habit: HabitMO!
    
    /// The habit storage used to manage the controller's habit.
    var habitStorage: HabitStorage!
    
    /// The persistent container used by this store to manage the
    /// provided habit.
    var container: NSPersistentContainer!
    
    /// View holding the prompt to ask the user if the activity
    /// was executed in the current day.
    @IBOutlet weak var promptView: UIView!
    
    /// The positive prompt button.
    @IBOutlet weak var positivePromptButton: UIButton!
    
    /// The negative prompt button.
    @IBOutlet weak var negativePromptButton: UIButton!
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assert on the required properties to be injected
        // (habit, habitStorage, container):
        assert(
            habit != nil,
            "Error: the needed habit wasn't injected."
        )
        assert(
            habitStorage != nil,
            "Error: the needed habitStorage wasn't injected."
        )
        assert(
            container != nil,
            "Error: the needed container wasn't injected."
        )
        
        title = habit.name
    }
    
    // MARK: Actions
    
    @IBAction func deleteHabit(_ sender: UIButton) {
        // Alert the user to see if the deletion is really wanted:
        
        // Declare the alert.
        let alert = UIAlertController(
            title: "Delete",
            message: "Are you sure you want to delete this habit? Deleting this habit makes all the history information unavailable.",
            preferredStyle: .alert
        )
        // Declare its actions.
        alert.addAction(UIAlertAction(title: "delete", style: .destructive) { _ in
            // If so, delete the habit using the container's viewContext.
            // Pop the current controller.
            self.habitStorage.delete(
                self.habit, from:
                self.container.viewContext
            )
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "cancel", style: .default))
        
        // Present it.
        present(alert, animated: true)
    }
    
    @IBAction func savePromptResult(_ sender: UIButton) {
        print("=D")
    }
    
    // MARK: Imperatives
    
    /// Show the prompt view if today is a day(HabitDayMO) being tracked
    /// by the app.
    private func handlePrompt() {
        // Try to get a habit day for today.
    }
    
    
}
