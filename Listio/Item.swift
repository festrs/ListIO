//
//  Item+CoreDataClass.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-08-17.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import StringScore_Swift

class Item: Object, Mappable {
    //optional
    dynamic var alert = 0
    dynamic var countReceipt = 0
    dynamic var qtde = 0
    dynamic var alertDays = 0
    dynamic var vlTotal = 0.0
    dynamic var vlUnit = 0.0
    dynamic var present = false
    dynamic var alertDate: Date?
    dynamic var descricao: String?
    dynamic var imgUrl: String?
    dynamic var unidade: String?

    //Non optional
    dynamic var document: Receipt?
    dynamic var remoteID: String?

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        remoteID    <- map["id"]
        descricao   <- map["descricao"]
        unidade     <- map["un"]
        vlTotal     <- map["vl_total"]
        vlUnit      <- map["vl_unit"]
    }
}

func == (lhs: Item, rhs: Item) -> Bool {
    let fuzzy1 = lhs.descricao!.trim().score(word: rhs.descricao!.trim(), fuzziness:1.0)
    return fuzzy1 > 0.45
}
