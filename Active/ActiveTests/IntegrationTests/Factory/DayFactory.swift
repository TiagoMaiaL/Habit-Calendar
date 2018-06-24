//
//  DayDummyFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating Day (entity) dummies.
struct DayFactory: DummyFactory {
    
    // MARK: Properties
    
    var container: NSPersistentContainer
    
    // MARK: Imperatives
    
    func makeDummy() -> NSManagedObject {
        // Declare a new Day entity.
        let day = Day(context: container.viewContext)
        
        // Configure it's properties (id, date).
        day.id = UUID().uuidString
        day.date = Date()
        
        return day
    }
    
}
