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
            "The provided days dates must have two or more dates."
        )
        
        let sequence = DaysSequenceMO(context: context)
        
        // Configure its main properties:
        sequence.id = UUID().uuidString
        sequence.createdAt = Date()
        sequence.fromDate = Date().getBeginningOfDay()
        sequence.toDate = daysDates.sorted().last!
        
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
