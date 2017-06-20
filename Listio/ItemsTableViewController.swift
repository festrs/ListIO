//
//  ItemsTableViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-06-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import DATAStack

class ItemsTableViewController: UITableViewController {

    public var dataProvider: MainDataProviderProtocol?
    public var dataStack: DATAStack?
    var presentedAlert: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        dataProvider = MainDataProvider()
        dataProvider?.dataStack = dataStack
        dataProvider?.tableView = tableView
        tableView.dataSource = dataProvider
        tableView.delegate = dataProvider
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try dataProvider?.performFetch()
        } catch Errors.CoreDataError(let msg) {
            showAlert(Alerts.ErroTitle, message: msg)
        } catch let error as NSError {
            showAlert(Alerts.ErroTitle, message: error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func showAlert(_ title: String, message: String) {
        guard !presentedAlert else {
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: { (_: UIAlertAction!) in
            self.presentedAlert = false
        }))
        self.present(alert, animated: true, completion: {
            self.presentedAlert = true
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender is UITableViewCell,
            let vc = segue.destination as? NewItemViewController {
            vc.new = false
        }
    }
}

extension ItemsTableViewController: FPHandlesMOC {
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        dataStack = incomingDataStack
    }
}
