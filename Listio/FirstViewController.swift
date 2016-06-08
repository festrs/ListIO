//
//  FirstViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-06-03.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import DATAStack

class FirstViewController: UIViewController, FPHandlesMOC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var textField:UITextField!
    private var dataStack:DATAStack!
    var array = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.configTableView()
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    let range = NSMakeRange(0, self.tableView.numberOfSections)
//    let sections = NSIndexSet(indexesInRange: range)
//    self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
    
    func loadData(){
        let fetchRequest = NSFetchRequest(entityName: "Group")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do{
            let results = try self.dataStack.mainContext.executeFetchRequest(fetchRequest) as! [Group]

            array = results
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        self.tableView?.reloadData()
    }
    
    func addNewGroup(){
        let groupObj = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: self.dataStack.mainContext) as! Group
        groupObj.name = self.textField.text!
        do {
            try self.dataStack.mainContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        loadData()
        
    }
    
    //MARK: - UIALert handle
    @IBAction func addNewGroup(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Alert Title", message: "Alert Message", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            self.addNewGroup()
        }))
        self.presentViewController(alert, animated: true, completion: {
            //print("completion block")
            //
        })
    }
    
    func configurationTextField(textField: UITextField!)
    {
        if textField != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField.text = "Hello world"
        }
    }
    
    func handleCancel(alertView: UIAlertAction!)
    {
        self.textField.resignFirstResponder()
    }
    
    //MARK: - TableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath)
        let group = array[indexPath.row] as Group
   
        cell.textLabel!.text = group.name

        return cell
    }
    
    func colorForIndex(index: NSInteger) -> UIColor {
        
        let itemCount:Int = array.count
        let a = Float(index)
        let b = Float(itemCount)
        let val = (a/b) * 0.5
        
        let sender:UIColor = UIColor(red: CGFloat(0.25), green: CGFloat(val), blue: CGFloat(0.9), alpha: CGFloat(1.0))
        
        return sender
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
        if let vc = segue.destinationViewController as? MainViewController,
            let cell = sender as? UITableViewCell {
            let indexPath = self.tableView.indexPathForCell(cell)
            vc.groupObj = array[(indexPath?.row)!]
        }
    }
}
