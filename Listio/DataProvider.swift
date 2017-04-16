//
//  DataProvider.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit

public class DataProvider: NSObject, DataProviderProtocol {
    struct Keys {
        static let CellIdentifier = "documentCell"
    }
    
    public var coreDataHandler: CoreDataHandler!
    weak public var tableView: UITableView!
    var items:[Item]?
    
    public func fetch() {
        items = coreDataHandler.getAllItems()
    }
    
    public func addReceipt(_ json: [String : AnyObject]) {
        guard coreDataHandler.savingData(json) == true else {
            print("error saving")
            return
        }
    }
    
    required public init(coreDataHandler: CoreDataHandler) {
        super.init()
        self.coreDataHandler = coreDataHandler
        fetch()
    }
    
    public func calcMediumCost() -> Double {
        return coreDataHandler.calcMediumCost()
    }
    
    public func getCountItems() -> Int {
        return (items?.count)!
    }
    
}


extension DataProvider : UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Keys.CellIdentifier, for: indexPath) as! DocumentUiTableViewCell
        let item = items?[indexPath.row]
        
        cell.nameLabel.text = item?.descricao
        cell.unLabel.text = item?.un
        cell.valueLabel.text = item?.vlUnit?.toMaskReais()
        
        return cell
    }
}
