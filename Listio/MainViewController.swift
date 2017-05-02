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
import DATAStack

class MainViewController: UIViewController, FPHandlesMOC {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var qteItemsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    fileprivate var dataStack:DATAStack!
    public var dataProvider: MainDataProviderProtocol?
    
    struct Keys {
        static let EntityName = "ItemList"
        static let SortDescriptorField = "countDocument"
        static let IdentifierCell = "documentCell"
        static let HeaderSection1Identifier = "headerSection1"
        static let HeightForFooterView = 61.0
        static let SegueAddListItem = "toAddListItem"
    }
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let DataDownloaderError = "Error while data downloading."
        static let DefaultTitle = "Ops"
        static let DefaultMessage = "There was a problem, please try again."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init objects
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        assert(dataProvider != nil, "dataProvider is not allowed to be nil at this point")
        
        dataProvider?.tableView = tableView
        tableView.dataSource = dataProvider
        dataProvider?.dataStack = dataStack
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try dataProvider?.performFetch()
            tableView.reloadData()
            try loadTotal()
        } catch Errors.CoreDataError(let msg) {
            showAlert("Error", message: msg)
        } catch {
            showAlert("Error", message: "Generic ")
        }
    }
    @IBAction func createNewList(_ sender: Any) {
        performSegue(withIdentifier: Keys.SegueAddListItem, sender: sender)
    }
  
    
    @IBAction func editTableView(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    func loadTotal() throws {
        let qtdeItems = try dataProvider?.getCountItems()
        qteItemsLabel.text = "Qtde Produtos: \(String(describing: qtdeItems))"
        let total = try NSNumber(value: (dataProvider?.calcMediumCost())!)
        totalLabel.text = "Valor Total: \(total.toMaskReais()!)"
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - HUD
    fileprivate func showLoadingHUD() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Carregando"
    }
    
    fileprivate func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
    }
    
    //MARK: - FPHandlesMOC Delegate
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        self.dataStack = incomingDataStack
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FPHandlesMOC {
            vc.receiveDataStack(self.dataStack)
        }
        if let vc = segue.destination as? AddListItemViewController {
            vc.dataProvider = AddListItemDataProvider()
        }
    }
}


