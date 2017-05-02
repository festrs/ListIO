//
//  Item.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-05-31.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import CoreData
import StringScore_Swift


class Item: NSManagedObject {
    
}

func == (lhs: Item, rhs: Item) -> Bool {
    let fuzzy1 = lhs.descricao!.trim().score(rhs.descricao!.trim(), fuzziness:1.0)
    return fuzzy1 > 0.45
}
