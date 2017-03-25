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

class CoreDataHandler {
    
    let mainContext:NSManagedObjectContext!
    
    init(mainContext:NSManagedObjectContext){
        self.mainContext = mainContext
    }
    
    func getAllDocuments() -> [Document]?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do{
            return try self.mainContext.fetch(fetchRequest) as? [Document]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func savingData(_ json:[String: AnyObject]) -> Bool{
        guard verifyNewObject(json["id"] as! String) == false else{
            return false
        }
        let docObj = NSEntityDescription.insertNewObject(forEntityName: "Document", into: self.mainContext) as! Document
        docObj.hyp_fill(with: json)
        for item in json["items"] as! [AnyObject] {
            let itemObj = NSEntityDescription.insertNewObject(forEntityName: "Item", into: self.mainContext) as! Item
            if let itemT = item as? [String:AnyObject]{
                itemObj.hyp_fill(with: itemT)
            }
            itemObj.document = docObj
            docObj.mutableSetValue(forKey: "items").add(itemObj)
        }
        saveContex()
        return true
    }
    
    func verifyNewObject(_ key:String) -> Bool{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
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
    
    func saveItemListObj(_ array:[MapItem]){
        deleteAllItemList()
        var totalValue = 0.0
        for item in array{
            let listObj = NSEntityDescription.insertNewObject(forEntityName: "ItemList", into: self.mainContext) as! ItemList
            listObj.hyp_dictionary()
            listObj.hyp_fill(with: item.toJson())
            totalValue += item.vlUnit * Double(item.qtde)
        }
        saveContex()
    }
    
    func deleteAllItemList(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemList")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.mainContext.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func saveContex() {
        do {
            try self.mainContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}
