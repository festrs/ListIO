//
//  QRCodeViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-27.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import DATAStack
import SVProgressHUD

class QRCodeViewController: UIViewController {
    
    public var communicator: APICommunicatorProtocol = APICommunicator()
    var dataStack: DATAStack!
    var presented: Bool = false
    var presentedAlert: Bool = false
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
        }
        builder.cancelButtonTitle = Keys.CancelButtonTittle
        return QRCodeReaderViewController(builder: builder)
    }()
    
    struct Keys {
        static let ToCreateListIdentifier = "toCreateList"
        static let SucessAlertTitle = "Adicionado com sucesso"
        static let SucessAlertMSG = "Você deseja criar uma nova lista?"
        static let ProgressHUDStatus = "Adicionando ..."
        static let CancelButtonTittle = "Cancelar"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentQRCodeReader()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func presentQRCodeReader() {
        if !presented {
            self.parent?.present(self.readerVC, animated: true, completion: {
                self.presented = true
            })
        }
    }
    func showAlert(_ title: String, message: String) {
        guard !presentedAlert else {
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: { (action: UIAlertAction!) in
            self.presentedAlert = false
            self.presented = false
            self.presentQRCodeReader()
        }))
        self.present(alert, animated: true, completion: {
            self.presentedAlert = true
        })
    }
    func createNewList() {
        let refreshAlert = UIAlertController(title: Keys.SucessAlertTitle, message: Keys.SucessAlertMSG, preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: Keys.ToCreateListIdentifier, sender: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            self.dismissWithTabBar()
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func dismissWithTabBar() {
        tabBarController?.selectedIndex = 0
        dismiss(animated: true, completion: {
            self.presented = false
        })
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FPHandlesMOC {
            vc.receiveDataStack(self.dataStack)
        }
        if let vc = segue.destination as? AddListItemViewController {
            vc.new = true
            vc.dataProvider = AddListItemDataProvider()
            vc.communicatorDelegate = self
        }
    }
}

extension QRCodeViewController : AddListCommunicator {
    func backFromAddList() {
        dismissWithTabBar()
    }
}

extension QRCodeViewController : FPHandlesMOC {
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        dataStack = incomingDataStack
    }
}

extension QRCodeViewController : QRCodeReaderViewControllerDelegate {
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
        dismiss(animated: true, completion: {
            self.presented = false
        })
    }
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismissWithTabBar()
    }
}
