//
//  ColorsPickerView.swift
//  Active
//
//  Created by Tiago Maia Lopes on 12/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A view displaying a number of color options so the user can choose one.
@IBDesignable class ColorsPickerView: UIView {

    // MARK: Parameters

    /// The number of colors to be displayed in the IB.
    /// - Note: This code shouldn't be invoked, it's meant only for the
    ///         interaction with storyboards.
    @IBInspectable var colorNumber: Int = 0

    /// The collection view's flow layout object.
    private(set) lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        return layout
    }()

    /// The collection view displaying the color options provided to the class.
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: frame.size.width,
                height: frame.size.height
            ),
            collectionViewLayout: flowLayout
        )
        collectionView.backgroundColor = .blue

        return collectionView
    }()

    /// The collection view's delegate and data source in charge of displayin the
    /// color options.
    let colorPickerDataSource = ColorPickerViewDataSource()

    /// The colors to be displayed by the picker view.
    var colorsToDisplay = [UIColor]() {
        didSet {
            // Pass the colors to the data source.
            colorPickerDataSource.colors = colorsToDisplay
            // Display each one of them.
            collectionView.reloadData()
        }
    }

    /// How many colors per row should be displayed.
    @IBInspectable var colorsPerRow: Int = 5 {
        didSet {
            flowLayout.itemSize = getItemsExpectedSize()
        }
    }

    /// The space between each color (both horizontally and vertically).
    @IBInspectable var spaceBetweenItems: CGFloat = 10 {
        didSet {
            flowLayout.minimumInteritemSpacing = spaceBetweenItems
            flowLayout.minimumLineSpacing = spaceBetweenItems
            flowLayout.itemSize = getItemsExpectedSize()
        }
    }

    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    // MARK: Setup

    private func setup() {
        // Configure the cells to be displayed.
        collectionView.register(
            ColorOptionCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorPickerViewDataSource.cellId
        )
        // Configure the data source and delegate of the collection view.
        collectionView.delegate = colorPickerDataSource
        collectionView.dataSource = colorPickerDataSource
    }

    // MARK: Life Cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        // If the number of colors was set, generated the random colors.
        if colorNumber > 0 {
            colorPickerDataSource.colors = makeRandomColors(number: colorNumber)
            collectionView.reloadData()
        }

        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !subviews.contains(collectionView) {
            // Calculate the size of each item and apply it to the layout.
            flowLayout.itemSize = getItemsExpectedSize()
            addSubview(collectionView)
        }
        collectionView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)

        _ = getExpectedHeight()
    }

    // MARK: Imperatives

    /// Calculates the expected height of the color picker.
    /// - Note: The expected height is enough to display all picker's colors.
    /// - Returns: The calculated height.
    func getExpectedHeight() -> CGFloat {
        // Get how many rows are going to be needed.
        let rowsCount = ceil(CGFloat(colorsToDisplay.count) / CGFloat(colorsPerRow))
        // Get the vertical space to be accounted.
        let verticalSpace = (rowsCount - 1) * flowLayout.minimumLineSpacing

        return (rowsCount * getItemsExpectedSize().height) + verticalSpace
    }

    /// Computes the expected size of each item, taking into account the expected
    /// number of items per row.
    /// - Returns: The calculated size.
    func getItemsExpectedSize() -> CGSize {
        // Compute the size based on the picker's width minus the horizontal space
        // between the items to be displayed.
        let spaceToBeAccounted: CGFloat = CGFloat(colorsPerRow - 1) * flowLayout.minimumInteritemSpacing
        let sideLength = (collectionView.frame.size.width - spaceToBeAccounted) / CGFloat(colorsPerRow)

        return CGSize(width: sideLength, height: sideLength)
    }

    /// Generates an array of random colors.
    /// - Parameter number: The number of random colors to be generated.
    /// - Returns: The generated colors.
    private func makeRandomColors(number: Int) -> [UIColor] {
        assert(number > 0, "The number of colors to be generated should be greated than one.")

        return (0...number).map { _ in
            /// Generates a random amount of color.
            func makeRandomColorAmount() -> CGFloat {
                return CGFloat(Int.random(0..<256)) / 255
            }
            return UIColor(
                red: makeRandomColorAmount(),
                green: makeRandomColorAmount(),
                blue: makeRandomColorAmount(),
                alpha: 1
            )
        }
    }
}
