//
//  DummyFactory.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 23/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Declares the main interface for the dummy factories
/// of each core data entity.
/// - Note: Dummies are only used for testing
///         the storage and model layers.
protocol DummyFactory {
    
    // MARK: Properties
    
    /// The container used to generate dummies.
    var container: NSPersistentContainer { get }
    
    // MARK: Imperatives
    
    /// Generates and returns the dummy object.
    func makeDummy() -> NSManagedObject
}
