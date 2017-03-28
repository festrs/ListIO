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
    
    @IBOutlet weak var qtdeItemsLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    fileprivate var dataStack:DATAStack!
    var coreDataHandler: CoreDataHandler!
    var downloader: Downloader?
    var hud: MBProgressHUD!
    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
    })
    
    struct Keys {
        static let EntityName = "ItemList"
        static let SortDescriptorField = "countDocument"
        static let IdentifierCell = "documentCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init objects
        coreDataHandler = CoreDataHandler(mainContext: self.dataStack.mainContext)
        downloader = Downloader(withDataHandler: coreDataHandler)
        hud = MBProgressHUD(view: self.view)
        
        self.configTableView()
        self.loadTotal()
    }
    
    func loadTotal() {
        //        let qtdeItems = fetchedResultsController?.fetchedObjects?.count
        //        qtdeItemsLabel.text = "Qtde Produtos: \(qtdeItems!)"
        let total = 0
        totalLabel.text = "Valor Total: \(total)"
    }
    
    func configTableView() {
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
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
        // Retrieve the QRCode content
        // By using the delegate pattern
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
        
        downloader?.downloadData(result: result, { (error) in
            self.hideLoadingHUD()
            
            guard error == nil else {
                return
            }
            // reload data
            self.tableView.reloadData()
            self.loadTotal()
        })
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataHandler.itemList.count
    }
}

extension MainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   cellForRowAt
        
        indexPath: IndexPath) -> UITableViewCell {
        let viewItem = coreDataHandler.itemList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Keys.IdentifierCell) as! DocumentUiTableViewCell
        
        cell.nameLabel.text = viewItem.name
        cell.unLabel.text = "Qtde \(viewItem.qtde.description)"
        cell.valueLabel.text = viewItem.vlUnit.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //objects.removeAtIndex(indexPath.row)
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
