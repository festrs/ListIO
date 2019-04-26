//
//  NewItemViewModel.swift
//  Prod
//
//  Created by Felipe Dias Pereira on 2017-11-18.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit

enum NewItemError: Error {
    case itemNameBlank
}

protocol NewItemViewModelProtocol: class {

    var itemDaysToExpire: String? { get }
    var itemName: String? { get }
    var itemUnit: Int { get }
    var itemPriceString: String? { get }
    var hasExpireAlert: Bool { get }
    var itemImageUrl: String? { get }
    var alertDays: Int { get }
    var itemAlertDate: Date? { get }
    var itemImage: UIImage? { get }

    var alertDaysDidChange: ((NewItemViewModelProtocol) -> Void)? { get set }

    func changeItemPrice(to price: Double)
    func changeItemName(_ newName: String?)
    func changeItemUnit(to unit: Int)
    func changeAlertDate(_ date: Date?)
    func changeActiveStateOfAlert(_ state: Bool)
    func changeAlertDays(to value: Int)
    func changeItemImage(with image: UIImage, and identifier: String?)
    func saveItem() throws -> Item

    init(item: Item?)
}

class NewItemViewModel: NewItemViewModelProtocol {
    var item: Item?

    var itemDaysToExpire: String?
    var itemName: String?
    var itemPriceString: String?
    var itemUnit: Int = 0
    var hasExpireAlert: Bool = false
    var itemImageUrl: String?
    var itemImage: UIImage?
    var itemAlertDate: Date? = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
    var itemPrice: Double = 0.0

    var alertDaysDidChange: ((NewItemViewModelProtocol) -> Void)?

    var alertDays: Int = 5 {
        didSet {
            itemDaysToExpire = "Aviso \(alertDays) dias antes do vencimento."
            guard let unwrappedAlertDaysDidChange = alertDaysDidChange else {
                return
            }
            unwrappedAlertDaysDidChange(self)
        }
    }

    required init(item: Item?) {
        self.item = item
        loadFields()
    }

    func loadFields() {
        itemDaysToExpire = "Aviso \(alertDays) dias antes do vencimento."

        guard let unwrappedItem = item else {
            return
        }
        hasExpireAlert = unwrappedItem.alert
        alertDays = unwrappedItem.alertDays
        itemName = unwrappedItem.descricao
        itemUnit = unwrappedItem.qtde
        itemPrice = unwrappedItem.vlUnit
        itemPriceString = NSNumber(value: unwrappedItem.vlUnit).maskToCurrency()
        itemImageUrl = unwrappedItem.imgUrl
        hasExpireAlert = unwrappedItem.alert
        itemAlertDate = unwrappedItem.alertDate
    }

    func changeAlertDate(_ date: Date?) {
        itemAlertDate = date
    }

    func changeActiveStateOfAlert(_ state: Bool) {
        hasExpireAlert = state
    }

    func changeAlertDays(to value: Int) {
        alertDays = value
    }

    func changeItemImage(with image: UIImage, and identifier: String?) {
        itemImage = image
        itemImageUrl = identifier
    }

    func changeItemPrice(to price: Double) {
        itemPrice = price
    }

    func changeItemName(_ newName: String?) {
        itemName = newName
    }

    func changeItemUnit(to unit: Int) {
        itemUnit = unit
    }

    func saveItem() throws -> Item {
        if item != nil {
            DatabaseManager.write(DatabaseManager.realm, writeClosure: {
                item?.descricao = itemName
                item?.vlUnit = itemPrice
                item?.qtde = itemUnit
                item?.alert = hasExpireAlert
                item?.alertDate = itemAlertDate
                item?.alertDays = alertDays
                item?.imgUrl = itemImageUrl
            })
            return item!
        } else {
            guard itemName != nil && itemName != "" else {
                throw NewItemError.itemNameBlank
            }
            let newItem = Item()
            newItem.remoteID = UUID().uuidString
            newItem.descricao = itemName
            newItem.vlUnit = itemPrice
            newItem.qtde = itemUnit
            newItem.present = true
            newItem.alertDays = alertDays
            let newAlertDate = Calendar.current.date(byAdding: .day,
                                                     value: -(alertDays),
                                                     to: itemAlertDate!)
            newItem.alertDate = newAlertDate
            newItem.alert = hasExpireAlert
            newItem.imgUrl = itemImageUrl

            DatabaseManager.write(DatabaseManager.realm, writeClosure: {
                DatabaseManager.realm.add(newItem)
            })
            return newItem
        }
    }

}
