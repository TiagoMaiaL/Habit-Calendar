//
//  UserStorage.swift
//  Active
//
//  Created by Tiago Maia Lopes on 07/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Class in charge of managing user entities.
class UserStorage {
    
    // MARK: Properties
    
    /// The persistent container used by the storage.
    let container: NSPersistentContainer
    
    // MARK: - Initializers
    
    /// Creates a new HabitStorage class using the provided persistent container.
    /// - Parameter container: the persistent container used by the storage.
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    // MARK: - Imperatives
    
    /// Gets the persisted and single User entity.
    /// - Note: Only one user is created by each app.
    /// - Returns: the app's user entity, if it exists.
    // TODO: Check what are the possible exceptions thrown by a fetch.
    func getUser() throws -> User? {
        // Get the request to fetch the user.
        let request: NSFetchRequest<User> = User.fetchRequest()
        // Fetch the app's user.
        let results = try container.viewContext.fetch(request)
        
        // Assert that only one user was persisted.
        assert(results.count <= 1, "UserStorage -- getUser: There's more than one user persisted, only one should be allowed.")
        
        return results.first
    }
    
    /// Creates a new User entity.
    /// - Returns: the newly created user entity.
    func create() -> User {
        let user = User(context: container.viewContext)
        user.created = Date()
        return user
    }
    
    /// Removes the passed User entity.
    func delete() {
        // Declare the request to fetch the user.
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        // Try to get the uniquely created user.
        do {
            let results = try container.viewContext.fetch(request)
            
            // If the fetch worked, assert it only has one user to be deleted.
            assert(results.count == 1, "UserStorage -- delete: There's more than one user to be deleted.")
            
            // Try to delete the only created user.
            self.container.viewContext.delete(results.first!)
        } catch {
            // If it wasn't possible, return, there's nothing to be deleted.
            return
        }
    }
}
