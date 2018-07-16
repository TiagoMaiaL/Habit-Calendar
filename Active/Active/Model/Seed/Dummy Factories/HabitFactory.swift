//
//  HabitFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating DayMO dummies.
struct HabitFactory: DummyFactory {
    
    // MARK: Types
    
    // This factory generates entities of the Habit class.
    typealias Entity = HabitMO
    
    // MARK: Properties
    
    var context: NSManagedObjectContext
    
    /// The maximum number of days contained within the generated dummy.
    private let maxNumberOfDays = 61
    
    /// A collection of dummy habit names.
    private let names = [
        "Play the guitar",
        "Play the piano",
        "Go jogging",
        "Play chess",
        "Read",
        "Go swimming",
        "Workout",
        "Write",
        "Study math",
        "Program",
        "Learn to dance"
    ]
    
    // MARK: Imperatives
    
    /// Generates and returns a Habit dummy entity.
    /// - Note: The dummy is related to other HabitDay
    ///         and Notification dummies.
    /// - Returns: The Habit entity as an NSManagedObject.
    func makeDummy() -> HabitMO {
        // Declare the habit entity.
        let habit = HabitMO(context: context)
        
        // Associate its properties (id, created, name, color).
        habit.id = UUID().uuidString
        habit.created = Date()
        habit.name = names[Int.random(0..<names.count)]
        habit.color = HabitMO.Color.green.rawValue
        
        // Associate its relationships:
        let notificationFactory = NotificationFactory(context: context)
        let sequenceFactory = DaysSequenceFactory(context: context)
        let dummySequence = sequenceFactory.makeDummy()
        dummySequence.habit = habit
        
        if let habitDays = dummySequence.days as? Set<HabitDayMO> {
            for habitDay in habitDays {
                habitDay.habit = habit
                
                let notification = notificationFactory.makeDummy()
                notification.fireDate = habitDay.day!.date
                notification.habit = habit
            }
        }
        
        assert(
            (habit.daysSequences?.count ?? 0) > 0,
            "The generated dummy habit must have a sequence."
        )
        assert(
            (habit.notifications?.count ?? 0) > 0,
            "The generated dummy habit must have notifications."
        )
        
        return habit
    }
}
