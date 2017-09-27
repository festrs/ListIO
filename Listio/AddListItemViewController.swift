//
//  AddListItemViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-24.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit

class AddListItemViewController: UIViewController {

    var dataProvider: AddListItemDataProviderProtocol?
    @IBOutlet weak var editTableView: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    var new: Bool = false
    var presentedAlert: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        assert(dataProvider != nil, "dataProvider is not allowed to be nil at this point")

        dataProvider?.tableView = tableView
        tableView.dataSource = dataProvider
        tableView.delegate = dataProvider
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try dataProvider?.performFetch()
        } catch {

        }
    }

    @IBAction func editTableViewAction(_ sender: Any) {
        if (dataProvider?.countItems())! > 0 {
            tableView.setEditing(!tableView.isEditing, animated: true)
        }
    }

    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

    @IBAction func unselectAllItems(_ sender: Any) {
        dataProvider?.unselectAll()

    }
    @IBAction func selectAllItems(_ sender: Any) {
        dataProvider?.selectAll()
    }

}
