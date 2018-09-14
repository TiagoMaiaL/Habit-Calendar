//
//  FireTimeTests.swift
//  ActiveTests
//
//  Created by Tiago Maia Lopes on 21/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import CoreData
import XCTest
@testable import Habit_Calendar

/// Class in charge of testing the FireTimeMO core data entity methods.
class FireTimeTests: IntegrationTestCase {

    // MARK: Tests

    func testFireTimeDateGetter() {
        // 1. Declare the fireTimeMO to be used.
        let dummyFireTime = FireTimeMO(context: context)
        dummyFireTime.id = UUID().uuidString
        dummyFireTime.createdAt = Date()
        dummyFireTime.hour = Int16(Int.random(0..<60))
        dummyFireTime.minute = Int16(Int.random(0..<60))

        // 2. Get its fire time as a date instance.
        let fireTimeComponents = dummyFireTime.getFireTimeComponents()

        // 3. Assert on its hour and minute components.
        // Its year, month and day components should be nil.
        XCTAssertEqual(
            Int(dummyFireTime.hour),
            fireTimeComponents.hour,
            "The generated date should have the expected hour."
        )
        XCTAssertEqual(
            Int(dummyFireTime.minute),
            fireTimeComponents.minute,
            "The generated date should have the expected minute."
        )
        XCTAssertNil(fireTimeComponents.year, "The year should be nil.")
        XCTAssertNil(fireTimeComponents.month, "The month should be nil.")
        XCTAssertNil(fireTimeComponents.day, "The day should be nil.")
    }

    /// Class used to test the protocol methods.
    private class FireTimesDisplayer: FireTimesDisplayable {
        var fireTimesAmountLabel: UILabel!
        var fireTimesLabel: UILabel!
    }

    func testGettingFireTimesDisplayText() {
        let factory = FireTimeFactory(context: context)

        // 1. Declare the dummy fire times.
        let dummyFireTimes: [FireTimeMO] = (0..<3).map { index in
            let fireTime = factory.makeDummy()
            fireTime.hour = Int16(index)
            return fireTime
        }

        // 2. Get the text from the displayer.
        let displayer = FireTimesDisplayer()
        let description = displayer.getText(from: dummyFireTimes.map { $0.getFireTimeComponents() })

        print(description)

        // 3. Split the text to get each fire time's text.
        let fireTimesText = description.split(separator: ",").compactMap {
            $0.trimmingCharacters(in: .whitespaces)
        }
        // 3.1 Assert on the count.
        XCTAssertEqual(dummyFireTimes.count, fireTimesText.count)
        // 3.2 Assert on each string, if it has a corresponding fire time.
        for fireTimeText in fireTimesText {
            let components = fireTimeText.split(separator: ":").map {
                Int($0) ?? 0
            }
            XCTAssertEqual(components.count, 2)

            let matchingFireTime = dummyFireTimes.filter {
                Int($0.hour) == components.first! && Int($0.minute) == components.last!
            }
            XCTAssertTrue(!matchingFireTime.isEmpty)
        }
    }
}
