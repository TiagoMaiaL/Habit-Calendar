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
    let persistentContainer: NSPersistentContainer

    // MARK: Initializers

    init(completionBlock: @escaping (Error?) -> Void) {
        persistentContainer = NSPersistentContainer(name: "Habit-Calendar")
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data
                 * protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                #if DEVELOPMENT
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #endif

                // TODO: Treat these kind of errors.
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
