//
//  NewItemViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-06-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit

class NewItemViewController: UIViewController {

    var new: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        if new {
            title = "Novo Item"
        } else {
            title = "Item"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
