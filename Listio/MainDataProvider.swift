//
//  DataProvider.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData
import DATAStack

enum Errors : Error {
    case CoreDataError(String)
    case DoubleReceiptWithSameID
}

public class MainDataProvider: NSObject, MainDataProviderProtocol {
    struct Keys {
        static let CellIdentifier = "documentCell"
        static let ReceiptEntityName = "Receipt"
        static let ReceiptItemsArrayName = "items"
        static let ReceiptItemEntityName = "Item"
        static let ReceiptSortDescriptor = "createdAt"
        static let ItemDescriptionKey = "descricao"
        static let numberOfSections = 1
    }
    
    public var dataStack: DATAStack!
    weak public var tableView: UITableView!
    var items:[Item] = []
    
    public func performFetch() throws {
        items = try getUniqueItems()!
    }
    
    public func calcMediumCost() throws -> Double {
        let receipts = try getAllReceipt()
        let values: [Double] = receipts!.map { (receipt) -> Double in
            let payment = NSKeyedUnarchiver.unarchiveObject(with: receipt.payments! as Data) as! NSDictionary
            return Double(payment["vl_total"] as! String)!
        }
        return values.reduce(0, +)/Double(values.count)
    }
    
    public func getCountItems() -> Int {
        return items.count
    }
    
    func getUniqueItems() throws -> [Item]? {
        return try Item.getUniqueItems(dataStack.mainContext, withPresent: true)
    }
    
    func getAllReceipt() throws -> [Receipt]? {
        return try Receipt.getAllReceipt(dataStack.mainContext)
    }
    
    func getAllItems() throws -> [Item]? {
        return try Item.getAllItems(dataStack.mainContext)
    }
    
    func createPresentTagList(allItems: [Item]) {
        do {
            var auxItems = allItems.map { (item) -> (Item) in
                item.present = NSNumber(booleanLiteral: false)
                return item
            }
            
            auxItems = allItems.sorted(by: { (item1, item2) -> Bool in
                (item1.countReceipt?.intValue)! < (item2.countReceipt?.intValue)!
            })
            let mediumPrice = try calcMediumCost()
            var value = 0.0
            var auxItemArray:[Item] = [Item]()
            while value <= mediumPrice, let item = auxItems.popLast() {
                value += (item.vlTotal?.doubleValue)!
                item.present = NSNumber(booleanLiteral: true)
                auxItemArray.append(item)
            }
            items = auxItemArray
        } catch {
            
        }
    }
}


extension MainDataProvider {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Keys.numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.CellIdentifier, for: indexPath) as? DocumentUiTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        let item:Item? = items[indexPath.row]
        
        cell.nameLabel.text = item?.descricao
        cell.unLabel.text = item?.qtde?.intValue.description
        cell.valueLabel.text = item?.vlUnit?.toMaskReais()
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let obj = items.remove(at: indexPath.row)
            obj.present = NSNumber(booleanLiteral: false)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
}
