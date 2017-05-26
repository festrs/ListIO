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
    // swiftlint:disable identifier_name
    case CoreDataError(String)
    case DoubleReceiptWithSameID
}

public class MainDataProvider: NSObject, MainDataProviderProtocol {
    struct Keys {
        static let CellIdentifier = "mainCell"
        static let ReceiptEntityName = "Receipt"
        static let ReceiptItemsArrayName = "items"
        static let ReceiptItemEntityName = "Item"
        static let ReceiptSortDescriptor = "createdAt"
        static let ItemDescriptionKey = "descricao"
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
            // swiftlint:disable force_cast
            let payment = NSKeyedUnarchiver.unarchiveObject(with: receipt.payments! as Data) as! NSDictionary
            return Double(payment["vl_total"] as! String)!
        }
        if values.count > 0 {
            return values.reduce(0, +)/Double(values.count)
        }
        return 0.0
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
    
//    func createPresentTagList(allItems: [Item]) {
//        do {
//            var auxItems = allItems.map { (item) -> (Item) in
//                item.present = NSNumber(booleanLiteral: false)
//                return item
//            }
//            
//            auxItems = allItems.sorted(by: { (item1, item2) -> Bool in
//                (item1.countReceipt?.intValue)! < (item2.countReceipt?.intValue)!
//            })
//            let mediumPrice = try calcMediumCost()
//            var value = 0.0
//            var auxItemArray:[Item] = [Item]()
//            while value <= mediumPrice, let item = auxItems.popLast() {
//                value += (item.vlTotal?.doubleValue)!
//                item.present = NSNumber(booleanLiteral: true)
//                auxItemArray.append(item)
//            }
//            items = auxItemArray
//        } catch {
//            
//        }
//    }
}


extension MainDataProvider {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.CellIdentifier, for: indexPath) as? MainTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        let item:Item? = items[indexPath.row]
        
        cell.nameLabel.text = item?.descricao
        cell.unLabel.text = "UN \(item?.qtde?.intValue ?? 0)"
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

extension MainDataProvider {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MainTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        cell.bigFlatSwitch.setSelected(!cell.bigFlatSwitch.isSelected, animated: true)
    }
}
