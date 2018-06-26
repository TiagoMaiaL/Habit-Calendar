//
//  Habit.swift
//  Active
//
//  Created by Tiago Maia Lopes on 01/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// The Habit model entity.
/// - Note: The user can have as many habits as he/she wants.
class Habit: NSManagedObject {
    
    // MARK: Properties
    
    /// The count of days in which the habit was marked
    /// as executed.
    var executedCount: Int {
        let predicate = NSPredicate(
            format: "wasExecuted == true"
        )
        return days?.filtered(using: predicate).count ?? 0
    }
    
    /// The percentage of executed days out of all days.
    var executionPercentage: Double {
        if let daysCount = days?.count,
            daysCount > 0 {
            return Double(executedCount) / Double(daysCount) * 100
        }
        return 0
    }
    
    // MARK: Life cycle
    
    override func prepareForDeletion() {
        // TODO: Check what needs to be done in case of a deletion in this entity.
    }
    
    // MARK: Imperatives
    
    /// Gets the habit title text.
    /// - Note: The habit title text may be used for user notifications
    ///         and to display the habit's info in the list or graphics.
    /// - Returns: The habit's title string.
    func getTitleText() -> String {
        assert(name != nil, "Habit's name must have a value.")
        return name!
    }
    
    /// Gets the habit subtitle text.
    /// - Note: The habit subtitle text may be used for user
    ///         notifications and to display the habit's info.
    /// - Returns: The habit's subtitle string.
    func getSubtitleText() -> String {
        // TODO: Make this localized.
        return "Have you practiced this activity?"
    }
    
    /// Gets the habit description text.
    /// - Note: The habit description text is used for user
    ///         notifications.
    /// - Returns: The habit's description string.
    func getDescriptionText() -> String {
        return ""
    }
}

/// Enum representing all possible colors a habit entity can have as a property.
enum HabitColor {
    
    /// The habit color associated with the entity.
    
    // TODO: Describe the possible colors.
    case green
    case blue
    case red
    case purple
    
    // TODO: Write a method in charge of creating the Color from the stored color string.
    
    /// Used to get the color's string identifier for storage porpuses.
    /// - Return: the color's string.
    func getPersistenceIdentifier() -> String {
        // TODO: check to see if there's a better way to associate the persistence string with the enum.
        // TODO: Implement the method.
        return ""
    }
}

