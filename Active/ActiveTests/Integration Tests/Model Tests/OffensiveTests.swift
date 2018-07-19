//
//  OffensiveTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 19/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import XCTest
@testable import Active

/// Class in charge of testing the OffensiveMO core data entity methods.
class OffensiveTests: IntegrationTestCase {

    // MARK: Tests
    
    func testGettingOffensiveLength() {
        // 1. Declare an empty offensive.
        let offensiveDummy = OffensiveMO(context: context)
        
        // 2. Set its from and to dates.
        let differenceInDays = Int.random(1..<50)
        offensiveDummy.fromDate = Date()
        offensiveDummy.toDate = Date().byAddingDays(differenceInDays)
        
        // 3. Assert that the length is the expected one.
        XCTAssertEqual(
            offensiveDummy.getLength(),
            differenceInDays,
            "The offensive's length isn't the expected one."
        )
    }
    
    func testGettingOffensiveLengthWhenFromDateAndToDateAreEquals() {
        // 1. Declare an empty offensive.
        let offensiveDummy = OffensiveMO(context: context)
        
        // 2. Set its from and to dates to the current one.
        offensiveDummy.fromDate = Date()
        offensiveDummy.toDate = Date()
        
        // 3. Assert that the length is one.
        XCTAssertEqual(
            offensiveDummy.getLength(),
            1,
            "The offensive's length isn't one."
        )
    }

}
