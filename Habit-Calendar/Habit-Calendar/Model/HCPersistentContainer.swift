//
//  HCPersistentContainer.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 24/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData

class HCPersistentContainer: NSPersistentContainer {

    override class func defaultDirectoryURL() -> URL {
        guard let appGroupContainerUrl = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.tiago.maia.Habit-Calendar"
            ) else {
                assertionFailure("Couldn't get the url of the shared container.")
                return super.defaultDirectoryURL().appendingPathComponent("HabitCalendar")
        }
        return appGroupContainerUrl.appendingPathComponent("HabitCalendar")
    }

}
