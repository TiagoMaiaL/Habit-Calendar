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

    private typealias SeedProcedure = (NSManagedObjectContext) -> Void

    // MARK: Properties

    /// The container in which the entities are going to be seeded.
    private let container: NSPersistentContainer

    /// An array of blocks containing the seeding code in the correct order.
    /// - Note: Every time a new entity needs to be seeded, add a new block
    ///         containing the code in charge of the seed. This array will
    ///         be iterated and the blocks run with a given managed context.
    private let seedProcedures: [SeedProcedure] = [ {
            context in
            print("Seeding user.")

            // Try to fetch any users in the database.
            let request: NSFetchRequest<UserMO> = UserMO.fetchRequest()
            let results = try? context.fetch(request)

            // If there's already a saved UserMO,
            // don't proceed with the user seed.
            if let results = results, !results.isEmpty {
                return
            }

            // Instantiate a new user factory using the context.
            let userFactory = UserFactory(context: context)

            // Make a new dummy.
            _ = userFactory.makeDummy()
        }, {
            context in
            print("Seeding habits to begin.")

            // Get the previously seeded user.
            guard let user = try? context.fetch(UserMO.fetchRequest()).first as? UserMO else {
                assertionFailure("Couldn't get the seeded user.")
                return
            }

            let habitsCount = 7

            // Instantiate a new Habit factory using the context.
            let habitFactory = HabitFactory(context: context)

            for _ in 1...habitsCount {
                // Make a new dummy.
                let habit = habitFactory.makeDummy()

                // Associate the habit's user.
                habit.user = user
            }
        }, {
            context in
            print("Seeding habits in progress.")

            // Make the first two habits in the set become habits in progress.
            // Habits in progress are habits that have an active days' challenge with some days already executed.
            let habitsRequest: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
            if let habits = try? context.fetch(habitsRequest) {
                // Get only the first two
                for index in 0...1 {
                    // Append a random amount of past days to the current habit.
                    let randomPastDays = (Int.random(-30 ..< -2) ..< 0).compactMap {
                        Date().getBeginningOfDay().byAddingDays($0)
                    }
                    let pastHabitDays = randomPastDays.map { date -> DayMO in
                        let day = DayMO(context: context)
                        day.date = date
                        day.id = UUID().uuidString

                        return day
                    }.map { day -> HabitDayMO in
                        let habitDay = HabitDayMO(context: context)
                        habitDay.id = UUID().uuidString
                        habitDay.day = day
                        // The wasExecuted property will be a random boolean.
                        habitDay.wasExecuted = arc4random_uniform(2) == 0

                        return habitDay
                    }

                    let habit = habits[index]
                    habit.addToDays(Set(pastHabitDays) as NSSet)
                    habit.getCurrentChallenge()?.addToDays(Set(pastHabitDays) as NSSet)
                    habit.getCurrentChallenge()?.fromDate = randomPastDays.first
                }
            }
        }, {
            context in
            print("Seeding random offensives to the habits that have past days.")

            // Get the challenges that have past habit days.
            let pastPredicate = NSPredicate(
                format: "fromDate < %@",
                Date().getBeginningOfDay() as NSDate
            )
            let challengesRequest: NSFetchRequest<DaysChallengeMO> = DaysChallengeMO.fetchRequest()
            challengesRequest.predicate = pastPredicate

            if let challenges = try? context.fetch(challengesRequest) {
                // Add an OffensiveMO to each challenge.
                // TODO:
            }
        }
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

    /// Removes all previously seeded entities from the persistent stores.
    func erase() {
        print("Removing seeded entities.")

        // Declare the context to be used for the seed erase.
        let context = container.viewContext

        // Delete all DayMO entities.
        let daysRequest: NSFetchRequest<DayMO> = DayMO.fetchRequest()

        if let days = try? context.fetch(daysRequest) {
            for day in days {
                context.delete(day)
            }
        }

        // Get a new user storage instance.
        let userStorage = UserStorage()

        // Get the current user.
        if let user = userStorage.getUser(using: context) {
            // Delete it.
            context.delete(user)
        }

        // Save the context.
        do {
            try context.save()
        } catch {
            assertionFailure("Error when erasing the seed.")
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
