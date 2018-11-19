//
//  ProgressDisplayable.swift
//  Habit-Calendar
//
//  Created by Tiago Maia Lopes on 19/11/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

protocol ProgressDisplayable {

    // MARK: Properties

    /// The main color of the progress view.
    var tint: UIColor? { get set }

    /// The progress (from 0 to 1) to be displayed by the view.
    var progress: CGFloat { get set }

    // MARK: Imperatives

    /// Draws the view, showing its progress.
    func drawProgress()
}
