//
//  AddListItemDataProviderProtocol.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-23.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData

public protocol AddListItemDataProviderProtocol: UITableViewDataSource, UITableViewDelegate {
    weak var tableView: UITableView! { get set }
    func performFetch() throws
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    func countItems() -> Int
    func unselectAll()
    func selectAll()
}
