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
            colorView.backgroundColor = optionColor
        }
    }

    /// The rouded view to display the color option.
    private(set) lazy var colorView = UIView()

    /// MARK: Life Cycle

    override func layoutSubviews() {
        super.layoutSubviews()

        if colorView.superview == nil {
            colorView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(colorView)
        }

        // Center the colorView in the contentView and change it's size to be 0.85 of the content's one.
        colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85).isActive = true
        colorView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.85).isActive = true

        // Apply cornerRadius so as to make the view become a circle.
        colorView.layer.cornerRadius = (frame.size.width * 0.85) / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
