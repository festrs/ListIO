//
//  CoreDataTableViewController.swift
//  IBoleto-Project
//
//  Created by Felipe Dias Pereira on 2016-02-27.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UIViewController, CoreDataTableViewControllerProtocol {
    var coreDataTableView:UITableView!
    var _fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?{
        get {
            return _fetchedResultsController
        }
        set (newValue){
            _fetchedResultsController = newValue
            if self.coreDataTableView != nil {
                self.performFetch()
            }
        }
    }
    
    func performFetch(){
        do{
            try self.fetchedResultsController!.performFetch()
            coreDataTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView,
        cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
            let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell")
            return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.fetchedResultsController!.sections != nil){
            return (self.fetchedResultsController!.sections?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController!.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController!.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        
        return nil
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.fetchedResultsController!.section(forSectionIndexTitle: title, at: index)
    }
    
    //MARK - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.coreDataTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type){
        case .insert:
            self.coreDataTableView.insertSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.fade)
            break
        case .delete:
            self.coreDataTableView.deleteSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.fade)
            break
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: AnyObject, atIndexPath indexPath: IndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            self.coreDataTableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
            break
        case .delete:
            self.coreDataTableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
            break
        case .update:
            self.coreDataTableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
            break
        case .move:
            self.coreDataTableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
            self.coreDataTableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.coreDataTableView.endUpdates()
    }
}
