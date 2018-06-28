//
//  HabitFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData
@testable import Active

/// Factory in charge of generating Day (entity) dummies.
struct HabitFactory: DummyFactory {
    
    // MARK: Types
    
    // This factory generates entities of the Habit class.
    typealias Entity = Habit
    
    // MARK: Properties
    
    var container: NSPersistentContainer
    
    // MARK: Imperatives
    
    /// Generates and returns a Habit dummy entity.
    /// - Note: The dummy is related to other HabitDay
    ///         and Notification dummies.
    /// - Returns: The Habit entity as an NSManagedObject.
    func makeDummy() -> Habit {
        // Declare the habit entity.
        let habit = Habit(context: container.viewContext)
        
        // Associate it's properties (id, created, name, color).
        habit.id = UUID().uuidString
        habit.created = Date()
        habit.name = "Dummy Habit"
        habit.color = "Green"
        
        // Declare a NotificationFactory's instance.
        let notificationFactory = NotificationFactory(container: container)
        
        // Declare a HabitDayFactory's instance.
        let habitDayFactory = HabitDayFactory(container: container)
        
        // TODO: Make the days and notifications become random.
        // Associate it's relationships:
        // Associate 3 Notification dummies.
        // Associate 3 HabitDay dummies.
        for _ in 1...3 {
            habit.addToNotifications(
                notificationFactory.makeDummy()
            )
            habit.addToDays(
                habitDayFactory.makeDummy()
            )
        }
        
        return habit
    }
}
