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
import ObjectMapper

class MainViewController: UIViewController, QRCodeReaderViewControllerDelegate, FPHandlesMOC {
    
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
    var array = [MapItem]()
    var key:String!
    let core = InteligenceCore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configTableView(){
        array = core.calculate(self.dataStack.mainContext, documentGroup: self.groupObj)!
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func saveDocumentToGroup(){
        let fetchRequest = NSFetchRequest(entityName: "Document")
        fetchRequest.predicate = NSPredicate(format: "remoteID = %@",key)
        do{
            let result = try self.dataStack.mainContext.executeFetchRequest(fetchRequest).first as! Document
            groupObj.mutableSetValueForKey("documents").addObject(result)
            result.groupType = groupObj
            
            array = core.calculate(self.dataStack.mainContext, documentGroup: self.groupObj)!
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        do {
            try self.dataStack.mainContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
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
    
    func saveingData(json:[String: AnyObject]){
        
        guard verifyNewObject(json["id"] as! String) == false else{
            hideLoadingHUD()
            return
        }
        
        let docObj = NSEntityDescription.insertNewObjectForEntityForName("Document", inManagedObjectContext: self.dataStack.mainContext) as! Document
        
        docObj.hyp_fillWithDictionary(json)
        
        for item in json["items"] as! [AnyObject] {
            let itemObj = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: self.dataStack.mainContext) as! Item
            if let itemT = item as? [String:AnyObject]{
                itemObj.hyp_fillWithDictionary(itemT)
            }
            itemObj.document = docObj
            docObj.mutableSetValueForKey("items").addObject(itemObj)
        }
        
        groupObj.mutableSetValueForKey("documents").addObject(docObj)
        docObj.groupType = groupObj
        
        do {
            try self.dataStack.mainContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        array = core.calculate(self.dataStack.mainContext, documentGroup: self.groupObj)!
        saveObj()
        self.tableView.reloadData()
        hideLoadingHUD()
    }
    
    func saveObj(){
        
        func inner(){
            groupObj.mutableSetValueForKey("itemList").removeAllObjects()
            for item in array{
                let listObj = NSEntityDescription.insertNewObjectForEntityForName("ItemList", inManagedObjectContext: self.dataStack.mainContext) as! ItemList
                listObj.hyp_dictionary()
                listObj.hyp_fillWithDictionary(item.toJson())
                groupObj.mutableSetValueForKey("itemList").addObject(listObj)
            }
            do {
                try self.dataStack.mainContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        
        //dispatch_async(dispatch_get_main_queue(), inner)
    }
    
    func verifyNewObject(key:String) -> Bool{
        let fetchRequest = NSFetchRequest(entityName: "Document")
        fetchRequest.predicate = NSPredicate(format: "remoteID = %@",key)
        do{
            let result = try self.dataStack.mainContext.executeFetchRequest(fetchRequest)
            if result.count > 0{
                return true
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
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
                    self.saveingData(responseJSON)
                    
                })
        })
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
        let mapType = array[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("documentCell")
        
        cell!.textLabel!.text = mapType.name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
