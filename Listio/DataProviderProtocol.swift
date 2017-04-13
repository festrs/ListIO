//
//  DataProviderProtocol.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData

public protocol DataProviderProtocol: UITableViewDataSource {
    
    var coreDataHandler: CoreDataHandler! { get }
    
    weak var tableView: UITableView! { get set }

    func fetch()
    
    func addReceipt(_ json:[String: AnyObject])
    
    func calcMediumCost() -> Double
    
    func getCountItems() -> Int
    
    init(coreDataHandler: CoreDataHandler)
    
}
