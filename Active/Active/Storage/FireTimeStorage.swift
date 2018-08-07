//
//  FireTimeStorage.swift
//  Active
//
//  Created by Tiago Maia Lopes on 21/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// Class in charge of storing FireTime entities.
class FireTimeStorage {

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

}
