//
//  EmptyStateView.swift
//  Active
//
//  Created by Tiago Maia Lopes on 30/08/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {

    // MARK: Properties

    /// The main label displaying the empty state message.
    @IBOutlet weak var emptyLabel: UILabel!

    /// The call to action button associated with the empty state.
    @IBOutlet weak var callToActionButton: RoundedButton!
}
