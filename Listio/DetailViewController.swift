//
//  DetailViewController.swift
//  NFC-E-Project
//
//  Created by Felipe Dias Pereira on 2016-02-24.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData
import DATAStack

class DetailViewController: CoreDataTableViewController,FPHandlesMOC {
    //MARK: - Variables
    @IBOutlet weak var itemsTableView: UITableView!
    var itemName:String!
    var groupObj:Group!
    var dataStack:DATAStack!
    
    //MARK: - App life
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setUp()
        self.title = "Histórico"
        // not show empty tableviewcell
        self.itemsTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.itemsTableView.alwaysBounceVertical = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - FPHandlesMOC Delegate
    func receiveDataStack(incomingDataStack: DATAStack) {
        self.dataStack = incomingDataStack
    }
    
    //MARK: - Setup Labels
    func setUp(){
        self.coreDataTableView = self.itemsTableView
        
        let request = NSFetchRequest(entityName: "Item")
        var expressionDescriptions = [AnyObject]()
        
        expressionDescriptions.append("descricao")
        
        //Count qtde collum on data base
        var expressionDescription = NSExpressionDescription()
        expressionDescription.name = "QtdeCount"
        expressionDescription.expression = NSExpression(format: "@sum.qtde")
        expressionDescription.expressionResultType = .Integer32AttributeType
        expressionDescriptions.append(expressionDescription)
        
        //Get createdAt collum on documents
        expressionDescription = NSExpressionDescription()
        expressionDescription.name = "createdAt"
        expressionDescription.expression = NSExpression(format: "document.createdAt")
        expressionDescription.expressionResultType = .DateAttributeType
        expressionDescriptions.append(expressionDescription)
        
        //GroupBy for descricao and document.creadteAt
        request.propertiesToGroupBy = ["descricao","document.createdAt"]
        request.resultType = .DictionaryResultType
        request.sortDescriptors = [NSSortDescriptor(key: "descricao", ascending: true)]
        request.propertiesToFetch = expressionDescriptions
        
        request.predicate = NSPredicate(format: "document.groupType.name = %@ AND descricao = %@",self.groupObj.name!,self.itemName)
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.dataStack.mainContext, sectionNameKeyPath: nil, cacheName: "rootCache")
        self.performFetch()
        self.itemsTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    //MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! DetailTableViewCell
        
        let item = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! [String:AnyObject]

        cell.nameLabel?.text = item["descricao"] as? String
        
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        let date = item["createdAt"] as! NSDate
        let mes = "\(formatter.stringFromNumber((date.getComponent(.Month))!)!)/\((date.getComponent(.Year))!)"
        
        cell.dateLabel?.text = mes
        
        cell.qtdeLabel.text = (item["QtdeCount"] as? Int)?.description
        
        return cell
    }
    
}
