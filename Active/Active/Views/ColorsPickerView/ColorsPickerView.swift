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
        // TODO: Put the right colors to be displayed.
        colorPickerDataSource.colorOptions = [UIColor.black]
        collectionView.delegate = colorPickerDataSource
        collectionView.dataSource = colorPickerDataSource
    }

    // MARK: Life Cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        collectionView.reloadData()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !subviews.contains(collectionView) {
            addSubview(collectionView)
        }
        collectionView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }

}
