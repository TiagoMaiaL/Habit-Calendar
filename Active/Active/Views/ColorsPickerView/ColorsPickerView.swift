//
//  ColorsPickerView.swift
//  Active
//
//  Created by Tiago Maia Lopes on 12/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

@IBDesignable class ColorsPickerView: UICollectionView {

    // MARK: Life Cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        backgroundColor = .red
    }

}
