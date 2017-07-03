//
//  NewItemViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-06-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit

class NewItemViewController: UITableViewController {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    var new: Bool = true
    var product: Item!

    override func viewDidLoad() {
        super.viewDidLoad()
        if new {
            title = "Novo Item"
        } else {
            title = "Item"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !new {
            navigationItem.rightBarButtonItem = nil
            productName.text = product.descricao
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func choosePhoto(_ sender: Any) {


    }

    @IBAction func doneAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension NewItemViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
