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

        /// The colors to be displayed.
        var colors = [UIColor]()

        /// The color currently selected.
        var selectedColor: UIColor? {
            didSet {
                // Inform what's the selected color now.
                if let color = selectedColor {
                    colorSelectionHandler?(color)
                }
            }
        }

        /// The closure used to inform the selected color.
        var colorSelectionHandler: ((UIColor) -> Void)?

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
            let color = colors[indexPath.item]

            // Configure the cell's color option.
            cell.optionColor = color

            // If the color is selected, change its style.
            if selectedColor == color {
                cell.animateSelection()
            }

            return cell
        }

        func collectionView(
            _ collectionView: UICollectionView,
            didSelectItemAt indexPath: IndexPath
        ) {
            /// Tries to get the color cell at the specified indexPath.
            /// - Returns: The ColorOptionCollectionViewCell at the provided indexPath, if found.
            func getCellAtIndexPath(
                _ indexPath: IndexPath
            ) -> ColorOptionCollectionViewCell? {
                return collectionView.cellForItem(at: indexPath) as? ColorOptionCollectionViewCell
            }

            // Deselect the current color cell.
            if let selectedColor = selectedColor {
                // Try to get the index of the current selected cell.
                if let index = colors.index(of: selectedColor),
                    let selectedCell = getCellAtIndexPath(IndexPath(item: index, section: 0)) {
                    selectedCell.animateDeselection()
                } else {
                    assertionFailure("Error: couldn't get the currently selected cell.")
                }
            }

            // Select the new color.
            selectedColor = colors[indexPath.item]

            // Make it appear as the selected one.
            if let cellToSelect = getCellAtIndexPath(indexPath) {
                cellToSelect.animateSelection()
            } else {
                assertionFailure("Error: couldn't get the color selection cell.")
            }
        }
    }
}
