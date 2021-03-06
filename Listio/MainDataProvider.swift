//
//  DataProvider.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import Kingfisher
import Photos

enum Errors: Error {
    // swiftlint:disable identifier_name
    case CoreDataError(String)
    case DoubleReceiptWithSameID
}

public class MainDataProvider: NSObject, MainDataProviderProtocol {

    public var tableView: UITableView!
    var items: [Item] = []

    public func performFetch() throws {
        items = try getUniqueItems()!
        tableView.reloadData()
    }

    public func calcMediumCost() -> Double {
        return items.reduce(0.0) { (result, item) -> Double in
            return item.vlTotal + result
        }
    }

    public func getCountItems() -> Int {
        return items.count
    }

    func getUniqueItems() throws -> [Item]? {
        guard let result = Receipt.getUniqueItems() else { return [] }
        return result.filter { $0.present == true }
    }
}

extension MainDataProvider {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.MainDataProvider.CellIdentifier,
                                                       for: indexPath)
            as? MainTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        let item = items[indexPath.row]

        cell.nameLabel.text = item.descricao
        cell.unLabel.text = "UN \(item.qtde)"
        cell.valueLabel.text = NSNumber(value: item.vlUnit).maskToCurrency()
        let placeHolder = UIImage(named: "noimage")

        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        var image: UIImage? = nil
        if status == PHAuthorizationStatus.authorized {
            image = getImage(localUrl: item.imgUrl ?? "")
        }
        if image == nil {
            let url = URL(string: item.imgUrl ?? "")
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

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView,
                          commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let obj = items.remove(at: indexPath.row)
            DatabaseManager.write(DatabaseManager.realm, writeClosure: {
                obj.present = false
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}
