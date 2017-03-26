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

class MainViewController: CoreDataTableViewController, QRCodeReaderViewControllerDelegate, FPHandlesMOC {
    
    @IBOutlet weak var qtdeItemsLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    fileprivate var dataStack:DATAStack!
    var core:InteligenceCore!
    var coreDataHandler:CoreDataHandler!
    var downloader:Downloader?
    var hud:MBProgressHUD!
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
        core = InteligenceCore(coreDataHandler: coreDataHandler)
        downloader = Downloader(core: core, withDataHandler: coreDataHandler)
        hud = MBProgressHUD(view: self.view)
        
        self.loadTotal()
        self.configTableView()
        
        let qtdeItems = self.fetchedResultsController?.fetchedObjects?.count
        self.qtdeItemsLabel.text = "Qtde Produtos: \(qtdeItems!)"
    }
    
    func loadTotal(){
        //totalLabel.text = "Valor Total: \(groupObj.totalValue!.toMaskReais()!)"
    }
    
    func configTableView(){
        self.coreDataTableView = self.tableView
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Keys.EntityName)
        let countDocumentSort = NSSortDescriptor(key: Keys.SortDescriptorField, ascending: false)
        request.sortDescriptors = [countDocumentSort]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.dataStack.mainContext, sectionNameKeyPath: nil, cacheName: "rootCache")
        self.performFetch()
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
            self.performFetch()
            self.loadTotal()
            
        })
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITableView Delegate
    override func tableView(_ tableView: UITableView,
                            cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        let mapType = self.fetchedResultsController?.object(at: indexPath) as! ItemList
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Keys.IdentifierCell) as! DocumentUiTableViewCell
        
        cell.nameLabel.text = mapType.name!
        cell.unLabel.text = "Qtde \(mapType.qtde!.description)"
        cell.valueLabel.text = mapType.vlUnit?.maskToCurrency()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DocumentUiTableViewCell
        
        cell.bigFlatSwitch.setSelected(!cell.bigFlatSwitch.isSelected, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            //objects.removeAtIndex(indexPath.row)
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FPHandlesMOC{
            vc.receiveDataStack(self.dataStack)
        }
    }
    
    
}
