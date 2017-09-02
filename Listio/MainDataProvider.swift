//
//  DataProvider.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData
import DATAStack
import Kingfisher
import Photos

enum Errors: Error {
    // swiftlint:disable identifier_name
    case CoreDataError(String)
    case DoubleReceiptWithSameID
}

public class MainDataProvider: NSObject, MainDataProviderProtocol {

    public var dataStack: DATAStack!
    weak public var tableView: UITableView!
    public var items: [Item] = []

    public func performFetch() throws {
        items = try getUniqueItems()!
        tableView.reloadData()
    }

    public func calcMediumCost() -> Double {
        return items.reduce(0.0) { (result, item) -> Double in
            return (item.vlTotal?.doubleValue)! + result
        }
    }

    public func getCountItems() -> Int {
        return items.count
    }

    func getUniqueItems() throws -> [Item]? {
        return try Item.getUniqueItems(dataStack.mainContext, withPresent: true)
    }
}

extension MainDataProvider {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.MainDataProvider.CellIdentifier,
                                                       for: indexPath)
            as? MainTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        let item: Item? = items[indexPath.row]

        cell.nameLabel.text = item?.descricao
        cell.unLabel.text = "UN \(item?.qtde?.intValue ?? 0)"
        cell.valueLabel.text = item?.vlUnit?.toMaskReais()
        let placeHolder = UIImage(named: "noimage")

        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        var image: UIImage? = nil
        if status == PHAuthorizationStatus.authorized {
            image = getImage(localUrl: item?.imgUrl ?? "")!
        }
        if image == nil {
            let url = URL(string: item?.imgUrl ?? "")
            cell.productImageView.kf.setImage(with: url,
                                              placeholder: placeHolder,
                                              options: nil,
                                              progressBlock: nil,
                                              completionHandler: nil)
        } else {
            cell.productImageView.image = image
        }
        cell.productImageView.layer.cornerRadius = cell.productImageView.frame.size.height/2.0
        cell.productImageView.layer.masksToBounds = true
        return cell
    }

    func getImage(localUrl: String) -> UIImage? {

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

    public func tableView(_ tableView: UITableView,
                          commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let obj = items.remove(at: indexPath.row)
            obj.present = 0
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
}
