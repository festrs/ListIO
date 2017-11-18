//
//  ItemViewModel.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-11-18.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit

protocol ItemViewModelProtocol: class, NewItemDelegate {

    var dateDescr: String? { get }
    var itemDaysToExpire: String? { get }
    var itemName: String? { get }
    var itemUnit: String? { get }
    var itemPrice: String? { get }
    var hasExpireAlert: Bool { get }
    var itemImageUrl: String? { get }
    var itemDidChange: ((ItemViewModelProtocol) -> Void)? { get set }

    func reloadItem()
    func changeActiveStateOfAlert(_ state: Bool)
    func didFinishUpdating(item: Item)

    init(item: Item)
}

final class ItemViewModel: ItemViewModelProtocol {

    var item: Item {
        didSet {
            loadFields()
        }
    }
    var alertProvider: AlertProvider? = AlertProvider()

    var itemDidChange: ((ItemViewModelProtocol) -> Void)?
    var dateDescr: String?
    var itemDaysToExpire: String?
    var itemName: String?
    var itemUnit: String?
    var itemPrice: String?
    var hasExpireAlert: Bool = false
    var itemImageUrl: String?

    lazy var defaultDate = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()

    func reloadItem() {
        guard let unwrappedItemDidChange = itemDidChange else {
            return
        }
        unwrappedItemDidChange(self)
    }

    func changeActiveStateOfAlert(_ state: Bool) {
        if state {
            let alertDate = item.alertDate ?? defaultDate
            let dictionary = [
                Constants.notificationIdentifierKey: item.remoteID ?? "" ,
                Constants.notificationProductNameKey: item.descricao ?? "",
                Constants.notificationProductDateKey: alertDate.getDateStringShort()
            ]

            let subtractDays = -(item.alertDays)

            let fireDate = Calendar.current.date(byAdding: .day,
                                                 value: subtractDays,
                                                 to: alertDate)

            guard (alertProvider?.registerForLocalNotification(on: UIApplication.shared))! else {
                return
            }

            alertProvider?.dispatchlocalNotification(with: "Lista Rápida",
                body: "O produto \(item.descricao!) ira vencer em \(alertDate.getDateStringShort())!",
                userInfo: dictionary,
                at: fireDate!)
        } else {
            alertProvider?.removeLocalNotificationByIdentifier(withID: item.remoteID )
        }

        DatabaseManager.write(DatabaseManager.realm, writeClosure: {
            if item.alertDate == nil {
                item.alertDate = defaultDate
            }
            item.alert = state
        })
    }

    required init(item: Item) {
        self.item = item
        loadFields()
    }

    func loadFields() {
        itemName = item.descricao
        itemUnit = "Quantidade (\(item.qtde.description))"
        itemPrice = NSNumber(value: item.vlUnit).maskToCurrency()
        itemDaysToExpire = "Aviso \(item.alertDays) dias antes do vencimento."
        hasExpireAlert = item.alert
        itemImageUrl = item.imgUrl ?? ""

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short

        if let alertDate = item.alertDate {
            dateDescr = dateFormatter.string(from: alertDate)
        } else {
            dateDescr = dateFormatter.string(from: defaultDate)
        }
    }
}

extension ItemViewModel: NewItemDelegate {
    func didFinishUpdating(item: Item) {
        self.item = item
    }
}
