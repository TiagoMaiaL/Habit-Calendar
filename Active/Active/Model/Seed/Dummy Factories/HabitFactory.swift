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
        
        // Associate it's properties (id, created, name, color).
        habit.id = UUID().uuidString
        habit.created = Date()
        habit.name = names[Int.random(0..<names.count)]
        habit.color = HabitMO.Color.green.rawValue
        
        // Declare a NotificationFactory's instance.
        let notificationFactory = NotificationFactory(context: context)
        
        // Declare a DayFactory's instance.
        let dayFactory = DayFactory(context: context)
        
        // Declare a HabitDayFactory's instance.
        let habitDayFactory = HabitDayFactory(context: context)
        
        // Associate it's relationships:
        let randomRange = 0..<Int.random(2..<maxNumberOfDays)
        for dayIndex in randomRange {
            // Declare the current day's date.
            if let dayDate = Date().byAddingDays(dayIndex) {
                
                // Declare the current Day entity:
                var dummyDay: DayMO!
                
                // Try to fetch it from the current day date.
                let request: NSFetchRequest<DayMO> = DayMO.fetchRequest()
                let predicate = NSPredicate(format: "date >= %@ && date <= %@",
                                            dayDate.getBeginningOfDay() as NSDate,
                                            dayDate.getEndOfDay() as NSDate)
                request.predicate = predicate
                let results = try? context.fetch(request)
                
                if results?.isEmpty ?? true {
                    // If none was found, create a new one with the date.
                    dummyDay = dayFactory.makeDummy()
                    dummyDay.date = dayDate
                } else {
                    dummyDay = results?.first!
                }
                
                // Declare the current habit.
                let dummyHabitDay = habitDayFactory.makeDummy()
                // Declare the current notification.
                let dummyNotification = notificationFactory.makeDummy()
                
                // Associate the date to the day and notification entities.
                dummyHabitDay.day = dummyDay
                dummyHabitDay.habit = habit
                dummyNotification.fireDate = dayDate
                
                // Associate the notification and day to the habit entity.
                habit.addToNotifications(
                    dummyNotification
                )
                habit.addToDays(
                    dummyHabitDay
                )
            }
        }
        
        // TODO: Make assertions to check if the dummy has:
        // the days.
        // the notifications.
        
        return habit
    }
}
