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

    init(completionBlock: @escaping (Error?, NSPersistentContainer) -> Void) {
        persistentContainer = HCPersistentContainer(name: "Habit-Calendar")

        let description = persistentContainer.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true

        if !persistentContainer.persistentStoreDescriptions.contains(description) {
            persistentContainer.persistentStoreDescriptions.append(description)
        }

        do {
            try shareStoreIfNecessary()
        } catch {
            completionBlock(error, persistentContainer)
        }

        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                #if DEVELOPMENT
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #endif
            }
            completionBlock(error, self.persistentContainer)
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

    /// Shares the storage file with the app group (only in cases of an app update, before adding extensions).
    private func shareStoreIfNecessary() throws {
        let fileManager = FileManager.default

        // Get the default store url (when it's not shared with the app group).
        let previousStoreUrl = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent("HabitCalendar")

        // Get the store url when it's shared with the app group.
        let appGroupStoreUrl = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: "group.tiago.maia.Habit-Calendar"
        )?.appendingPathComponent("HabitCalendar")

        // Share the file, if not yet shared and only in cases of an app update before the adition of app extensions.
        if let previousStoreUrl = previousStoreUrl, let appGroupStoreUrl = appGroupStoreUrl {
            if fileManager.fileExists(atPath: previousStoreUrl.path),
                !fileManager.fileExists(atPath: appGroupStoreUrl.path) {
                do {
                    print("Moving store from private bundle to shared app group container.")
                    try fileManager.moveItem(
                        at: previousStoreUrl,
                        to: appGroupStoreUrl
                    )
                } catch {
                    assertionFailure("Couldn't share the store with the extensions.")
                    throw error
                }
            }
        }
    }
}
