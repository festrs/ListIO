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
import MBProgressHUD
import Sync
import DATAStack

class MainViewController: UIViewController, FPHandlesMOC {
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var qteItemsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    fileprivate var dataStack:DATAStack!
    public var dataProvider: MainDataProviderProtocol?
    public var communicator: APICommunicatorProtocol = APICommunicator()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    struct Keys {
        static let EntityName = "ItemList"
        static let SortDescriptorField = "countDocument"
        static let IdentifierCell = "documentCell"
        static let HeaderSection1Identifier = "headerSection1"
        static let HeightForFooterView = 61.0
    }
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let DataDownloaderError = "Error while data downloading."
        static let DefaultTitle = "Ops"
        static let DefaultMessage = "There was a problem, please try again."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init objects
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        assert(dataProvider != nil, "dataProvider is not allowed to be nil at this point")
        
        tableView.setEditing(true, animated: true)
        dataProvider?.tableView = tableView
        tableView.dataSource = dataProvider
        do {
            try dataProvider?.fetch()
            try loadTotal()
        } catch {
            
        }
    }
    func loadTotal() throws {
        let qtdeItems = try dataProvider?.getCountItems()
        qteItemsLabel.text = "Qtde Produtos: \(String(describing: qtdeItems))"
        let total = try NSNumber(value: (dataProvider?.calcMediumCost())!)
        totalLabel.text = "Valor Total: \(total.toMaskReais()!)"
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - HUD
    fileprivate func showLoadingHUD() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Carregando"
    }
    
    fileprivate func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
    }
    
    //MARK: - FPHandlesMOC Delegate
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        self.dataStack = incomingDataStack
    }
    
    // MARK: - Actions
    @IBAction func addButtonAction(_ sender: AnyObject) {
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Please select", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Novo", style: .default)
        { _ in
            print("Save")
            
            self.readerVC.delegate = self
            // Presents the readerVC as modal form sheet
            self.readerVC.modalPresentationStyle = .formSheet
            self.present(self.readerVC, animated: true, completion: nil)
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Item", style: .default)
        { _ in
            
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FPHandlesMOC{
            vc.receiveDataStack(self.dataStack)
        }
    }
}

extension MainViewController : QRCodeReaderViewControllerDelegate {
    // MARK: - QRCodeReaderViewController Delegate Methods
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        self.showLoadingHUD()
        guard result.metadataType == AVMetadataObjectTypeQRCode else { return }
        
        communicator.getReceipt(linkUrl: result.value) { (error, responseJSON) in
            self.hideLoadingHUD()
            guard error == nil else {
                return
            }
            do {
                try self.dataProvider?.addReceipt(responseJSON!)
            } catch Errors.DoubleReceiptWithSameID() {
                print("mesmo")
            } catch {
                
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
}
