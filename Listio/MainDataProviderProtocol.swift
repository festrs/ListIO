//
//  DataProviderProtocol.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData

protocol MainDataProviderProtocol: UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView! { get set }
    var items: [Item] { get }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)

    func performFetch() throws
    func calcMediumCost() -> Double
    func getCountItems() -> Int

}
