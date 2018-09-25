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

    // MARK: - Imperatives

    /// Gets the persisted and single User entity.
    /// - Note: Only one user is created by each app.
    /// - Parameter context: The context used to fetch the entity.
    /// - Returns: the app's user entity, if it exists.
    func getUser(using context: NSManagedObjectContext) -> UserMO? {
        // Get the request to fetch the user.
        let request: NSFetchRequest<UserMO> = UserMO.fetchRequest()
        // Fetch the app's user.
        let results = try? context.fetch(request)

        // Assert that only one user was persisted.
        assert(
            results?.count ?? 0 <= 1,
            "UserStorage -- getUser: There's more than one user persisted, only one should be allowed."
        )

        return results?.first
    }

    /// Creates a new User entity.
    /// - Parameter context: The context to write the entity to.
    /// - Returns: the newly created user entity.
    func create(using context: NSManagedObjectContext) -> UserMO {
        let user = UserMO(context: context)
        user.id = UUID().uuidString
        user.createdAt = Date()
        return user
    }

    /// Removes the passed User entity.
    /// - Parameter context: The context to delete the entity from.
    func delete(from context: NSManagedObjectContext) {
        // Declare the request to fetch the user.
        let request: NSFetchRequest<UserMO> = UserMO.fetchRequest()

        // Try to get the uniquely created user.
        do {
            let results = try context.fetch(request)

            // If the fetch worked, assert it only has one user to be deleted.
            assert(results.count == 1, "UserStorage -- delete: There's more than one user to be deleted.")

            // Try to delete the only created user.
            context.delete(results.first!)
        } catch {
            // If it wasn't possible, return, there's nothing to be deleted.
            return
        }
    }
}
