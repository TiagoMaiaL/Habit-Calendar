//
//  Formatter+Utils.swift
//  Active
//
//  Created by Tiago Maia Lopes on 17/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension DateFormatter {

    /// The short styled formatter configure with the current settings (calendar, time zone, and locale).
    static var shortCurrent: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        return formatter
    }

    /// Creates a new DateFormatter used to display notification fire times.
    /// - Returns: The FireTime date formatter.
    static var fireTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
        return formatter
    }
}

extension NumberFormatter {

    /// The local ordinal formatter.
    static var localOrdinal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        formatter.locale = .current
        return formatter
    }
}
