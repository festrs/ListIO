//
//  Receipt+CoreDataClass.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-03-28.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm

class Receipt: Object, Mappable {
    dynamic var identifier = 0
    dynamic var createdAt: Date?
    dynamic var mes: String?
    dynamic var payments: Data?
    var items: List<Item> = List<Item>()

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        items       <- (map["items"], ListTransform<Item>())
        createdAt   <- (map["created_at"], DateTransform())
        payments    <- map["payments"]
        mes         <- map["mes"]
        identifier  <- map["id"]
    }

    override static func primaryKey() -> String? {
        return "identifier"
    }

    static func getUniqueItems(withPresent: Bool = false) -> [Item]? {
        let realm = try! Realm()
        var items = realm.objects(Item.self).toArray(ofType: Item.self)
        if withPresent {
            items = items.filter {$0.present == true}
        }

        items = items.reduce([Item](), { uniqueElements, element in
            if uniqueElements.index(where: {$0 == element}) != nil {
                return uniqueElements
            } else {
                return uniqueElements + [element]
            }
        })
        return items

    }
}
