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
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0


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

    var colorsToDisplay = [UIColor]() {
        didSet {
            // Pass the colors to the data source.
            colorPickerDataSource.colors = colorsToDisplay
            // Display each one of them.
            collectionView.reloadData()
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
            addSubview(collectionView)
        }
        collectionView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }

    // MARK: Imperatives

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
