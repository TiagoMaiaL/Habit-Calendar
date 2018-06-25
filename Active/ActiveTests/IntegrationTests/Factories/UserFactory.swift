//
//  UserDummyFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData
@testable import Active

/// Factory in charge of generating User (entity) dummies.
struct UserFactory: DummyFactory {
    
    // MARK: Properties
    
    var container: NSPersistentContainer
    
    // MARK: Imperatives
    
    /// Creates an User entity object.
    func makeDummy() -> NSManagedObject {
        // Create the entity.
        let user = User(context: container.viewContext)
        
        // Configure it's properties.
        user.id = UUID().uuidString
        user.created = Date()
        
        return user
    }
}
