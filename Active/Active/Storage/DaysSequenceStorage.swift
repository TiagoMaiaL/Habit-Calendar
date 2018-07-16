//
//  DaysSequenceStorage.swift
//  Active
//
//  Created by Tiago Maia Lopes on 16/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// Class in charge of managing the DaysSequenceMO entities.
class DaysSequenceStorage {
    
    // MARK: Imperatives
    
    /// Creates a sequence entity by using the provided days' dates and the
    /// associated habit.
    /// - Parameters:
    ///     context: The context to which the entity is added.
    ///     daysDates: The days' dates used to create the sequence days.
    ///     habit: The habit entity to which the sequence is added.
    /// - Returns: A new sequence associated with the habit.
    func create(
        using context: NSManagedObjectContext,
        daysDates: [Date],
        and habit: HabitMO
    ) -> DaysSequenceMO {
        let sequence = DaysSequenceMO(context: context)
        // TODO: Configure the sequence.
        return sequence
    }
    
    /// Edits the provided entity by adding and replacing the new provided
    /// days' dates.
    /// - Parameters:
    ///     sequence: The sequence to be editted.
    ///     context: The context to which the entity is updated.
    ///     daysDates: The days' dates to be appended to the sequence.
    /// - Returns: The editted sequence entity.
    func edit(
        _ sequence: DaysSequenceMO,
        in context: NSManagedObjectContext,
        with daysDates: [Date]
    ) -> DaysSequenceMO {
        // TODO: Configure the sequence.
        return sequence
    }
    
    /// Deletes the provided entity from the given context.
    /// - Parameter sequence: The sequence to be deleted.
    func delete(_ sequence: DaysSequenceMO) {
        // TODO: Delete the sequence.
    }
}
