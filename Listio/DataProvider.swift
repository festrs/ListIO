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

public class DataProvider: NSObject, DataProviderProtocol {

    struct Keys {
        static let CellIdentifier = "documentCell"
        static let ReceiptEntityName = "Receipt"
        static let ReceiptItemsArrayName = "items"
        static let ReceiptItemEntityName = "Item"
        static let ReceiptSortDescriptor = "createdAt"
        static let ItemDescriptionKey = "descricao"
        static let numberOfSections = 2
    }
    
    public var dataStack: DATAStack!
    weak public var tableView: UITableView!
    var itemsSection1:[Item] = []
    var itemsSection2:[Item] = []
    
    public required init(DATAStack: DATAStack) {
        super.init()
        self.dataStack = DATAStack
    }
    
    public func fetch() throws {
        setItemSection(allItems: try getUniqueItems()!)
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
        return itemsSection1.count + itemsSection2.count
    }
    
    func getUniqueItems() throws -> [Item]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.ReceiptItemEntityName)
        do{
            var items = try self.dataStack.mainContext.fetch(fetchRequest) as? [Item]
            items = items?.reduce([Item](), { uniqueElements, element in
                if uniqueElements.index(where: {$0 == element}) != nil {
                    return uniqueElements
                } else {
                    return uniqueElements + [element]
                }
            })
            return items
        } catch let error as NSError {
            throw Errors.CoreDataError("Could not fetch \(error), \(error.userInfo)")
        }
    }

    
    func getAllReceipt() throws -> [Receipt]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.ReceiptEntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Keys.ReceiptSortDescriptor, ascending: false)]
        do{
            return try self.dataStack.mainContext.fetch(fetchRequest) as? [Receipt]
        } catch let error as NSError {
            throw Errors.CoreDataError("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func getAllItems() throws -> [Item]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.ReceiptItemEntityName)
        do{
            return try self.dataStack.mainContext.fetch(fetchRequest) as? [Item]
        } catch let error as NSError {
            throw Errors.CoreDataError("Could not fetch \(error), \(error.userInfo)")
        }
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
    }
    
    func setItemSection(allItems: [Item]) {
        
        var sortedItems = allItems.sorted(by: { (item1, item2) -> Bool in
            (item1.countReceipt?.intValue)! < (item2.countReceipt?.intValue)!
        })
        do {
            let mediumPrice = try calcMediumCost()
            var value = 0.0
            var auxItemArray:[Item] = [Item]()
            while value < mediumPrice, let item = sortedItems.popLast() {
                value += (item.vlTotal?.doubleValue)!
                auxItemArray.append(item)
            }
            
            itemsSection1 = auxItemArray
            itemsSection2 = sortedItems
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


extension DataProvider : UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Keys.numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
                return itemsSection1.count
        }
        return itemsSection2.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Keys.CellIdentifier, for: indexPath) as! DocumentUiTableViewCell
        
        var item:Item? = nil
        
        if indexPath.section == 0 {
            item = itemsSection1[indexPath.row]
        } else {
            item = itemsSection2[indexPath.row]
        }
        
        cell.nameLabel.text = item?.descricao
        cell.unLabel.text = item?.qtde?.intValue.description
        cell.valueLabel.text = item?.vlUnit?.toMaskReais()
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else {
            return
        }
        //swap(&items![sourceIndexPath.row], &items![destinationIndexPath.row])
    }
}
