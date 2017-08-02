//
//  NewItemViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-06-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import ALCameraViewController
import DatePickerCell
import DATAStack

class NewItemViewController: UITableViewController, FPHandlesMOC {

    @IBOutlet weak var addDateCellSwitch: UISwitch!
    @IBOutlet weak var datePickerCellRef: DatePickerCell!
    @IBOutlet weak var txfItemUn: UITextField!
    @IBOutlet weak var txfItemName: UITextField!
    @IBOutlet weak var txfItemPrice: CurrencyField!
    @IBOutlet weak var productImageView: UIImageView!
    fileprivate var dataStack: DATAStack!
    var new: Bool = true
    var product: Item!
    var numberMarkAux: String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if new {
            title = "Novo Item"
        } else {
            title = "Item"
        }
        // extension
        hideKeyboardWhenTappedAround()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !new {
            txfItemName.text = product.descricao
            txfItemPrice.text = product.vlUnit?.toMaskReais()
            txfItemUn.text = product.qtde?.description
        }
    }

    func receiveDataStack(_ incomingDataStack: DATAStack) {
        dataStack = incomingDataStack
    }

    @IBAction func addDatePickerCell(_ sender: Any) {
        datePickerCellRef.isHidden = !addDateCellSwitch.isOn
    }

    @IBAction func choosePhoto(_ sender: Any) {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            self?.productImageView.image = image
            self?.product.imgUrl = asset?.localIdentifier
            self?.dismiss(animated: true, completion: nil)
        }
        navigationController?.present(cameraViewController, animated: true, completion: nil)
    }

    @IBAction func doneAction(_ sender: Any) {
        if !new {
            product.descricao = txfItemName.text
            product.vlUnit = txfItemPrice.decimalNumber
            product.qtde = txfItemUn.text?.decimal.number
            navigationController?.popViewController(animated: true)
        } else {
            let newItem = Item(withName: txfItemName.text!, withImageUrl: "", intoMainContext: dataStack.mainContext)
            newItem.vlUnit = txfItemPrice.decimalNumber
            newItem.qtde = txfItemUn.text?.decimal.number
            newItem.remoteID = UUID().uuidString
            newItem.present = 1
            dismiss(animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DatePickerCell {
            cell.selectedInTableView(tableView)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 && addDateCellSwitch.isOn {
            return datePickerCellRef.datePickerHeight()
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
