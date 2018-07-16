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
    
    // MARK: Properties
    
    /// The habitDayStorage used to create the days.
    private let habitDayStorage: HabitDayStorage
    
    // MARK: Initializers
    
    init(habitDayStorage: HabitDayStorage) {
        self.habitDayStorage = habitDayStorage
    }
    
    // MARK: Imperatives
    
    /// Creates a sequence entity by using the provided days' dates and the
    /// associated habit.
    /// - Parameters:
    ///     - context: The context to which the entity is added.
    ///     - daysDates: The days' dates used to create the sequence days.
    ///     - habit: The habit entity to which the sequence is added.
    /// - Returns: A new sequence associated with the habit.
    func create(
        using context: NSManagedObjectContext,
        daysDates: [Date],
        and habit: HabitMO
    ) -> DaysSequenceMO {
        assert(
            daysDates.count > 1,
            "The provided days dates need to have two or more dates."
        )
        
        // TODO: Order the passed days dates.
        
        let sequence = DaysSequenceMO(context: context)
        
        // Configure its main properties:
        sequence.id = UUID().uuidString
        sequence.createdAt = Date()
        sequence.fromDate = daysDates.first!
        sequence.toDate = daysDates.last!
        
        // Associate its habit entity.
        sequence.habit = habit
        
        // Configure its days.
        // Create the days using the HabitDayStorage.
        let habitDays = habitDayStorage.createDays(
            using: context,
            dates: daysDates,
            and: habit
        )
        sequence.addToDays(Set<HabitDayMO>(habitDays) as NSSet)
        
        return sequence
    }
    
    /// Edits the provided entity by adding and replacing the new provided
    /// days' dates.
    /// - Note: Editting a sequence is only allowed when the sequence's days are
    ///         still being currently tracked (the days are in the present).
    ///         If the days have already passed (are in the past),
    ///         the edition isn't allowed.
    /// - Parameters:
    ///     - sequence: The sequence to be editted.
    ///     - context: The context to which the entity is updated.
    ///     - daysDates: The days' dates to be appended to the sequence.
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
    /// - Parameters:
    ///     - sequence: The sequence to be deleted.
    ///     - context: The context in which the deletion takes place.
    func delete(
        _ sequence: DaysSequenceMO,
        from context: NSManagedObjectContext
    ) {
        context.delete(sequence)
    }
}
