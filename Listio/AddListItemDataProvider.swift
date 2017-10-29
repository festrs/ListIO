//
//  AddListItemDataProvider.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-23.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import RealmSwift

class AddListItemDataProvider: NSObject, AddListItemDataProviderProtocol {
    struct Keys {
        static let CellIdentifier = "ItemListCell"
        static let InfoCellIdentifer = "infoCell"
    }

    // swiftlint:disable force_try
    let realm = try! Realm()
    weak public var tableView: UITableView!
    var items: [Item] = [Item]()

    func performFetch() throws {
        items = try getUniqueItems()
        tableView.reloadData()
    }

    func getUniqueItems() throws -> [Item] {
        guard let items = Receipt.getUniqueItems() else { return [] }
        return items
    }

    func countItems() -> Int {
        return items.count
    }

    func unselectAll() {
        for value in items {
            try! realm.write {
                value.present = false
            }
        }
        tableView.reloadData()
    }

    func selectAll() {
        for value in items {
            try! realm.write {
                value.present = true
            }
        }
        tableView.reloadData()
    }
}

extension AddListItemDataProvider {
    // MARk: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemObj = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? AddListItemTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        if itemObj.present {
            cell.accessoryType = .none
            try! realm.write {
                itemObj.present = false
            }
        } else {
            cell.accessoryType = .checkmark
            try! realm.write {
                itemObj.present = true
            }
        }
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            guard items.count != 0 else { return }

            let obj = items.remove(at: indexPath.row)
            try! realm.write {
                realm.delete(obj)
            }

            if items.count == 0 {
                tableView.setEditing(false, animated: true)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}

extension AddListItemDataProvider {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            return 1
        }
        return items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if items.isEmpty {
            return 150
        }
        return 58
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if items.count == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.InfoCellIdentifer,
                                                           for: indexPath) as? AddListItemTableViewCell else {
                                                            fatalError("Unexpected Index Path")
            }

            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Keys.CellIdentifier,
                                                       for: indexPath) as? AddListItemTableViewCell else {
                                                        fatalError("Unexpected Index Path")
        }
        let itemObj = items[indexPath.row]

        cell.nameLabel.text = itemObj.descricao
        cell.priceLabel.text = NSNumber(value: itemObj.vlUnit).maskToCurrency()
        cell.unLabel.text = "UN \(itemObj.qtde)"

        if itemObj.present {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
