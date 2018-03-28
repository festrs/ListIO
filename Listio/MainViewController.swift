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
import Floaty
import SVProgressHUD
import Alamofire
import Fabric
import Crashlytics

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatyButtonView: Floaty!
    public var communicator: APICommunicatorProtocol = APICommunicator()
    var presentedAlert: Bool = false
    let notificationName = NSNotification.Name(rawValue: Constants.newProductAddedNotificationKey)
    public let dataProvider: MainDataProviderProtocol? = MainDataProvider()
    let searchController = UISearchController(searchResultsController:  nil)

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObject.ObjectType.qr.rawValue,
                                                           AVMetadataObject.ObjectType.ean13.rawValue,
                                                           AVMetadataObject.ObjectType.ean8.rawValue],
                                     captureDevicePosition: .back)
        }
        builder.cancelButtonTitle = Constants.MainVC.CancelButtonTittle

        return QRCodeReaderViewController(builder: builder)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configFloatyAddButton()
        configTableView()
        configSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        floatyButtonView.open()
        floatyButtonView.close()
        reloadData()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    func configSearchController() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barStyle = .black

        if let txfSearchField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            txfSearchField.backgroundColor = .lightGray
        }

        definesPresentationContext = true

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationController?.navigationBar.prefersLargeTitles = true

            let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
        } else {

        }
    }

    func configTableView() {
        dataProvider?.tableView = tableView
        tableView.dataSource = dataProvider
        tableView.delegate = dataProvider
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    @objc func reloadData() {
        do {
            try dataProvider?.performFetch()
        } catch Errors.CoreDataError(let msg) {
            showAlert(Alerts.ErroTitle, message: msg)
        } catch let error as NSError {
            showAlert(Alerts.ErroTitle, message: error.localizedDescription)
        }
    }

    func configFloatyAddButton() {
        floatyButtonView.addItem("Via código de barras",
                                 icon: UIImage(named: "Barcode-29")) { [weak self] _ in
                                    guard let strongSelf = self else { return }
                                    strongSelf.showReader()

                                    Answers.logContentView(withName: "Main View",
                                                                   contentType: "Add Buttons",
                                                                   contentId: "button-0",
                                                                   customAttributes: [:])
        }
        floatyButtonView.addItem("Via QR Code", icon: UIImage(named: "QR Code-29")) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.showReader()
            Answers.logContentView(withName: "Main View",
                                           contentType: "Add Buttons",
                                           contentId: "button-1",
                                           customAttributes: [:])
        }
        floatyButtonView.addItem("Novo item", icon: UIImage(named: "Add-29")) { [weak self] (item) in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: Constants.MainVC.SegueToNewItemIdentifier, sender: item)

            Answers.logContentView(withName: "Main View",
                                           contentType: "Add Buttons",
                                           contentId: "button-2",
                                           customAttributes: [:])
        }
    }

    func showReader() {
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate = self
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
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

    @IBAction func createNewlist(_ sender: Any) {
        Answers.logContentView(withName: "Main View",
                               contentType: "New List",
                               contentId: "button-0",
                               customAttributes: [:])
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddListItemViewController {
            vc.dataProvider = AddListItemDataProvider()
            vc.new = false
        }

        if let cell = sender as? UITableViewCell,
            let vc = segue.destination as? ItemViewController,
            let index = tableView.indexPath(for: cell),
            let item = dataProvider?.items[index.row] {
            vc.item = item
        }
    }
}

extension MainViewController : QRCodeReaderViewControllerDelegate {
    // MARK: - QRCodeReaderViewController Delegate Methods
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        SVProgressHUD.setStatus(Constants.MainVC.ProgressHUDStatus)
        SVProgressHUD.show()
        reader.stopScanning()

        if result.metadataType == AVMetadataObject.ObjectType.ean13.rawValue {
            createNewItemFromBarCode(code: result.value)
        } else if result.metadataType == AVMetadataObject.ObjectType.qr.rawValue {
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

            if let unwrapedJson = responseJSON,
                let receipt = Receipt(JSON: unwrapedJson) {
                DatabaseManager.write(DatabaseManager.realm, writeClosure: {
                    DatabaseManager.realm.add(receipt, update: true)
                })
            }
            strongSelf.createNewList()
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
                let itemUrl = fields["gtin_img"] as? String else {
                    //strongSelf.showAlert(Alerts.ErroTitle, message: "Produto não encontrado.")
                    strongSelf.performSegue(withIdentifier: Constants.MainVC.SegueToNewItemIdentifier, sender: nil)
                    return
            }

            let item = Item()
            item.remoteID = UUID().uuidString
            item.descricao = itemName
            item.present = true
            item.imgUrl = itemUrl
            DatabaseManager.write(DatabaseManager.realm, writeClosure: {
                DatabaseManager.realm.add(item)
            })

            NotificationCenter.default.post(name:
                NSNotification.Name(rawValue: Constants.newProductAddedNotificationKey),
                                            object: nil)
        }
    }
}
