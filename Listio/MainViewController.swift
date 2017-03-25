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
import JWT
import Alamofire
import MBProgressHUD
import Sync
import DATAStack
import Sync

class MainViewController: CoreDataTableViewController, QRCodeReaderViewControllerDelegate, FPHandlesMOC {
    
    @IBOutlet weak var qtdeItemsLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var dataStack:DATAStack!
    var core:InteligenceCore!
    var coreDataHandler:CoreDataHandler!
    
    lazy var reader: QRCodeReaderViewController = {
        let builder = QRCodeViewControllerBuilder { builder in
            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeEAN13Code])
            builder.showTorchButton = true
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init objects
        coreDataHandler = CoreDataHandler(mainContext: self.dataStack.mainContext)
        core = InteligenceCore(coreDataHandler:coreDataHandler)

        self.loadTotal()
        
        addLabel.text = String.materialIcon(.add)
        //addLabel.textColor = UIColor.randomColor()
        addLabel.font = UIFont.materialIconOfSize(51)
        
        self.configTableView()
        
        let qtdeItems = self.fetchedResultsController?.fetchedObjects?.count
        self.qtdeItemsLabel.text = "Qtde Produtos: \(qtdeItems!)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadTotal(){
        //totalLabel.text = "Valor Total: \(groupObj.totalValue!.toMaskReais()!)"
    }
    
    func configTableView(){
        self.coreDataTableView = self.tableView
        let request = NSFetchRequest(entityName: "ItemList")
        let countDocumentSort = NSSortDescriptor(key: "countDocument", ascending: false)
        request.sortDescriptors = [countDocumentSort]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.dataStack.mainContext, sectionNameKeyPath: nil, cacheName: "rootCache")
        self.performFetch()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    // MARK: - HUD
    fileprivate func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = "Loading..."
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
        if QRCodeReader.supportsMetadataObjectTypes() {
            reader.modalPresentationStyle = .formSheet
            reader.delegate               = self
            present(reader, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - QRCodeReader Delegate Methods
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.dismiss(animated: true, completion: {
            self.showLoadingHUD()
            guard result.metadataType == AVMetadataObjectTypeQRCode else { return }
            
            let url = urlBase + endPointAllProducts
            let headers = [
                "x-access-token": JWT.encode(.hs256("SupperDupperSecret")) { builder in
                    builder.expiration = Date().addingTimeInterval(30*60)
                }
            ]
            let parameters = [
                "linkurl": result.value
                ] as [String : AnyObject]
            
            Alamofire.request(.POST, url, parameters: parameters, headers: headers).responseJSON(completionHandler: { response in
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(response.result.error)")
                    self.hideLoadingHUD()
                    return
                }
                guard let responseJSON = response.result.value as? [String: AnyObject] else {
                    print("Invalid tag information received from service")
                    self.hideLoadingHUD()
                    return
                }
                // add new item
                if self.coreDataHandler.savingData(responseJSON) {
                    //case document are add calculate the list
                    self.core.calculate()
                }
                // reload data
                self.performFetch()
                self.loadTotal()
                self.hideLoadingHUD()
            })
        })
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITableView Delegate
    override func tableView(_ tableView: UITableView,
                            cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        let mapType = self.fetchedResultsController?.object(at: indexPath) as! ItemList
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell") as! DocumentUiTableViewCell
        
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
