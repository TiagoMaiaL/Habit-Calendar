//
//  Habit.swift
//  Active
//
//  Created by Tiago Maia Lopes on 01/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// The Habit model entity.
class Habit: NSManagedObject {

    /// The habit color associated with the entity.
    enum Color {
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
}



