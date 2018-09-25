//
//  Seeder.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Class in charge of seeding entities into sqlite every time the app runs.
class Seeder {

    // MARK: Types

    typealias SeedProcedure = (NSManagedObjectContext) -> Void

    // MARK: Properties

    /// The container in which the entities are going to be seeded.
    let container: NSPersistentContainer

    /// The basic seeds to be applied in any kind of environment and situation.
    /// - Note: An User entity is always needed, so the base Seeder class always seeds it.
    private let baseProcedures: [SeedProcedure] = [ {
        context in
        print("Seeding user.")

        // Create the base user if necessary.
        let userStorage = UserStorage()
        if userStorage.getUser(using: context) == nil {
            _ = userStorage.create(using: context)
        }
    }]

    /// An array of blocks containing the seeding code in the desired order.
    /// - Note: Every time a new entity needs to be seeded, add a new block
    ///         containing the code in charge of the seed. This array will
    ///         be iterated and the blocks run with a given managed context.
    var seedProcedures: [SeedProcedure] {
        // The base seeder doesn't apply any specific seeds.
        return []
    }

    // MARK: Initializers

    /// - Parameter container: The container used when seeding the entities.
    init(container: NSPersistentContainer) {
        self.container = container
    }

    // MARK: Imperatives

    /// Seeds the sqlite database using the provided container and running the
    /// each code in the array of seed procedures defined internally.
    final func seed() {
        // Get a background context.
        container.performBackgroundTask { context in
            print("===========================================================")

            // Iterate over each seed procedure and call each one passing the context.
            // Seed the base precedures (to be always applied).
            let procedures = self.baseProcedures + self.seedProcedures

            for procedure in procedures {
                procedure(context)
            }

            do {
                try context.save()
            } catch {
                print("\nOops =(")
                print("There was an error when trying to save the seed context:")
                print(error.localizedDescription)
                print(error)
            }

            self.printEntitiesCount()

            print("===========================================================")
        }
    }

    /// Removes all previously seeded entities from the persistent stores.
    func erase() {
        assertionFailure("Error: erase() shouldn't be called in the base seeder instances.")
    }

    /// Prints the number of entities within the database after the seed.
    /// - Note: Every time a new entity class is added and seeded, this code
    ///         will need to be modified to print the new entity's count.
    func printEntitiesCount() {
        // Declare a dictionary containing the entities and fetch requests
        // for each one of them.
        let entities = [
            "User": UserMO.fetchRequest(),
            "Habit": HabitMO.fetchRequest(),
            "Challenge": DaysChallengeMO.fetchRequest(),
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
