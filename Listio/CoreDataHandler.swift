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

struct ViewItem :Equatable {
    var countDocument = 0
    var qtde = 0
    var name = ""
    var vlUnit:Double = 0
    var vlTotal:Double = 0
    
    mutating func addCountQte(_ value: Int){
        qtde += value
    }
    
    func toJson() ->[String : AnyObject]{
        return ["countDocument":countDocument as AnyObject,"qtde":qtde as AnyObject,"name":name as AnyObject,"vlUnit":vlUnit as AnyObject,"vlTotal":vlTotal as AnyObject]
    }
}

func ==(lhs: ViewItem, rhs: ViewItem) -> Bool {
    let fuzzy1 = lhs.name.trim().score(rhs.name.trim(), fuzziness:1.0)
    return fuzzy1 > 0.45
}

class CoreDataHandler {
    let mainContext:NSManagedObjectContext!
    var itemList:[ViewItem]!
    
    struct Keys {
        static let ReceiptEntityName = "Receipt"
        static let ReceiptItemsArrayName = "items"
        static let ReceiptItemEntityName = "Item"
        static let ReceiptSortDescriptor = "createdAt"
    }

    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
        deleteAllData(entity: Keys.ReceiptEntityName)
        itemList = getAllItens(getAllDocuments()!)
    }
    
    func getAllDocuments() -> [Receipt]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.ReceiptEntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Keys.ReceiptSortDescriptor, ascending: false)]
        do{
            return try self.mainContext.fetch(fetchRequest) as? [Receipt]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func savingData(_ json:[String: AnyObject]) -> Bool {
        guard verifyNewObject(json["id"] as! String) == false else{
            return false
        }
        let docObj = NSEntityDescription.insertNewObject(forEntityName: Keys.ReceiptEntityName, into: self.mainContext) as! Receipt
        docObj.hyp_fill(with: json)
        let itemsArray = removeRedudancy(receipt: docObj, json[Keys.ReceiptItemsArrayName] as! [AnyObject])
        
        docObj.addToItems(NSSet(array: itemsArray))
        
        itemList = getAllItens(getAllDocuments()!)

        saveContex()
        return true
    }
    
    func getAllItens(_ documentList : [Receipt]) -> [ViewItem] {
        // put all itens in a single array
        let allItems = documentList.flatMap({ d in d.items!}) as! [Item]
        
        
        //check if the item is present in more them 1 document, return list of ViewItem
        return allItems.map {
            item in
            var countDoc = 0
            for document in documentList {
                for itemDoc:Item in document.items?.allObjects as! [Item] {
                    if itemDoc == item {
                        countDoc += 1
                        break;
                    }
                }
            }
            return ViewItem(countDocument: countDoc, qtde: (item.qtde?.intValue)!, name: item.descricao!, vlUnit: (item.vlUnit?.doubleValue)!, vlTotal: item.vlTotal!.doubleValue)
        }
    }
    
    fileprivate func removeRedudancy(receipt: Receipt, _ itemList: [AnyObject])->[Item]{
        let newMapped = itemList.reduce([Item]()) {
            a, item in
            var b = [Item]()
            var aux = a
            let itemObj:Item = NSEntityDescription.insertNewObject(forEntityName: Keys.ReceiptItemEntityName, into: self.mainContext) as! Item
            itemObj.hyp_fill(with: item as! [String : Any])
            if !a.contains(where: {$0 == itemObj}){
                itemObj.document = receipt
                b.append(itemObj)
            }else{
                let index = a.index(where: {$0 == itemObj})!
                let item2 = a[index]
                item2.addCountQte((itemObj.qtde?.intValue)!)
                aux.remove(at: index)
                aux.insert(item2, at: index)
                item2.document = receipt
            }
            b.append(contentsOf: aux)
            return b
        }

        return newMapped
    }
    
    fileprivate func verifyNewObject(_ key:String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.ReceiptEntityName)
        fetchRequest.predicate = NSPredicate(format: "remoteID = %@",key)
        do{
            let result = try self.mainContext.fetch(fetchRequest)
            if result.count > 0{
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
    
    fileprivate func deleteAllData(entity: String)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try mainContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                (managedObject as AnyObject).delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
}
