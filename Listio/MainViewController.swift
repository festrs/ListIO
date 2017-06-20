//
//  MainViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-05-31.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import DATAStack
import Floaty
import SVProgressHUD
import BarcodeScanner

class MainViewController: UIViewController, FPHandlesMOC {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var qteItemsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatyButtonView: Floaty!
    fileprivate var dataStack: DATAStack!
    public var dataProvider: MainDataProviderProtocol = MainDataProvider()
    public var communicator: APICommunicatorProtocol = APICommunicator()
    public let barCodeScannerController = BarcodeScannerController()
    var presentedAlert: Bool = false

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
        }
        builder.cancelButtonTitle = Keys.CancelButtonTittle
        return QRCodeReaderViewController(builder: builder)
    }()

    struct Keys {
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        configBarcodeScanner()
        configFloatyAddButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            //try loadTotal()
        } catch Errors.CoreDataError(let msg) {
            showAlert(Alerts.ErroTitle, message: msg)
        } catch let error as NSError {
            showAlert(Alerts.ErroTitle, message: error.localizedDescription)
        }
    }

    func configBarcodeScanner() {
        barCodeScannerController.isOneTimeSearch = true
        barCodeScannerController.codeDelegate = self
        barCodeScannerController.errorDelegate = self
        barCodeScannerController.dismissalDelegate = self
    }

    func configFloatyAddButton() {
        floatyButtonView.addItem("Via código de barras", icon: UIImage(named: "Barcode-29")) { _ in
            self.present(self.barCodeScannerController, animated: true, completion: nil)
        }
        floatyButtonView.addItem("Via QR Code", icon: UIImage(named: "QR Code-29")) { _ in
            self.present(self.readerVC, animated: true, completion: nil )
        }
        floatyButtonView.addItem("Novo item", icon: UIImage(named: "Add-29")) { (item) in
            self.performSegue(withIdentifier: Keys.SegueToNewItemIdentifier, sender: item)
        }
        floatyButtonView.addItem("Nova lista", icon: UIImage(named: "To Do-29")) { (item) in
            self.performSegue(withIdentifier: Keys.SegueAddListItem, sender: item)
        }
    }

//    func loadTotal() throws {
//        let qtdeItems = dataProvider?.getCountItems()
//        qteItemsLabel.text = "Qtde Produtos: \(qtdeItems!)"
//        let total = NSNumber(value: (dataProvider?.calcMediumCost())!)
//        totalLabel.text = total.toMaskReais()!
//    }

    func showAlert(_ title: String, message: String) {
        guard !presentedAlert else {
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: { (_: UIAlertAction!) in
            self.presentedAlert = false
        }))
        self.present(alert, animated: true, completion: {
            self.presentedAlert = true
        })
    }

    func createNewList() {
        let refreshAlert = UIAlertController(title: Keys.SucessAlertTitle,
                                           message: Keys.SucessAlertMSG,
                                    preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: Keys.SegueAddListItem, sender: nil)
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
    }

    // MARK: - FPHandlesMOC Delegate
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        self.dataStack = incomingDataStack
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FPHandlesMOC {
            vc.receiveDataStack(self.dataStack)
        }
        if let vc = segue.destination as? AddListItemViewController {
            vc.dataProvider = AddListItemDataProvider()
            vc.new = false
        }
    }
}

extension MainViewController : QRCodeReaderViewControllerDelegate {
    // MARK: - QRCodeReaderViewController Delegate Methods
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        SVProgressHUD.setStatus(Keys.ProgressHUDStatus)
        SVProgressHUD.show()
        reader.stopScanning()

        guard result.metadataType == AVMetadataObjectTypeQRCode else { return }
        communicator.getReceipt(linkUrl: result.value) { [weak self] (error, responseJSON) in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                strongSelf.showAlert(Alerts.ErroTitle, message: "O serviço ainda não chegou ao seu estado.")
                return
            }
            do {
                try Receipt.createReceipt(strongSelf.dataStack.mainContext, json: responseJSON!)
                strongSelf.createNewList()
            } catch Errors.DoubleReceiptWithSameID() {
                strongSelf.showAlert(Alerts.ErroTitle, message: Alerts.ErrorDoubleReceiptWithSameID)
            } catch let error as NSError {
                strongSelf.showAlert(Alerts.ErroTitle, message: error.localizedDescription)
            }
        }
        dismiss(animated: true, completion: nil )
    }
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
}

extension MainViewController: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {

    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {

        communicator.getProduct(code: code) { [weak self] (error, responseJSON) in
            guard let strongSelf = self else {
                controller.resetWithError(message: "Ocorreu um erro, tente novamente mais tarde.")
                return
            }
            guard error == nil else {
                controller.resetWithError(message: "Ocorreu um erro, tente novamente mais tarde.")
                return
            }

            guard let records = responseJSON?["records"] as? [AnyObject],
                let firstRecord = records.first,
                let fields = firstRecord["fields"] as? [String: AnyObject],
                let itemName = fields["gtin_nm"] as? String,
                let itemUrl = fields["gtin_img"] as? String,
                let un = fields["pkg_unit"] as? Int,
                let cod = fields["gtin_cd"] as? String else {
                controller.resetWithError(message: "Ocorreu um erro, tente novamente mais tarde.")
                return
            }

            let item = Item(withName: itemName,
                            withImageUrl: itemUrl,
                            intoMainContext: strongSelf.dataStack.mainContext)

            item.un = "\(un)"
            item.remoteID = cod

            controller.reset(animated: true)
            controller.dismiss(animated: true, completion: {
                strongSelf.createNewList()
            })
        }
    }

    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }

    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
