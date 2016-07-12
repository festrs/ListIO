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
    
    func getAllDocumentsByGroup(groupObj: Group) -> [Document]?{
        let fetchRequest = NSFetchRequest(entityName: "Document")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "groupType.name == %@", groupObj.name!)
        do{
            return try self.mainContext.executeFetchRequest(fetchRequest) as? [Document]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func getAllItemsFromGroup(groupObj: Group){
        let request = NSFetchRequest(entityName: "Item")
        var expressionDescriptions = [AnyObject]()
        
//        expressionDescriptions.append("descricao")
//        //expressionDescriptions.append("document.remoteID")
//        
//        //Count qtde collum on data base
//        var expressionDescription = NSExpressionDescription()
//        expressionDescription.name = "QtdeCount"
//        expressionDescription.expression = NSExpression(format: "@sum.qtde")
//        expressionDescription.expressionResultType = .Integer32AttributeType
//        expressionDescriptions.append(expressionDescription)
//        
//        //Get createdAt collum on documents
//        expressionDescription = NSExpressionDescription()
//        expressionDescription.name = "DocCount"
//        let sqExpression=NSExpression(format: "SUBQUERY(document, $t, $t.remoteID)")
//        expressionDescription.expression=NSExpression(forFunction: "count", arguments: [sqExpression])
//        //expressionDescription.expression = NSExpression(format: "count:(document.groupType.name)")
//        expressionDescription.expressionResultType = .DoubleAttributeType
//        expressionDescriptions.append(expressionDescription)
//        
//        //GroupBy for descricao and document.creadteAt
//        request.propertiesToGroupBy = ["descricao", "document.groupType.name"]
//        request.resultType = .DictionaryResultType
//        request.sortDescriptors = [NSSortDescriptor(key: "descricao", ascending: true)]
//        request.propertiesToFetch = expressionDescriptions
//        
//        request.predicate = NSPredicate(format: "document.groupType.name = %@",groupObj.name!)
//        
//        do{
//            //let results = try self.mainContext.executeFetchRequest(request)
//            //print(results)
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
    }
    
    func savingData(json:[String: AnyObject], groupObj: Group){
        guard verifyNewObject(json["id"] as! String, groupObj: groupObj) == false else{
            return
        }
        
        let docObj = NSEntityDescription.insertNewObjectForEntityForName("Document", inManagedObjectContext: self.mainContext) as! Document
        
        docObj.hyp_fillWithDictionary(json)
        
        for item in json["items"] as! [AnyObject] {
            let itemObj = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: self.mainContext) as! Item
            if let itemT = item as? [String:AnyObject]{
                itemObj.hyp_fillWithDictionary(itemT)
            }
            itemObj.document = docObj
            docObj.mutableSetValueForKey("items").addObject(itemObj)
        }
        
        groupObj.mutableSetValueForKey("documents").addObject(docObj)
        docObj.groupType = groupObj
        
        saveContex()
    }
    
    func verifyNewObject(key:String, groupObj:Group) -> Bool{
        let fetchRequest = NSFetchRequest(entityName: "Document")
        fetchRequest.predicate = NSPredicate(format: "remoteID = %@ AND groupType.name = %@",key,groupObj.name!)
        do{
            let result = try self.mainContext.executeFetchRequest(fetchRequest)
            if result.count > 0{
                return true
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }
    
    func saveItemListObj(array:[MapItem],groupObj:Group){
        groupObj.mutableSetValueForKey("itemList").removeAllObjects()
        var totalValue = 0.0
        for item in array{
            let listObj = NSEntityDescription.insertNewObjectForEntityForName("ItemList", inManagedObjectContext: self.mainContext) as! ItemList
            listObj.hyp_dictionary()
            listObj.hyp_fillWithDictionary(item.toJson())
            groupObj.mutableSetValueForKey("itemList").addObject(listObj)
            totalValue += item.vlUnit * Double(item.qtde)
        }
        groupObj.totalValue = totalValue
        saveContex()
    }
    
    func saveContex() {
        do {
            try self.mainContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}