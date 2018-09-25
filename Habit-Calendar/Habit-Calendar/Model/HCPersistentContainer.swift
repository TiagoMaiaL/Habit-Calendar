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
        return super.defaultDirectoryURL().appendingPathComponent("HabitCalendar")
    }

}
