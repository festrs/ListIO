//
//  ItemList+CoreDataProperties.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-07-22.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ItemList {

    @NSManaged var countDocument: NSNumber?
    @NSManaged var name: String?
    @NSManaged var qtde: NSNumber?
    @NSManaged var vlTotal: NSNumber?
    @NSManaged var vlUnit: NSNumber?

}
