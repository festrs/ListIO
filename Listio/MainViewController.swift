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
import DATAStack

class MainViewController: UIViewController, FPHandlesMOC {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var qteItemsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    fileprivate var dataStack:DATAStack!
    public var dataProvider: MainDataProviderProtocol?
    var presentedAlert:Bool = false
    
    struct Keys {
        static let EntityName = "ItemList"
        static let SortDescriptorField = "countDocument"
        static let IdentifierCell = "documentCell"
        static let HeaderSection1Identifier = "headerSection1"
        static let HeightForFooterView = 61.0
        static let SegueAddListItem = "toAddListItem"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        assert(dataProvider != nil, "dataProvider is not allowed to be nil at this point")
        
        dataProvider?.tableView = tableView
        tableView.dataSource = dataProvider
        tableView.delegate = dataProvider
        dataProvider?.dataStack = dataStack
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try dataProvider?.performFetch()
            tableView.reloadData()
            try loadTotal()
        } catch Errors.CoreDataError(let msg) {
            showAlert(Alerts.ErroTitle, message: msg)
        } catch let error as NSError {
            showAlert(Alerts.ErroTitle, message: error.localizedDescription)
        }
    }
    @IBAction func createNewList(_ sender: Any) {
        performSegue(withIdentifier: Keys.SegueAddListItem, sender: sender)
    }
    
    @IBAction func editTableView(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    func loadTotal() throws {
        let qtdeItems = dataProvider?.getCountItems()
        qteItemsLabel.text = "Qtde Produtos: \(qtdeItems!)"
        let total = try NSNumber(value: (dataProvider?.calcMediumCost())!)
        totalLabel.text = total.toMaskReais()!
    }
    
    func showAlert(_ title: String, message: String) {
        guard !presentedAlert else {
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: { (action: UIAlertAction!) in
            self.presentedAlert = false
        }))
        self.present(alert, animated: true, completion: {
            self.presentedAlert = true
        })
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
            vc.new = false
        }
    }
}


