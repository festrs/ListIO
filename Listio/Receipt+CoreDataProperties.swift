//
//  Receipt+CoreDataProperties.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-03-28.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import CoreData
import Sync

extension Receipt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Receipt> {
        return NSFetchRequest<Receipt>(entityName: Constants.Receipt.ReceiptEntityName)
    }

    @nonobjc public class func getAllReceipt(_ mainContext: NSManagedObjectContext) throws -> [Receipt]? {
        let fetchRequest: NSFetchRequest<Receipt> = Receipt.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.Receipt.ReceiptSortDescriptor, ascending: false)]
        do {
            return try mainContext.fetch(fetchRequest)
        } catch let error as NSError {
            throw Errors.CoreDataError("Could not fetch \(error), \(error.userInfo)")
        }
    }

    @nonobjc public class func createReceipt(_ mainContext: NSManagedObjectContext, json: [String: AnyObject]) throws {
        // swiftlint:disable force_cast
        guard try verifyNewReceipt(mainContext, key: json["id"] as! String) == false else {
            throw Errors.DoubleReceiptWithSameID
        }
        // swiftlint:disable force_cast
        let docObj = NSEntityDescription.insertNewObject(forEntityName: Constants.Receipt.ReceiptEntityName,
                                                         into: mainContext) as! Receipt
        docObj.hyp_fill(with: json)

        for item in (json[Constants.Receipt.ReceiptItemsArrayName] as? [AnyObject])! {
            // swiftlint:disable force_cast
            let itemObj: Item = NSEntityDescription.insertNewObject(forEntityName: Constants.Receipt.ItemEntityName,
                                                                    into: mainContext) as! Item
            itemObj.hyp_fill(with: item as! [String : Any])
            docObj.addToItems(itemObj)
        }

        try setCountReceipt(mainContext)
    }

    @nonobjc public class func setCountReceipt(_ mainContext: NSManagedObjectContext) throws {
        guard let allItems = try Item.getAllItems(mainContext) else {
            throw Errors.CoreDataError("")
        }
        for (i, item) in allItems.enumerated() {
            var count = 1
            for (j, auxItem) in allItems.enumerated() {
                if item == auxItem && i != j {
                    count += 1
                }
            }
            item.countReceipt = NSNumber(value: count)
        }
    }

    @nonobjc public class func verifyNewReceipt(_ mainContext: NSManagedObjectContext, key: String) throws -> Bool {
        let fetchRequest: NSFetchRequest<Receipt> = Receipt.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "remoteID = %@", key)
        do {

            let result = try mainContext.fetch(fetchRequest)
            if result.count > 0 {
                return true
            }
        } catch let error as NSError {
            throw Errors.CoreDataError("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var link: String?
    @NSManaged public var mes: String?
    @NSManaged public var payments: NSData?
    @NSManaged public var remoteID: String?
    @NSManaged public var value: String?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension Receipt {

    @objc(addItemsObject:)
    @NSManaged func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
