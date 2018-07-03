//
//  SeedManager.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Class in charge of seeding entities into sqlite every time the app runs.
class SeedManager {
    
    // MARK: Types
    
    private typealias SeedProcedure = (NSManagedObjectContext) -> ()
    
    // MARK: Properties
    
    /// The container in which the entities are going to be seeded.
    private let container: NSPersistentContainer
    
    /// An array of blocks containing the seeding code in the correct order.
    /// - Note: Every time a new entity needs to be seeded, add a new block
    ///         containing the code in charge of the seed. This array will
    ///         be iterated and the blocks run with a given managed context.
    private let seedProcedures: [SeedProcedure] = [
        { context in
            print("Seeding user.")
            
            // Instantiate a new user factory using the context.
            let userFactory = UserFactory(context: context)
            
            // Make a new dummy.
            _ = userFactory.makeDummy()
        },
        { context in
            print("Seeding habits.")
            
            // Instantiate a new Habit factory using the context.
            let habitFactory = HabitFactory(context: context)
            
            // Make a new dummy.
            let habit = habitFactory.makeDummy()
            
            // Associate it's user.
            guard let user = try? context.fetch(UserMO.fetchRequest()).first as? UserMO else {
                assertionFailure("Couldn't get the seeded user.")
                return
            }
            habit.user = user
        },
    ]
    
    // MARK: Initializers
    
    /// - Parameter container: The container used when seeding the entities.
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    // MARK: Imperatives
    
    /// Seeds the sqlite database using the provided container and running the
    /// each code in the array of seed procedures defined internally.
    func seed() {
        // Get a background context.
        container.performBackgroundTask { context in
            print("===========================================================")
            
            // Iterate over each seed procedure and call each one passing
            // the context.
            for procedure in self.seedProcedures {
                procedure(context)
            }
            
            do {
                try context.save()
            } catch {
                print("\nOops =(")
                print("There was an error when trying to save the seed context:")
                print(error.localizedDescription)
            }
            
            self.printEntitiesCount()
            
            print("===========================================================")
        }
    }
    
    /// Erases the database and the seeded entities.
    func erase() {
        // Iterate through each internal persitent stores
        // and remove each one of them.
        print("Removing seeded entities.")
        container.persistentStoreCoordinator.persistentStores.forEach { store in
            let currentURL = container.persistentStoreCoordinator.url(for: store)
            
            try! container.persistentStoreCoordinator.destroyPersistentStore(
                at: currentURL,
                ofType: ".sqlite"
            )
        }
    }
    
    /// Prints the number of entities within the database after the seed.
    /// - Note: Every time a new entity class is added and seeded, this code
    ///         will need to be modified to print the new entity's count.
    private func printEntitiesCount() {
        // Declare a dictionary containing the entities and fetch requests
        // for each one of them.
        let entities = [
            "User": UserMO.fetchRequest(),
            "Habit": HabitMO.fetchRequest(),
            "HabitDay": HabitDayMO.fetchRequest(),
            "Notification": NotificationMO.fetchRequest(),
            "Day": DayMO.fetchRequest()
        ]
        
        // Iterate through the dictionary and print the count of each entity.
        print("\nSeed results:")
        for (entity, fetchRequest) in entities {
            let count = (try? container.viewContext.count(for: fetchRequest)) ?? 0
            print("The number of \(entity) entities in the database is: \(count)")
        }
    }
}
