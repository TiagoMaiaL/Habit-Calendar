//
//  DaysChallengeStorage.swift
//  Active
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// Class in charge of managing the DaysChallengeMO entities.
class DaysChallengeStorage {

    // MARK: Properties

    /// The habitDayStorage used to create the days.
    private let habitDayStorage: HabitDayStorage

    // MARK: Initializers

    init(habitDayStorage: HabitDayStorage) {
        self.habitDayStorage = habitDayStorage
    }

    // MARK: Imperatives

    /// Creates a challenge entity by using the provided days' dates and the
    /// associated habit.
    /// - Parameters:
    ///     - context: The context to which the entity is added.
    ///     - daysDates: The days' dates used to create the challenge days.
    ///     - habit: The habit entity to which the challenge is added.
    /// - Returns: A new days challenge associated with the habit.
    func create(
        using context: NSManagedObjectContext,
        daysDates: [Date],
        and habit: HabitMO
    ) -> DaysChallengeMO {
        assert(
            daysDates.count > 1,
            "The provided days dates must have two or more dates."
        )
        let daysDates = daysDates.map { $0.getBeginningOfDay() }
        let challenge = DaysChallengeMO(context: context)

        // Configure its main properties:
        challenge.id = UUID().uuidString
        challenge.createdAt = Date()
        challenge.fromDate = daysDates.sorted().first!
        challenge.toDate = daysDates.sorted().last!

        // Associate its habit entity.
        challenge.habit = habit

        // Configure its days.
        // Create the days using the HabitDayStorage.
        let habitDays = habitDayStorage.createDays(
            using: context,
            dates: daysDates,
            and: habit
        )
        challenge.addToDays(Set<HabitDayMO>(habitDays) as NSSet)

        return challenge
    }

    /// Deletes the provided entity from the given context.
    /// - Parameters:
    ///     - challenge: The challenge to be deleted.
    ///     - context: The context in which the deletion takes place.
    func delete(
        _ challenge: DaysChallengeMO,
        from context: NSManagedObjectContext
    ) {
        context.delete(challenge)
    }

    /// Closes all challenges that are now past and aren't marked as closed.
    /// - Parameter context: The context used to fetch and update the challenges.
    func closePastChallenges(using context: NSManagedObjectContext) {
        let openPastPredicate = NSPredicate(
            format: "toDate < %@ AND isClosed == false",
            Date().getBeginningOfDay() as NSDate
        )
        let request: NSFetchRequest<DaysChallengeMO> = DaysChallengeMO.fetchRequest()
        request.predicate = openPastPredicate

        if let challenges = try? context.fetch(request) {
            for challenge in challenges {
                challenge.isClosed = true
            }
        }
    }
}
