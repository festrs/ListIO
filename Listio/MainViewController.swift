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

// MARK: URL Base
let urlBase:String = "http://nfc-e-server.herokuapp.com"

// MARK: EndPoints
let endPointAllProducts:String = "/api/v1/qrdata"

let monthsName: [Int:String] = [1:"JAN",2:"FEV",3:"MAR",4:"ABR",5:"MAIO",6:"JUN",7:"JUL",8:"AGO",9:"SET",10:"OUT",11:"NOV",12:"DEZ"]

class MainViewController: CoreDataTableViewController, QRCodeReaderViewControllerDelegate, FPHandlesMOC {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var reader: QRCodeReaderViewController = {
        let builder = QRCodeViewControllerBuilder { builder in
            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeEAN13Code])
            builder.showTorchButton = true
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    private var dataStack:DATAStack!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configTableView(){
        let fetchRequest = NSFetchRequest(entityName: "Document")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let fecthController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataStack.mainContext, sectionNameKeyPath: nil , cacheName: nil)
        self.fetchedResultsController = fecthController
        self.coreDataTableView = self.tableView
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.performFetch()
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
    
    // MARK: - QRCodeReader Delegate Methods
    func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.dismissViewControllerAnimated(true, completion: {
            if result.metadataType == AVMetadataObjectTypeQRCode{
                let url = urlBase + endPointAllProducts
                let headers = [
                    "x-access-token": JWT.encode(.HS256("SupperDupperSecret")) { builder in
                        builder.expiration = NSDate().dateByAddingTimeInterval(30*60)
                    }
                ]
                let parameters = [
                    "linkurl": result.value
                ]
                Alamofire.request(.POST, url, parameters: parameters, headers: headers)
                    .responseJSON { response in
                        switch response.result {
                        case .Success:
                            var json = [String:AnyObject]()
                            do {
                                json = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]
                            } catch let error as NSError {
                                print(error)
                            }
                            let key = json["id"] as! String
                            let predicate = NSPredicate(format: "remoteID = %@",key)
                            Sync.changes([json], inEntityNamed: "Document", predicate: predicate, dataStack: self.dataStack, completion: { (error) -> Void in
                                if error != nil {
                                    print(error)
                                    self.hideLoadingHUD();
                                }else{
                                    self.performFetch()
                                }
                            })
                        case .Failure(let error):
                            print(error)
                            self.hideLoadingHUD();
                        }
                }
            }
        })
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
        let document = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! Document
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DocumentCell")
        let payments = NSKeyedUnarchiver.unarchiveObjectWithData(document.payments!) as! NSDictionary
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        cell!.detailTextLabel!.text = dateFormatter.stringFromDate(document.createdAt!)
        
        let total:String = (payments["vl_total"] as! String).stringByReplacingOccurrencesOfString(".", withString: ",")
        cell!.textLabel!.text = "R$\(total)"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let document = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! Document
        self.performSegueWithIdentifier("toDetailDocument", sender: document)
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailDocument"{
            if segue.destinationViewController.isKindOfClass(DetailViewController){
                let vc = segue.destinationViewController as! DetailViewController
                if sender!.isKindOfClass(Document){
                    let doc = sender as! Document
                    vc.document = doc
                }
            }
        }
     }
 
    
}
