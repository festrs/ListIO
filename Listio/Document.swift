//
//  Document.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-05-31.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import CoreData

class Document: NSManagedObject{
    
}

func ==(lhs: Document, rhs: Document) -> Bool {

    let arrayA = lhs.items?.allObjects as! [Item]
    let arrayB = rhs.items?.allObjects as! [Item]
    
    var count = 0;
    for item in arrayB{
        for otherItem in arrayA{
            if item == otherItem{
                count += 1
            }
        }
    }
    let porcentage = (count*100/arrayA.count)
    
    return porcentage > 65
}

