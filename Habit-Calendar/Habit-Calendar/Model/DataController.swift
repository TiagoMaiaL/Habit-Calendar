//
//  DataController.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 19/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

/// Handles the initialization of the core data stack and contains its main objects.
class DataController {

    // MARK: Properties

    /// Holds the core data stack.
    let persistentContainer: HCPersistentContainer

    // MARK: Initializers

    init(completionBlock: @escaping (Error?) -> Void) {
        persistentContainer = HCPersistentContainer(name: "Habit-Calendar")
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                #if DEVELOPMENT
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #endif
            }
            completionBlock(error)
        })
    }

    // MARK: Imperatives

    /// Saves the container's view context, if needed.
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                #if DEVELOPMENT
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                #else
                context.rollback()
                #endif
            }
        }
    }
}
