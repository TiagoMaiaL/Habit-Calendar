//
//  HabitsTableViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 06/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Controller in charge of displaying the list of tracked habits.
class HabitsTableViewController: UITableViewController {
  
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - DataSource Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
