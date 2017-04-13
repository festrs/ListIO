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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item");
    }

    @NSManaged public var descricao: String?
    @NSManaged public var qtde: NSDecimalNumber?
    @NSManaged public var remoteID: String?
    @NSManaged public var un: String?
    @NSManaged public var vlTotal: NSNumber?
    @NSManaged public var vlUnit: NSNumber?
    @NSManaged public var present: NSNumber?
    @NSManaged public var countDocument: NSNumber?
    @NSManaged public var document: Receipt?

    func addCountQte(_ value: Int) {
        let aux = (qtde?.intValue)! + value
        qtde = NSDecimalNumber(value: aux)
    }
    
    func addCountDocument(_ value: Int) {
        let aux = (countDocument?.intValue)! + value
        countDocument = NSDecimalNumber(value: aux)
    }
    
}
