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

    // MARK: Types
    
    // This factory generates entities of the User class.
    typealias Entity = UserMO
    
    // MARK: Properties
    
    var container: NSPersistentContainer
    
    // MARK: Imperatives
    
    /// Creates an User entity object.
    func makeDummy() -> UserMO {
        // Create the entity.
        let user = UserMO(context: container.viewContext)
        
        // Configure it's properties.
        user.id = UUID().uuidString
        user.created = Date()
        
        return user
    }
}
