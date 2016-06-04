//
//  FirstViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-06-03.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import DATAStack

class FirstViewController: UIViewController,FPHandlesMOC,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var dataStack:DATAStack!
    var array = [MapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.configTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func createShopList(sender: AnyObject) {
        
        let core = InteligenceCore()
        
        array = core.calculate(self.dataStack.mainContext)!
        self.tableView.reloadData()
    }
    
    
    //MARK: - Table view Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mapItem = array[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell")
        
        cell!.textLabel!.text = mapItem.name
        cell?.detailTextLabel?.text = mapItem.vlTotal.description
        
        return cell!
    }
    
    //MARK: - FPHandlesMOC Delegate
    func receiveDataStack(incomingDataStack: DATAStack) {
        self.dataStack = incomingDataStack
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? FPHandlesMOC{
            vc.receiveDataStack(self.dataStack)
        }
    }
}
