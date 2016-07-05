//
//  Group.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-06-05.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import CoreData


class Group: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    func addDocument(document:Document?){
        self.mutableSetValueForKey("documents").addObject(document!)
    }

}
