//
//  DataProviderProtocol.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData
import DATAStack

public protocol MainDataProviderProtocol: UITableViewDataSource {
    var dataStack: DATAStack! { get set }
    weak var tableView: UITableView! { get set }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func numberOfSections(in tableView: UITableView) -> Int
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    
    func performFetch() throws
    func calcMediumCost() throws -> Double
    func getCountItems() -> Int

}
