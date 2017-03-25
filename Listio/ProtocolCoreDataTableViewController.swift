//
//  ProtocolCoreDataTableViewController.swift
//  Boleto
//
//  Created by Felipe Dias Pereira on 2016-03-14.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData

public protocol CoreDataTableViewControllerProtocol: UITableViewDataSource {
    
    func performFetch()
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>? {get set}
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: IndexPath) -> UITableViewCell
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
}
