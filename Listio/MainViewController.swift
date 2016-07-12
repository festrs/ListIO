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
import GoogleMaterialIconFont

class MainViewController: CoreDataTableViewController, QRCodeReaderViewControllerDelegate, FPHandlesMOC {
    

    @IBOutlet weak var qtdeItemsLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    lazy var reader: QRCodeReaderViewController = {
        let builder = QRCodeViewControllerBuilder { builder in
            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeEAN13Code])
            builder.showTorchButton = true
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    private var dataStack:DATAStack!
    var groupObj:Group!
    var core:InteligenceCore!
    var coreDataHandler:CoreDataHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init objects
        coreDataHandler = CoreDataHandler(mainContext: self.dataStack.mainContext)
        core = InteligenceCore(coreDataHandler:coreDataHandler)
        
        self.title = groupObj.name!

        self.loadTotal()
        
        addLabel.text = String.materialIcon(.Add)
        //addLabel.textColor = UIColor.randomColor()
        addLabel.font = UIFont.materialIconOfSize(51)
        
        coreDataHandler.getAllItemsFromGroup(self.groupObj)
        
        self.configTableView()
        
        let qtdeItems = self.fetchedResultsController?.fetchedObjects?.count
        self.qtdeItemsLabel.text = "Qtde Produtos: \(qtdeItems!)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadTotal(){
        totalLabel.text = "Valor Total: \(groupObj.totalValue!.toMaskReais()!)"
    }
    
    func configTableView(){
        self.coreDataTableView = self.tableView
        let request = NSFetchRequest(entityName: "ItemList")
        let countDocumentSort = NSSortDescriptor(key: "countDocument", ascending: false)
        request.sortDescriptors = [countDocumentSort]
        request.predicate = NSPredicate(format: "group.name = %@",groupObj.name!)
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.dataStack.mainContext, sectionNameKeyPath: nil, cacheName: "rootCache")
        self.performFetch()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    // MARK: - HUD
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    //MARK: - FPHandlesMOC Delegate
    func receiveDataStack(incomingDataStack: DATAStack) {
        self.dataStack = incomingDataStack
    }
    
    // MARK: - Actions
    @IBAction func addButtonAction(sender: AnyObject) {
        if QRCodeReader.supportsMetadataObjectTypes() {
            reader.modalPresentationStyle = .FormSheet
            reader.delegate               = self
            
            presentViewController(reader, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - QRCodeReader Delegate Methods
    func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.dismissViewControllerAnimated(true, completion: {
            self.showLoadingHUD()
            guard result.metadataType == AVMetadataObjectTypeQRCode else { return }
            
            let url = urlBase + endPointAllProducts
            let headers = [
                "x-access-token": JWT.encode(.HS256("SupperDupperSecret")) { builder in
                    builder.expiration = NSDate().dateByAddingTimeInterval(30*60)
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
                self.coreDataHandler.savingData(responseJSON, groupObj: self.groupObj)
                //calculate list
                self.core.calculate(self.groupObj)
                // reload data
                self.performFetch()
                self.loadTotal()
                self.hideLoadingHUD()
            })
        })
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UITableView Delegate
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
        let mapType = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! ItemList
        
        let cell = tableView.dequeueReusableCellWithIdentifier("documentCell") as! DocumentUiTableViewCell
        
        cell.nameLabel.text = mapType.name!
        cell.unLabel.text = "Qtde \(mapType.qtde!.description)"
        cell.valueLabel.text = mapType.vlUnit?.maskToCurrency()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DocumentUiTableViewCell
        
        cell.bigFlatSwitch.setSelected(!cell.bigFlatSwitch.selected, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //objects.removeAtIndex(indexPath.row)
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? FPHandlesMOC{
            vc.receiveDataStack(self.dataStack)
        }
        if let vc = segue.destinationViewController as? DetailViewController,
        let cell = sender as? UITableViewCell {
            vc.groupObj = self.groupObj
            let indexPath = self.tableView.indexPathForCell(cell)
            vc.itemName = (self.fetchedResultsController?.objectAtIndexPath(indexPath!) as! ItemList).name
        }
    }
    
    
}
