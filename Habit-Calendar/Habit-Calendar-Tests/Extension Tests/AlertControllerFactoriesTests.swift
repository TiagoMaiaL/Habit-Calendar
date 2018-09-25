//
//  AlertControllerFactoriesTests.swift
//  Habit-CalendarTests
//
//  Created by Tiago Maia Lopes on 25/09/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import XCTest
@testable import Habit_Calendar

/// Class in charge of testing each factory of the UIAlertController class.
class AlertControllerFactoriesTests: XCTestCase {

    // MARK: Tests

    func testSimpleFactory() {
        // 1. Declare the title, message, and button's title.
        let title = "Error"
        let message = "Testing message."
        let buttonTitle = "title"

        // 2. Assert it was properly configured.
        let alert = UIAlertController.make(title: title, message: message, mainButtonTitle: buttonTitle)

        XCTAssertEqual(alert.title, title)
        XCTAssertEqual(alert.message, message)
        XCTAssertEqual(alert.actions.first?.title, buttonTitle)
        XCTAssertEqual(alert.actions.first?.style, .default)
    }
}
