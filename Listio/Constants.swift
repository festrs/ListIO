//
//  Constants.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-08-12.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import Foundation

struct Constants {
    static let notificationIdentifierKey = "uuid"
    static let notificationProductNameKey = "productNameKey"
    static let notificationProductDateKey = "productDateKey"
    static let newProductAddedNotificationKey = "newProductAdded"

    struct API {
        #if Hml
        static let BaseURL = "http://192.168.0.4:3000"
        #else
        static let BaseURL = "https://nfc-e-server.herokuapp.com"
        #endif
        static let EndPointAllProducts = "/api/v1/qrdata"
        static let ProductBaseURL = "https://pod.opendatasoft.com/api/records/1.0/search/?dataset=pod_gtin&q=gtin_cd%3D"
    }

    struct MainDataProvider {
        static let CellIdentifier = "mainCell"
    }

    struct MainVC {
        static let EntityName = "ItemList"
        static let SortDescriptorField = "countDocument"
        static let IdentifierCell = "documentCell"
        static let HeaderSection1Identifier = "headerSection1"
        static let HeightForFooterView = 61.0
        static let SegueAddListItem = "toNewList"
        static let itemsIdentifier = "showItemsIdentifier"
        static let SegueIdentifierQRCode = "toQrCodeReader"
        static let ToCreateListIdentifier = "toCreateList"
        static let SucessAlertTitle = "Adicionado com sucesso"
        static let SucessAlertMSG = "Você deseja criar uma nova lista?"
        static let ProgressHUDStatus = "Adicionando ..."
        static let CancelButtonTittle = "Cancelar"
        static let SegueToNewItemIdentifier = "toNewItem"
        static let AlertDaysDefault = NSDecimalNumber(value: 5)
    }

    struct Receipt {
        static let ReceiptEntityName = "Receipt"
        static let ReceiptSortDescriptor = "createdAt"
        static let ReceiptItemsArrayName = "items"
        static let ItemEntityName = "Item"
    }
}
