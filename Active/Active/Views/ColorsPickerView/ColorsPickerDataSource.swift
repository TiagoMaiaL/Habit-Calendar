//
//  ColorsPickerDataSource.swift
//  Active
//
//  Created by Tiago Maia Lopes on 12/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Adds the code necessary for the ColorPickerView to display each color option.
extension ColorsPickerView {

    /// The picker's delegate and datasource in charge of handling the color picker.
    class ColorPickerViewDataSource: NSObject, UICollectionViewDelegate,
        UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

        // MARK: Properties

        /// The color cell's reuse identifier.
        static let cellId = "color_option_cell"

        /// How many items are to be displayed by a single row.
        var itemsPerRow = 5

        /// The expected height to display all picker's colors.
        private(set) var expectedHeight = 0

        /// The colors to be displayed.
        var colors = [UIColor]()

        // MARK: CollectionView DataSource methods

        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {
            return colors.count
        }

        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ColorPickerViewDataSource.cellId,
                    for: indexPath
                ) as? ColorOptionCollectionViewCell else {
                    assertionFailure("ColorOptionCell couldn't be dequeued.")
                    return UICollectionViewCell()
            }

            // Configure the cell's color option.
            cell.optionColor = colors[indexPath.item]

            return cell
        }
    }
}
