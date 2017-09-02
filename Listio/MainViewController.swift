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
import Alamofire

class MainViewController: UIViewController, FPHandlesMOC {

    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var floatyButtonView: Floaty!
    fileprivate var dataStack: DATAStack!
    public var communicator: APICommunicatorProtocol = APICommunicator()
    var presentedAlert: Bool = false
    let notificationName = NSNotification.Name(rawValue: Constants.newProductAddedNotificationKey)

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode,
                                                           AVMetadataObjectTypeEAN13Code,
                                                           AVMetadataObjectTypeEAN8Code], captureDevicePosition: .back)
        }
        builder.cancelButtonTitle = Constants.MainVC.CancelButtonTittle

        return QRCodeReaderViewController(builder: builder)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configFloatyAddButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        floatyButtonView.open()
        floatyButtonView.close()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    func configFloatyAddButton() {
        floatyButtonView.addItem("Via código de barras",
                                 icon: UIImage(named: "Barcode-29")) { [weak self] _ in
                                    guard let strongSelf = self else { return }
                                    strongSelf.showReader()
        }
        floatyButtonView.addItem("Via QR Code", icon: UIImage(named: "QR Code-29")) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.showReader()
        }
        floatyButtonView.addItem("Novo item", icon: UIImage(named: "Add-29")) { [weak self] (item) in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: Constants.MainVC.SegueToNewItemIdentifier, sender: item)
        }
    }

    func showReader() {
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate = self
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { [weak self] response in
            guard let strongSelf = self else { return }
            if response {
                strongSelf.present(strongSelf.readerVC, animated: true, completion: nil )
            } else {
                let alert = UIAlertController(title: "Atenção!",
                                              message: "Habilite o acesso da câmera nos ajustes de privacidade.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .cancel, handler: nil ))
                alert.addAction(UIAlertAction(title: "Ajustes", style: .default, handler: { (_: UIAlertAction!) in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }))
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
    }

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
        let refreshAlert = UIAlertController(title: Constants.MainVC.SucessAlertTitle,
                                             message: Constants.MainVC.SucessAlertMSG,
                                             preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default,
                                             handler: { [weak self] (_: UIAlertAction!) in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: Constants.MainVC.SegueAddListItem, sender: nil)
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil ))
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
        SVProgressHUD.setStatus(Constants.MainVC.ProgressHUDStatus)
        SVProgressHUD.show()
        reader.stopScanning()

        if result.metadataType == AVMetadataObjectTypeEAN13Code {
            createNewItemFromBarCode(code: result.value)
        } else if result.metadataType == AVMetadataObjectTypeQRCode {
            createNewListFromQRCode(code: result.value)
        }
        dismiss(animated: true, completion: nil )
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }

    func createNewListFromQRCode(code: String) {
        communicator.getReceipt(linkUrl: code) { [weak self] (error, responseJSON) in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else {
                return
            }

            if let errorCode = error as? AFError {
                switch errorCode {
                case .responseValidationFailed(let reason):
                    switch reason {
                    case .unacceptableStatusCode(let code):
                        if code == 501 {
                            strongSelf.showAlert(Alerts.ErroTitle,
                                                 message: "Opss!! parece que o serviço ainda não chegou ao seu estado.")
                        } else if code == 404 {
                            strongSelf.showAlert(Alerts.ErroTitle,
                                                 message: "Opss!! Nota emitida em contingência. Aguarde 24 horas!")
                        } else {
                            strongSelf.showAlert(Alerts.ErroTitle,
                                                 message: "Opss!! Ocorreu um erro, tente novamente.")
                        }
                        return
                    default:
                        strongSelf.showAlert(Alerts.ErroTitle, message: "Opss!! Ocorreu um erro, tente novamente.")
                        return
                    }
                default:
                    strongSelf.showAlert(Alerts.ErroTitle, message: "Opss!! Ocorreu um erro, tente novamente.")
                    return
                }
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
    }

    func createNewItemFromBarCode(code: String) {
        communicator.getProduct(code: code) { [weak self] (error, responseJSON) in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                strongSelf.showAlert(Alerts.ErroTitle, message: "Ocorreu um erro, tente novamente mais tarde.")
                return
            }

            guard let records = responseJSON?["records"] as? [AnyObject],
                let firstRecord = records.first,
                let fields = firstRecord["fields"] as? [String: AnyObject],
                let itemName = fields["gtin_nm"] as? String,
                let itemUrl = fields["gtin_img"] as? String,
                let cod = fields["gtin_cd"] as? String else {
                    //strongSelf.showAlert(Alerts.ErroTitle, message: "Produto não encontrado.")
                    strongSelf.performSegue(withIdentifier: Constants.MainVC.SegueToNewItemIdentifier, sender: nil)
                    return
            }
            _ = Item(withName: itemName,
                     withImageUrl: itemUrl,
                     withVlUnit: 0,
                     withQTDE: 0,
                     withRemoteID: cod,
                     withDate: Date(),
                     withAlertPresent: false,
                     withAlertDays: Constants.MainVC.AlertDaysDefault,
                     intoMainContext: strongSelf.dataStack.mainContext)
            NotificationCenter.default.post(name:
                NSNotification.Name(rawValue: Constants.newProductAddedNotificationKey),
                                            object: nil)
        }
    }
}
