//
//  Int+Utils.swift
//  Active
//
//  Created by Tiago Maia Lopes on 28/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// Adds utilities to the Int struct.
extension Int {

    /// Returns a random number out of the provided range.
    /// - Parameter range: A half-open range from min to max (but not including) value.
    /// - Returns: A random Int value.
    static func random(_ range: CountableRange<Int>) -> Int {
        assert(!range.isEmpty, "The passed range can't be empty.")
        assert(range.count >= 2, "The passed range can't be empty.")

        // 1. Force unwrap the minimum and maximum values.
        let min = range.first!
        let max = range.last!

        // 2. Get a random number from those values.
        return min + Int(arc4random_uniform(UInt32(max - min)))
    }
}
