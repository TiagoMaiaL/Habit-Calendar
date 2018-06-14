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
    
    // MARK: Life cycle
    
    override func prepareForDeletion() {
        // TODO: Check what needs to be done in case of a deletion in this entity.
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

