//
//  NotificationFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData
@testable import Active

/// Factory in charge of generating Notification (entity) dummies.
struct NotificationFactory: DummyFactory {
    
    // MARK: Types
    
    // This factory generates entities of the Notification class.
    typealias Entity = NotificationMO
    
    // MARK: Properties
    
    var container: NSPersistentContainer
    
    // MARK: Imperatives
    
    /// Generates a Notification (entity) dummy.
    /// - Note: The generated Notification dummy is empty, it doesn't have
    ///         an assciated habit object, and it doesn't have a user
    ///         notification id.
    /// - Returns: A generated Notification dummy as a NSManagedObject.
    func makeDummy() -> NotificationMO {
        // Declare the Notification entity.
        let notification = NotificationMO(context: container.viewContext)
        
        // Associate its properties.
        notification.id = UUID().uuidString
        notification.fireDate = Date(timeInterval: Double(arc4random()), since: Date())
        
        return notification
    }
}
