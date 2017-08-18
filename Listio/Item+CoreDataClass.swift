//
//  Item+CoreDataClass.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-08-17.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import CoreData
import StringScore_Swift

public class Item: NSManagedObject {

}

func == (lhs: Item, rhs: Item) -> Bool {
    let fuzzy1 = lhs.descricao!.trim().score(word: rhs.descricao!.trim(), fuzziness:1.0)
    return fuzzy1 > 0.45
}
