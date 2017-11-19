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
import Photos

class Item: Object, Mappable {
    //optional
    dynamic var alert = false
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
        remoteID            <- map["id"]
        descricao           <- map["descricao"]
        qtde                <- map["qtde"]
        vlTotal             <- map["vl_total"]
        vlUnit              <- map["vl_unit"]
    }

    override static func primaryKey() -> String? {
        return "remoteID"
    }

    static func getImage(localUrl: String) -> UIImage? {

        let assetUrl = URL(string: "assets-library://asset/asset.JPG?id=\(localUrl)")
        let asset = PHAsset.fetchAssets(withALAssetURLs: [assetUrl!], options: nil)

        guard let result = asset.firstObject else {
            return nil
        }
        var assetImage: UIImage?
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: result,
                                              targetSize: UIScreen.main.bounds.size,
                                              contentMode: PHImageContentMode.aspectFill,
                                              options: options) { image, _ in
                                                assetImage = image
        }
        return assetImage
    }
}

func == (lhs: Item, rhs: Item) -> Bool {
    let fuzzy1 = lhs.descricao!.trim().score(word: rhs.descricao!.trim(), fuzziness:1.0)
    return fuzzy1 > 0.55
}
