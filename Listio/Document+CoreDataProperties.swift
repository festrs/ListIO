//
//  Document+CoreDataProperties.swift
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

extension Document {

    @NSManaged var createdAt: Date?
    @NSManaged var link: String?
    @NSManaged var mes: String?
    @NSManaged var payments: Data?
    @NSManaged var remoteID: String?
    @NSManaged var value: String?
    @NSManaged var items: NSSet?

}
