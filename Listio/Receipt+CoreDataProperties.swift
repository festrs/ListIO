//
//  Receipt+CoreDataProperties.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-03-28.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import CoreData


extension Receipt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Receipt> {
        return NSFetchRequest<Receipt>(entityName: "Receipt");
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