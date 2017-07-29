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

enum Errors: Error {
    // swiftlint:disable identifier_name
    case CoreDataError(String)
    case DoubleReceiptWithSameID
}

public class MainDataProvider: NSObject, MainDataProviderProtocol {
    struct Keys {
        static let CellIdentifier = "mainCell"
        static let ReceiptEntityName = "Receipt"
        static let ReceiptItemsArrayName = "items"
        static let ReceiptItemEntityName = "Item"
        static let ReceiptSortDescriptor = "createdAt"
        static let ItemDescriptionKey = "descricao"
    }

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.CellIdentifier, for: indexPath)
            as? MainTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        let item: Item? = items[indexPath.row]

        cell.nameLabel.text = item?.descricao
        cell.unLabel.text = "UN \(item?.qtde?.intValue ?? 0)"
        cell.valueLabel.text = item?.vlUnit?.toMaskReais()
        let url = URL(string: item?.imgUrl ?? "")
        let placeHolder = UIImage(named: "noimage")
        cell.productImageView.kf.setImage(with: url,
                                          placeholder: placeHolder,
                                          options: nil,
                                          progressBlock: nil,
                                          completionHandler: nil)

        return cell
    }

    public func tableView(_ tableView: UITableView,
                          commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let obj = items.remove(at: indexPath.row)
            obj.present = NSNumber(booleanLiteral: false)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
}
