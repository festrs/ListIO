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

class MainViewController: UIViewController, QRCodeReaderViewControllerDelegate, FPHandlesMOC {
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var dataStack:DATAStack!
    public var dataProvider: DataProviderProtocol?
    public var communicator: APICommunicatorProtocol = APICommunicator()
    var hud: MBProgressHUD!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init objects
        hud = MBProgressHUD(view: self.view)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        assert(dataProvider != nil, "dataProvider is not allowed to be nil at this point")
        
        tableView.setEditing(true, animated: true)
        dataProvider?.tableView = tableView
        tableView.dataSource = dataProvider
        tableView.delegate = self
        do {
            try dataProvider?.fetch()
        } catch {
            
        }
    }
    
    // MARK: - HUD
    fileprivate func showLoadingHUD() {
        hud.show(animated: true)
    }
    
    fileprivate func hideLoadingHUD() {
        hud.hide(animated: true)
    }
    
    //MARK: - FPHandlesMOC Delegate
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        self.dataStack = incomingDataStack
    }
    
    // MARK: - Actions
    @IBAction func addButtonAction(_ sender: AnyObject) {
        readerVC.delegate = self
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FPHandlesMOC{
            vc.receiveDataStack(self.dataStack)
        }
    }
}

extension MainViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Keys.HeaderSection1Identifier) as? SectionFooterView
            
            do {
                let qtdeItems = try dataProvider?.getCountItems()
                cell?.qteItemsLabel.text = "Qtde Produtos: \(String(describing: qtdeItems))"
                let total = try NSNumber(value: (dataProvider?.calcMediumCost())!)
                cell?.totalPriceLabel.text = "Valor Total: \(total.toMaskReais()!)"
            } catch {
                
            }
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(Keys.HeightForFooterView)
    }
}
