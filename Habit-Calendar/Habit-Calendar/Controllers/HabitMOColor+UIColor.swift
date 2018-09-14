//
//  HabitMOColor+UIColor.swift
//  Active
//
//  Created by Tiago Maia Lopes on 13/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Extension that adds UIColor capabilities to the Color model enum.
extension HabitMO.Color {

    // MARK: Properties

    /// The UIColors associated with each enum constant.
    static let uiColors = [
        systemRed: UIColor("#FF3B30"),
        systemOrange: UIColor("#FF9500"),
        systemYellow: UIColor("#FFCC00"),
        systemGreen: UIColor("#4CD964"),
        systemTeal: UIColor("#5AC8FA"),
        systemBlue: UIColor("#007AFF"),
        systemPurple: UIColor("#5856D6"),
        systemPink: UIColor("#FF2D55")
    ]

    /// The UIColor associated with the enum.
    var uiColor: UIColor {
        guard let color = HabitMO.Color.uiColors[self] else {
            assertionFailure("Error: the current instance doesn't have a valid color associated with it.")
            return .black
        }
        return color
    }

    // MARK: Imperatives

    /// Searches for the enum instance associated with the passed UIColor.
    /// - Parameter color: the color associated with an instance.
    /// - Returns: An enum instance associated with the UIColor, if found.
    static func getInstanceFrom(color: UIColor) -> HabitMO.Color? {
        return HabitMO.Color.uiColors.enumerated().filter {
            $1.value == color
        }.first?.element.key
    }
}
