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
    
    /// The maximum number of days contained within the generated dummy.
    let maxNumberOfDays = 61
    
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
        // TODO: make the name and color properties become random.
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
        let randomRange = 0..<Int.random(2..<maxNumberOfDays)
        for dayIndex in randomRange {
            // Declare the current day's date.
            if let dayDate = Date().byAddingDays(dayIndex) {
                
                // Declare the current habit.
                let dummyHabitDay = habitDayFactory.makeDummy()
                // Declare the current notification.
                let dummyNotification = notificationFactory.makeDummy()
                
                // Associate the date to the day and notification entities.
                dummyHabitDay.day?.date = dayDate
                dummyNotification.fireDate = dayDate
                
                habit.addToNotifications(
                    dummyNotification
                )
                habit.addToDays(
                    dummyHabitDay
                )
            }
        }
        
        return habit
    }
}
