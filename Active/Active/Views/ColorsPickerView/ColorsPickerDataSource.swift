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

    class ColorPickerViewDataSource: NSObject, UICollectionViewDelegate,
        UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

        // MARK: Properties

        /// The color cell's reuse identifier.
        static let cellId = "color_option_cell"

        /// The colors to be displayed.
        var colorOptions = [UIColor]()

        // MARK: CollectionView DataSource methods

        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {
            return colorOptions.count
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
            cell.optionColor = colorOptions[indexPath.item]

            return cell
        }

        // MARK: CollectionView Layout Delegate methods

        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
            return CGSize(width: 30, height: 30)
        }
    }
}
