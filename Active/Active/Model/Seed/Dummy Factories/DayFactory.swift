//
//  DayDummyFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating DayMO dummies.
struct DayFactory: DummyFactory {
    
    // MARK: Types
    
    // This factory generates entities of the Day class.
    typealias Entity = DayMO
    
    // MARK: Properties
    
    var context: NSManagedObjectContext
    
    // MARK: Imperatives
    
    /// Makes a day entity with the current day as it's date.
    /// - Returns: A new day entity.
    func makeDummy() -> DayMO {
        // Declare a new Day entity.
        let day = DayMO(context: context)
        
        // Configure it's properties (id, date).
        day.id = UUID().uuidString
        day.date = Date()
        
        return day
    }
    
}
