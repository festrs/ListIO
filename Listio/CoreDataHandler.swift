//
//  CoreDataHandler.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-06-07.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData
import Sync

public class CoreDataHandler {
    let mainContext:NSManagedObjectContext!
    
    struct Keys {
        static let ReceiptEntityName = "Receipt"
        static let ReceiptItemsArrayName = "items"
        static let ReceiptItemEntityName = "Item"
        static let ReceiptSortDescriptor = "createdAt"
        static let ItemDescriptionKey = "descricao"
    }

    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    
    func getAllReceipt() -> [Receipt]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.ReceiptEntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Keys.ReceiptSortDescriptor, ascending: false)]
        do{
            return try self.mainContext.fetch(fetchRequest) as? [Receipt]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func getAllItems() -> [Item]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.ReceiptItemEntityName)
        do{
            return try self.mainContext.fetch(fetchRequest) as? [Item]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func savingData(_ json:[String: AnyObject]) -> Bool {
        guard verifyNewObject(json["id"] as! String) == false else {
            return false
        }
        let docObj = NSEntityDescription.insertNewObject(forEntityName: Keys.ReceiptEntityName, into: self.mainContext) as! Receipt
        docObj.hyp_fill(with: json)
        let itemsArray = removeRedudancy(receipt: docObj, json[Keys.ReceiptItemsArrayName] as! [AnyObject])
        
        let allItems = getAllItems()!
        
        _ = allItems.reduce([Item]()){
            uniqueElements, element in
            
            if let index = uniqueElements.index(where: {$0 == element}) {
                let auxItem = uniqueElements[index]
                auxItem.addCountDocument(1)
                return uniqueElements
            } else {
                return uniqueElements + [element]
            }
        }

        docObj.addToItems(NSSet(array: itemsArray))

        saveContex()
        return true
    }
    
    func calcMediumCost() -> Double {
        let receipts = getAllReceipt()
        let values: [Double] = receipts!.map { (receipt) -> Double in
            let payment = NSKeyedUnarchiver.unarchiveObject(with: receipt.payments! as Data) as! NSDictionary
            return Double(payment["vl_total"] as! String)!
        }
        return values.reduce(0, +)/Double(values.count)
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
        let itemObj:Item = NSEntityDescription.insertNewObject(forEntityName: Keys.ReceiptItemEntityName, into: self.mainContext) as! Item
        itemObj.hyp_fill(with: item)
        return itemObj
    }
    
    func verifyItemByFuzzy(lhs: String, rhs: String) -> Bool {
        let fuzzy1 = lhs.trim().score(rhs.trim(), fuzziness:1.0)
        return fuzzy1 > 0.45
    }
    
    fileprivate func verifyNewObject(_ key:String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.ReceiptEntityName)
        fetchRequest.predicate = NSPredicate(format: "remoteID = %@",key)
        do {
            let result = try self.mainContext.fetch(fetchRequest)
            if result.count > 0 {
                return true
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }
    
    fileprivate func saveContex() {
        do {
            try self.mainContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }

}
