//
//  DevelopmentSeeder.swift
//  Active
//
//  Created by Tiago Maia Lopes on 08/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

class DevelopmentSeeder: Seeder {

    // MARK: Properties

    /// The procedures to be called in order to seed the database.
    private let _seedProcedures: [SeedProcedure] = [ {
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

            // Make some of the habits in the set become habits in progress.
            // Habits in progress are habits that have an active days' challenge with some days already executed.
            let habitsRequest: NSFetchRequest<HabitMO> = HabitMO.fetchRequest()
            if let habits = try? context.fetch(habitsRequest) {
                // Get only the first two
                for index in 0...3 {
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
            print("Seeding completed habits.")

            // Get the previously seeded user.
            guard let user = try? context.fetch(UserMO.fetchRequest()).first as? UserMO else {
                assertionFailure("Couldn't get the seeded user.")
                return
            }

            // Completed habits are habits that don't have any active days' challenge.

            // Declare two new dummies, add past ones.
            let habitFactory = HabitFactory(context: context)
            let challengeFactory = DaysChallengeFactory(context: context)
            for _ in 0..<2 {
                let dummyHabit = habitFactory.makeDummy()

                // Remove their current challenges.
                if let challengesSet = dummyHabit.challenges as? Set<DaysChallengeMO> {
                    for challenge in challengesSet {
                        // Remove the challenge's days.
                        if let daysSet = challenge.days as? Set<HabitDayMO> {
                            for day in daysSet {
                                dummyHabit.removeFromDays(day)
                                context.delete(day)
                            }
                        }

                        dummyHabit.removeFromChallenges(challenge)
                        context.delete(challenge)
                    }
                }

                let completedChallenge = challengeFactory.makeCompletedDummy()
                for day in completedChallenge.days! {
                    if let day = day as? HabitDayMO {
                        day.habit = dummyHabit
                    }
                }
                dummyHabit.addToChallenges(completedChallenge)
                dummyHabit.user = user
            }
        }, {
            context in

            // Useful for testing the whole challenge's life cycle: begin, middle (in progress), and end.
            print("Seeding habits with challenges in their final days.")

            // Get the previously seeded user.
            guard let user = try? context.fetch(UserMO.fetchRequest()).first as? UserMO else {
                assertionFailure("Couldn't get the seeded user.")
                return
            }
            let challengeFactory = DaysChallengeFactory(context: context)

            let dummyHabit = HabitFactory(context: context).makeDummy()
            dummyHabit.user = user

            // Remove their current challenges.
            if let challengesSet = dummyHabit.challenges as? Set<DaysChallengeMO> {
                for challenge in challengesSet {
                    // Remove the challenge's days.
                    if let daysSet = challenge.days as? Set<HabitDayMO> {
                        for day in daysSet {
                            dummyHabit.removeFromDays(day)
                            context.delete(day)
                        }
                    }

                    dummyHabit.removeFromChallenges(challenge)
                    context.delete(challenge)
                }
            }

            let endingDates = [Date().byAddingDays(-1), Date()].compactMap { $0 }
            let endingChallenge = challengeFactory.makeDummy(using: endingDates)

            guard let days = endingChallenge.days as? Set<HabitDayMO> else {
                assertionFailure("Couldn't get the dummy's challenge's days.")
                return
            }
            endingChallenge.habit = dummyHabit
            for day in days {
                day.habit = dummyHabit
            }

            dummyHabit.addToChallenges(endingChallenge)
        }
    ]

    override var seedProcedures: [Seeder.SeedProcedure] {
        return _seedProcedures
    }

    // MARK: Imperatives

    override func erase() {
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
}
