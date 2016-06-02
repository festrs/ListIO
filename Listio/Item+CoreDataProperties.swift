//
//  Item+CoreDataProperties.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-05-31.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var descricao: String?
    @NSManaged var qtde: NSDecimalNumber?
    @NSManaged var remoteID: NSNumber?
    @NSManaged var un: String?
    @NSManaged var vlTotal: String?
    @NSManaged var vlUnit: String?
    @NSManaged var document: Document?

}
