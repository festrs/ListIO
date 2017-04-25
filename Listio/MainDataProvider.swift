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
    
    public func fetch() throws {
        let allItems = try getUniqueItems()!
        setItemSection(allItems: allItems)
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
        return try Item.getUniqueItems(dataStack.mainContext)
    }
    
    func getAllReceipt() throws -> [Receipt]? {
        return try Receipt.getAllReceipt(dataStack.mainContext)
    }
    
    func getAllItems() throws -> [Item]? {
        return try Item.getAllItems(dataStack.mainContext)
    }
    
    public func addReceipt(_ json:[String: AnyObject]) throws {
        guard try verifyNewObject(json["id"] as! String) == false else {
            throw Errors.DoubleReceiptWithSameID
        }
        let docObj = NSEntityDescription.insertNewObject(forEntityName: Keys.ReceiptEntityName, into: self.dataStack.mainContext) as! Receipt
        docObj.hyp_fill(with: json)
        let itemsArray = removeRedudancy(receipt: docObj, json[Keys.ReceiptItemsArrayName] as! [AnyObject])
        
        let allItems = try getAllItems()!
        
        _ = allItems.reduce([Item]()){
            uniqueElements, element in
            
            if let index = uniqueElements.index(where: {$0 == element}) {
                let auxItem = uniqueElements[index]
                auxItem.addCountReceipt(1)
                return uniqueElements
            } else {
                return uniqueElements + [element]
            }
        }
        
        docObj.addToItems(NSSet(array: itemsArray))
        
        try saveContex()
        createPresentTagList(allItems: try getUniqueItems()!)
    }
    
    func setItemSection(allItems: [Item]) {
        let auxItems = allItems
        //verify for items with present tag
        let arrayPresentedItems = auxItems.filter({ (item) -> Bool in
            item.present?.boolValue == true
        })
    
        //create present tag
        if arrayPresentedItems.count > 0 {
            items = arrayPresentedItems
        } else {
            createPresentTagList(allItems: auxItems)
        }
    }
    
    func createPresentTagList(allItems: [Item]) {
        do {
            var auxItems = allItems.sorted(by: { (item1, item2) -> Bool in
                (item1.countReceipt?.intValue)! < (item2.countReceipt?.intValue)!
            })
            let mediumPrice = try calcMediumCost()
            var value = 0.0
            var auxItemArray:[Item] = [Item]()
            while value < mediumPrice, let item = auxItems.popLast() {
                value += (item.vlTotal?.doubleValue)!
                item.present = NSNumber(booleanLiteral: true)
                auxItemArray.append(item)
            }
            items = auxItemArray
        } catch {
            
        }
    }
    
    fileprivate func removeRedudancy(receipt: Receipt, _ itemList: [AnyObject]) -> [Item] {
        let newMapped = itemList.reduce([Item]()) {
            a, item in
            var b = [Item]()
            if !a.contains(where: { verifyItemByFuzzy(lhs: $0.descricao!, rhs: item[Keys.ItemDescriptionKey] as! String) }) {
                let newItem = createItem(item: item as! [String : Any])
                newItem.document = receipt
                b.append(newItem)
            } else {
                let index = a.index(where: { verifyItemByFuzzy(lhs: $0.descricao!, rhs: item[Keys.ItemDescriptionKey] as! String) })!
                let item2 = a[index]
                item2.addCountQte(1)
            }
            b.append(contentsOf: a)
            return b
        }
        
        return newMapped
    }
    
    func createItem(item: [String : Any]) -> Item {
        let itemObj:Item = NSEntityDescription.insertNewObject(forEntityName: Keys.ReceiptItemEntityName, into: self.dataStack.mainContext) as! Item
        itemObj.hyp_fill(with: item)
        return itemObj
    }
    
    func verifyItemByFuzzy(lhs: String, rhs: String) -> Bool {
        let fuzzy1 = lhs.trim().score(rhs.trim(), fuzziness:1.0)
        return fuzzy1 > 0.45
    }
    
    fileprivate func verifyNewObject(_ key:String) throws -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.ReceiptEntityName)
        fetchRequest.predicate = NSPredicate(format: "remoteID = %@",key)
        do {
            let result = try self.dataStack.mainContext.fetch(fetchRequest)
            if result.count > 0 {
                return true
            }
        } catch let error as NSError {
            throw Errors.CoreDataError("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }
    
    fileprivate func saveContex() throws {
        do {
            try self.dataStack.mainContext.save()
        } catch {
            throw Errors.CoreDataError("Failure to save context: \(error)")
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
            
            do {
                try saveContex()
            } catch {
                
            }
        }
    }
}
