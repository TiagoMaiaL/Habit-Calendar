//
//  Date+Utils.swift
//  Active
//
//  Created by Tiago Maia Lopes on 09/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// Adds Utilities used by the app to the Date type.
extension Date {
    
    // MARK: Imperatives
    
    /// Gets the configured current calendar.
    private func getCurrentCalendar() -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        return calendar
    }
    
    /// Gets a new date representing the beginning of the current date's day value.
    /// - Returns: the current date at midnight (beginning of day).
    func getBeginningOfDay() -> Date {
        return getCurrentCalendar().startOfDay(for: self)
    }
    
    /// Gets a new date representing the end of the current date's day value.
    /// - Returns: the current date at the end of the day (23:59 PM).
    func getEndOfDay() -> Date {
        // Declare the components to calculate the end of the current date's day.
        var components = DateComponents()
        components.day = 1
        // One day (24:00:00) minus one second (23:59:59). Resulting in the end
        // of the previous day.
        components.second = -1
        
        let dayAtEnd = getCurrentCalendar().date(byAdding: components, to: getBeginningOfDay())
        
        // Is there a mistake with the computation of the date?
        assert(dayAtEnd != nil, "Date+Utils -- getEndOfDay: the computation of the end of the day could'nt be performed.")
        
        return dayAtEnd!
    }
}
