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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func numberOfSections(in tableView: UITableView) -> Int
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
}
