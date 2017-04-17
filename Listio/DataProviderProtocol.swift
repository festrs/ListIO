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

public protocol DataProviderProtocol: UITableViewDataSource {
    var dataStack: DATAStack! { get }
    weak var tableView: UITableView! { get set }

    func fetch() throws
    func addReceipt(_ json:[String: AnyObject]) throws
    func calcMediumCost() throws -> Double
    func getCountItems() throws -> Int
    
    init(DATAStack: DATAStack)
    
}
