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
    @objc dynamic var identifier = 0
    @objc dynamic var createdAt: Date?
    @objc dynamic var mes: String?
    @objc dynamic var payments: Data?
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
        return items

    }
}
