//
//  AddListItemViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-24.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import DATAStack

class AddListItemViewController: UIViewController, FPHandlesMOC {

    var dataProvider:AddListItemDataProviderProtocol?
    fileprivate var dataStack: DATAStack!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    weak var communicatorDelegate: AddListCommunicator!
    var new: Bool = false
    var presentedAlert: Bool = false

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
        } catch {

        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func backAction(_ sender: Any) {
        dismissWithTabBar()
    }

    func dismissWithTabBar() {
        tabBarController?.selectedIndex = 0
        dismiss(animated: true, completion: nil)
        if new {
            assert(communicatorDelegate != nil, "communicatorDelegate is not allowed to be nil at this point")
            communicatorDelegate.backFromAddList()
        }
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

    func receiveDataStack(_ incomingDataStack: DATAStack) {
        dataStack = incomingDataStack
    }

    @IBAction func unselectAllItems(_ sender: Any) {
        dataProvider?.unselectAll()

    }
    @IBAction func selectAllItems(_ sender: Any) {
        dataProvider?.selectAll()
    }

}
