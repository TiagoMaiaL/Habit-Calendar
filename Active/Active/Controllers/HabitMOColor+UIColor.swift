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
        midnightBlue: UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1),
        amethyst: UIColor(red: 155/255, green: 89/255, blue: 182/255, alpha: 1),
        pomegranate: UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1),
        alizarin: UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1),
        carrot: UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1),
        orange: UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1),
        blue: UIColor(red: 0/255, green: 168/255, blue: 255/255, alpha: 1.0),
        peterRiver: UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1),
        belizeRole: UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1),
        turquoise: UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1),
        emerald: UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
    ]

    // MARK: Imperatives

    /// Gets the UIColor representing the current enum instance.
    /// - Returns: The UIColor associated with the instance.
    func getColor() -> UIColor {
        guard let color = HabitMO.Color.uiColors[self] else {
            assertionFailure("Error: the current instance doesn't have a valid color associated with it.")
            return .black
        }
        return color
    }

    /// Searches for the enum instance associated with the passed UIColor.
    /// - Parameter color: the color associated with an instance.
    /// - Returns: An enum instance associated with the UIColor, if found.
    static func getInstanceFrom(color: UIColor) -> HabitMO.Color? {
        var instance: HabitMO.Color? = nil

        // Search for the instance associated with the color.
        for (currentInstance, uiColor) in HabitMO.Color.uiColors {
            // If the color is equals to the passed one, the instance was found and can be returned.
            if uiColor == color {
                instance = currentInstance
                break
            }
        }

        return instance
    }
}
