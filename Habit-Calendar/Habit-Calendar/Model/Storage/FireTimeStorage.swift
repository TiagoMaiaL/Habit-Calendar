//
//  FireTimeStorage.swift
//  Active
//
//  Created by Tiago Maia Lopes on 21/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// Class in charge of storing FireTime entities.
struct FireTimeStorage {

    // MARK: Imperatives

    /// Creates a FireTimeMO entity by using the passed components.
    /// - Parameters:
    ///     - context: The NSManagedObjectContext used to create the entity.
    ///     - components: The entity's components.
    ///     - habit: The habit entity associated with the FireTime.
    /// - Returns: The created FireTime entity.
    func create(
        using context: NSManagedObjectContext,
        components: DateComponents,
        andHabit habit: HabitMO
    ) -> FireTimeMO {
        assert(
            components.hour != nil,
            "The components' hour must be set."
        )
        assert(
            components.minute != nil,
            "The components' minute must be set."
        )

        // Create the fire time entity.
        let fireTime = FireTimeMO(context: context)
        fireTime.id = UUID().uuidString
        fireTime.createdAt = Date()
        fireTime.hour = Int16(components.hour!)
        fireTime.minute = Int16(components.minute!)
        fireTime.habit = habit

        return fireTime
    }

    /// Fetches the fire times of the app sorted by the time.
    /// - Parameter context: The context used to fetch all fire times.
    /// - Returns: all fire times of the app.
    func getAllSortedFireTimes(using context: NSManagedObjectContext) -> [FireTimeMO] {
        let request: NSFetchRequest<FireTimeMO> = FireTimeMO.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "hour", ascending: true),
            NSSortDescriptor(key: "minute", ascending: true)
        ]
        return (try? context.fetch(request)) ?? []
    }

    /// Deletes the fire times from the passed habit and context.
    /// - Parameters:
    ///     - habit: The habit containing the fire times.
    ///     - context: The context from which the fire times are deleted.
    func delete(from habit: HabitMO, andContext context: NSManagedObjectContext) {
        guard let fireTimes = habit.fireTimes as? Set<FireTimeMO> else { return }

        habit.removeFromFireTimes(fireTimes as NSSet)
        for fireTime in fireTimes {
            context.delete(fireTime)
        }
    }
}
