//
//  FirstViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-06-03.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import DATAStack

class FirstViewController: CoreDataTableViewController, FPHandlesMOC {
    
    @IBOutlet weak var tableView: UITableView!
    var textField:UITextField!
    private var dataStack:DATAStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configTableView(){
        self.coreDataTableView = self.tableView
        let request = NSFetchRequest(entityName: "Group")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.dataStack.mainContext, sectionNameKeyPath: nil, cacheName: "rootCache")
        self.performFetch()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
//    let range = NSMakeRange(0, self.tableView.numberOfSections)
//    let sections = NSIndexSet(indexesInRange: range)
//    self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
    
    func addNewGroup(){
        let groupObj = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: self.dataStack.mainContext) as! Group
        groupObj.name = self.textField.text!
        do {
            try self.dataStack.mainContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        self.performFetch()
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
    
    //MARK: - TableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath)
        let group = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! Group
   
        cell.textLabel!.text = group.name
        cell.detailTextLabel?.text = "R$\(group.totalValue!)"

        return cell
    }
    
    func colorForIndex(index: NSInteger) -> UIColor {
        
        let itemCount:Int = 5
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
            vc.groupObj = self.fetchedResultsController?.objectAtIndexPath(indexPath!) as! Group
        }
    }
}
