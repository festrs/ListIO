//
//  Item+CoreDataProperties.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-03-28.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import CoreData

extension Item {
    struct Keys {
        static let ItemEntityName = "Item"
        static let ItemsArrayName = "items"
        static let sortKey = "descricao"
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: Keys.ItemEntityName);
    }
    
    @nonobjc public class func getAllItems(_ mainContext: NSManagedObjectContext) throws -> [Item]? {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        do{
            return try mainContext.fetch(fetchRequest)
        } catch let error as NSError {
            throw Errors.CoreDataError("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @nonobjc public class func getUniqueItems(_ mainContext: NSManagedObjectContext, withPresent: Bool = false) throws -> [Item]? {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Keys.sortKey, ascending: true)]
        if withPresent {
            fetchRequest.predicate = NSPredicate(format: "present == %@", NSNumber(booleanLiteral: true))
        }
        do{
            var items = try mainContext.fetch(fetchRequest)
            items = items.reduce([Item](), { uniqueElements, element in
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
    
    convenience init(withName name: String, withImageUrl url:String, intoMainContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Keys.ItemEntityName, in: context)!
        if #available(iOS 10.0, *) {
            self.init(context: context)
        } else {
            self.init(entity: entity, insertInto: context)
        }
        self.descricao = name
        self.imgUrl = url
    }
    
    @NSManaged public var descricao: String?
    @NSManaged public var imgUrl: String?
    @NSManaged public var qtde: NSDecimalNumber?
    @NSManaged public var remoteID: String?
    @NSManaged public var un: String?
    @NSManaged public var vlTotal: NSNumber?
    @NSManaged public var vlUnit: NSNumber?
    @NSManaged public var present: NSNumber?
    @NSManaged public var countReceipt: NSNumber?
    @NSManaged public var document: Receipt?
    
}
