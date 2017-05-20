//
//  AddListItemDataProvider.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-23.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData
import DATAStack

class AddListItemDataProvider: NSObject, AddListItemDataProviderProtocol {
    struct Keys {
        static let CellIdentifier = "ItemListCell"
    }
    public var dataStack: DATAStack!
    weak public var tableView: UITableView!
    var items:[Item] = [Item]()
    
    func performFetch() throws {
        items = try getUniqueItems()!
    }
    
    func getUniqueItems() throws -> [Item]? {
        return try Item.getUniqueItems(dataStack.mainContext)
    }
    
    func countItems() -> Int {
        return items.count
    }
    
    func unselectAll() {
        for (_, value) in items.enumerated() {
            value.present = NSNumber(booleanLiteral: false)
        }
        tableView.reloadData()
    }
    
    func selectAll() {
        for (_, value) in items.enumerated() {
            value.present = NSNumber(booleanLiteral: true)
        }
        tableView.reloadData()
    }
}

extension AddListItemDataProvider {
    //MARk - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemObj = items[indexPath.row]
        
        guard let cell = tableView.cellForRow(at: indexPath) as? AddListItemTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        if let present = itemObj.present?.boolValue, present {
            cell.accessoryType = .none
            itemObj.present = NSNumber(booleanLiteral: false)
        } else {
            cell.accessoryType = .checkmark
            itemObj.present = NSNumber(booleanLiteral: true)
        }
        tableView.reloadData()
    }
}

extension AddListItemDataProvider {
    //MARK - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.CellIdentifier, for: indexPath) as? AddListItemTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        let itemObj = items[indexPath.row]
        
        cell.nameLabel.text = itemObj.descricao
        cell.priceLabel.text = itemObj.vlUnit?.toMaskReais()
        cell.unLabel.text = "UN \(itemObj.qtde?.intValue ?? 0)"
        
        if let present = itemObj.present?.boolValue, present {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
