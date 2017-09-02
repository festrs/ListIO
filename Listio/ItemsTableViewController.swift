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
    let notificationName = NSNotification.Name(rawValue: Constants.newProductAddedNotificationKey)

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
        reloadData()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData),
                                               name: notificationName,
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }

    func reloadData() {
        do {
            try dataProvider?.performFetch()
        } catch Errors.CoreDataError(let msg) {
            showAlert(Alerts.ErroTitle, message: msg)
        } catch let error as NSError {
            showAlert(Alerts.ErroTitle, message: error.localizedDescription)
        }
    }

    func showAlert(_ title: String, message: String) {
        guard !presentedAlert else {
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default,
                                      handler: { [weak self] (_: UIAlertAction!) in
            guard let strongSelf = self else { return }
            strongSelf.presentedAlert = false
        }))
        self.present(alert, animated: true, completion: {
            self.presentedAlert = true
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell,
            let vc = segue.destination as? NewItemViewController,
            let index = tableView.indexPath(for: cell),
            let item = dataProvider?.items[index.row] {
            vc.new = false
            vc.product = item
        }
    }
}

extension ItemsTableViewController: FPHandlesMOC {
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        dataStack = incomingDataStack
    }
}
