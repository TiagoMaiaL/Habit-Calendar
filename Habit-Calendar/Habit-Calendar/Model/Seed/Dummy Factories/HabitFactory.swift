//
//  HabitFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Factory in charge of generating DayMO dummies.
struct HabitFactory: DummyFactory {

    // MARK: Types

    // This factory generates entities of the Habit class.
    typealias Entity = HabitMO

    // MARK: Properties

    var context: NSManagedObjectContext

    /// The maximum number of days contained within the generated dummy.
    private let maxNumberOfDays = 61

    /// A collection of dummy habit names.
    private let names = [
        "Play the guitar",
        "Play the piano",
        "Go jogging",
        "Play chess",
        "Read",
        "Go swimming",
        "Workout",
        "Write",
        "Study math",
        "Program",
        "Learn to dance"
    ]

    // MARK: Imperatives

    /// Generates and returns a Habit dummy entity.
    /// - Note: The dummy is related to other HabitDay
    ///         and Notification dummies.
    /// - Returns: The Habit entity as an NSManagedObject.
    func makeDummy() -> HabitMO {
        // Declare the habit entity.
        let habit = HabitMO(context: context)

        configure(habit: habit)
        configureFireTimes(for: habit)
        configureHabitDays(for: habit)
        configureNotifications(for: habit)

        assert(
            (habit.fireTimes?.count ?? 0) > 0,
            "The generated dummy must have fire times."
        )
        assert(
            (habit.challenges?.count ?? 0) > 0,
            "The generated dummy habit must have a challenge."
        )
        assert(
            (habit.notifications?.count ?? 0) > 0,
            "The generated dummy habit must have notifications."
        )

        return habit
    }

    /// Configures the habit's main attributes.
    private func configure(habit: HabitMO) {
        // Associate its properties (id, created, name, color).
        habit.id = UUID().uuidString
        habit.createdAt = Date()
        habit.name = names[Int.random(0..<names.count)]
        habit.color = HabitMO.Color(
            rawValue: Int16(Int.random(0..<HabitMO.Color.count))
        )!.rawValue
    }

    /// Configures the habit's dummy fire times.
    private func configureFireTimes(for habit: HabitMO) {
        // Associate its relationships:
        let fireTimeFactory = FireTimeFactory(context: context)
        var fireTimes = [
            fireTimeFactory.makeDummy()
        ]
        // Add a second fire time, making sure its different from the
        // first one (to avoid errors, since there's a requirement of only one notification per date).
        let secondFireTime = fireTimeFactory.makeDummy()
        if secondFireTime.hour == fireTimes.first!.hour {
            secondFireTime.minute = 1
        }
        fireTimes.append(secondFireTime)

        habit.addToFireTimes(Set(fireTimes) as NSSet)
    }

    /// Configures the habit's dummy days.
    private func configureHabitDays(for habit: HabitMO) {
        let challengeFactory = DaysChallengeFactory(context: context)
        let dummyChallenge = challengeFactory.makeDummy()
        dummyChallenge.habit = habit
    }

    private func configureNotifications(for habit: HabitMO) {
        let notificationFactory = NotificationFactory(context: context)

        guard let habitDays = habit.getCurrentChallenge()?.days as? Set<HabitDayMO> else {
            assertionFailure("Error: The challenge dummy doesn't have valid days.")
            return
        }
        guard let fireTimes = habit.fireTimes as? Set<FireTimeMO> else {
            assertionFailure("Error: Couldn't get the dummy's fire times.")
            return
        }

        // For each day, generate the notifications based on the fire times and the habit's day.
        for habitDay in habitDays {
            habitDay.habit = habit

            for fireTime in fireTimes {
                // Create the fireDate by appending the date to the fireTime's components.
                if var fireDate = Calendar.current.date(
                    byAdding: fireTime.getFireTimeComponents(),
                    to: habitDay.day!.date!
                    ) {
                    if fireDate.isPast {
                        fireDate = Date().byAddingMinutes(60)!
                    }

                    let notification = notificationFactory.makeDummy()
                    notification.fireDate = fireDate
                    notification.habit = habit
                    if let order = habit.getCurrentChallenge()!.getOrder(of: habitDay) {
                        notification.dayOrder = Int64(order)
                    }
                }
            }
        }
    }
}
