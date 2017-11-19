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
import Photos
import Fabric
import Crashlytics

protocol NewItemDelegate: class {
    func didFinishUpdating(item: Item)
}

class NewItemViewController: UITableViewController {

    @IBOutlet weak var alertDaysLabel: UILabel!
    @IBOutlet weak var sliderCell: UITableViewCell!
    @IBOutlet weak var addDateCellSwitch: UISwitch!
    @IBOutlet weak var datePickerCellRef: DatePickerCell!
    @IBOutlet weak var txfItemUn: UITextField!
    @IBOutlet weak var txfItemName: UITextField!
    @IBOutlet weak var txfItemPrice: CurrencyField!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var daySlider: UISlider!

    var item: Item?
    var alertProvider: AlertProvider? = AlertProvider()
    weak var newItemDelegate: NewItemDelegate?

    var viewModel: NewItemViewModelProtocol! {
        didSet {
            setBindings()
            if item != nil {
                loadFields()
            }
        }
    }

    enum TxfType: Int {
        case name = 10, price = 20, unidade = 30
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NewItemViewModel(item: item)

        //defaults
        datePickerCellRef.date = viewModel.itemAlertDate!
        alertDaysLabel.text = viewModel.itemDaysToExpire

        configFields()
        // extension
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if item != nil {
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        }
    }

    func configFields() {
        if item == nil {
            let closeButton = UIBarButtonItem(image: UIImage(named: "close"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(closeAction(_:)))
            navigationItem.leftBarButtonItem  = closeButton
            title = "Novo Item"
        } else {
            title = "Item"
        }

        productImageView.layer.borderColor = UIColor.white.cgColor
        productImageView.layer.borderWidth = 2.0
        productImageView.layer.cornerRadius = productImageView.frame.size.height/2.0
        productImageView.layer.masksToBounds = true

        datePickerCellRef.delegate = self
        datePickerCellRef.leftLabel.text = "Data de validade"
        datePickerCellRef.dateStyle = .short

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    func loadFields() {
        daySlider.setValue(Float(viewModel.alertDays), animated: true)
        alertDaysLabel.text = viewModel.itemDaysToExpire

        let expireAlert = viewModel.hasExpireAlert
        datePickerCellRef.isHidden = !expireAlert
        sliderCell.isHidden = !expireAlert
        addDateCellSwitch.setOn(expireAlert, animated: true)
        datePickerCellRef.date = viewModel.itemAlertDate!

        txfItemName.text = viewModel.itemName
        txfItemUn.text = viewModel.itemUnit.description
        txfItemPrice.text = viewModel.itemPriceString

        if let date = viewModel.itemAlertDate {
            datePickerCellRef.date = date
        } else {
            datePickerCellRef.date = Date()
        }

        loadItemImage(viewModel.itemImageUrl)
    }

    func loadItemImage(_ url: String?) {
        guard let imageUrl = url else {
            return
        }

        var image: UIImage? = nil
        let placeHolder = #imageLiteral(resourceName: "noimage")
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            image = Item.getImage(localUrl: imageUrl)
        }

        if image == nil {
            let url = URL(string: imageUrl)
            productImageView.kf.setImage(with: url,
                                         placeholder: placeHolder,
                                         options: nil,
                                         progressBlock: nil,
                                         completionHandler: nil)
        } else {
            productImageView.image = image
        }
    }

    // MARK: - Bidings
    func setBindings() {
        viewModel.alertDaysDidChange = { [weak self] viewModel in
            guard let strongSelf = self else {
                return
            }
            strongSelf.alertDaysLabel.text = viewModel.itemDaysToExpire
        }
    }

    // MARK: - Actions
    @IBAction func txfHaveChanged(_ sender: UITextField) {
        if let typeTxf = TxfType(rawValue: sender.tag) {
            switch typeTxf {
            case .name:
                viewModel.changeItemName(sender.text)
                break
            case .price:
                viewModel.changeItemPrice(to: txfItemPrice.doubleValue)
                break
            case .unidade:
                if let value = Int(sender.text!) {
                    viewModel.changeItemUnit(to: value)
                }
                break
            }
        }
    }

    @IBAction func alertDaysChanged(_ sender: UISlider) {
        viewModel.changeAlertDays(to: Int(sender.value))
    }

    @IBAction func addDatePickerCell(_ sender: Any) {
        guard (alertProvider?.registerForLocalNotification(on: UIApplication.shared))! else {
            return
        }
        viewModel.changeActiveStateOfAlert(addDateCellSwitch.isOn)

        datePickerCellRef.isHidden = !addDateCellSwitch.isOn
        sliderCell.isHidden = !addDateCellSwitch.isOn

        Answers.logContentView(withName: "Edit Item",
                               contentType: "Add Alarm",
                               contentId: "switch-0",
                               customAttributes: [:])
    }

    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func choosePhoto(_ sender: Any) {
        let croppingParameters = CroppingParameters(isEnabled: true,
                                                    allowResizing: true,
                                                    allowMoving: true)

        let cameraViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParameters) { [weak self] image, asset in
            guard let stronSelf = self else { return }
            if image != nil {
                DatabaseManager.write(DatabaseManager.realm, writeClosure: {
                    stronSelf.productImageView.image = image
                    stronSelf.viewModel.changeItemImage(with: image!, and: asset?.localIdentifier)
                })
            }
            stronSelf.dismiss(animated: true, completion: nil)
        }
        navigationController?.present(cameraViewController, animated: true, completion: nil)
    }

    @IBAction func doneAction(_ sender: Any) {
        do {
            let newItem = try viewModel.saveItem()
            if let delegate = newItemDelegate {
                delegate.didFinishUpdating(item: newItem)
            }
            dismiss(animated: true, completion: nil)
        } catch NewItemError.itemNameBlank {
            let alert = UIAlertController(title: "Atenção!",
                                          message: "Para criar um produto o campo Nome deve ser preenchido.",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: UIAlertActionStyle.default,
                                          handler: nil ))
            present(alert, animated: true, completion: nil)
        } catch {

        }
    }

    // MARK: - TableView Functions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DatePickerCell {
            cell.selectedInTableView(tableView)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 && addDateCellSwitch.isOn {
            return datePickerCellRef.datePickerHeight()
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}

extension NewItemViewController: DatePickerCellDelegate {
    func datePickerCell(_ cell: DatePickerCell, didPickDate date: Date?) {
        viewModel.changeAlertDate(date)
    }
}
