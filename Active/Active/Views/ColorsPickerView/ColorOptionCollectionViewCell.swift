//
//  ColorOptionCollectionViewCell.swift
//  Active
//
//  Created by Tiago Maia Lopes on 12/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Cell in charge of displaying each color option item.
class ColorOptionCollectionViewCell: UICollectionViewCell {

    // MARK: Properties

    /// The color being displayed by the cell.
    var optionColor: UIColor? {
        didSet {
            backgroundColor = optionColor
        }
    }
}
