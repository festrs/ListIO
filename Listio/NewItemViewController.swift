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
import Photos

class NewItemViewController: UITableViewController, FPHandlesMOC {

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
    fileprivate var dataStack: DATAStack!
    var new: Bool = true
    var product: Item!
    var assetLocalIdentifier: String? = ""
    var alertProvider: AlertProvider?
    var currentValueOfDays: Int?
    var remoteID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if new {
            title = "Novo Item"
            remoteID = UUID().uuidString
        } else {
            title = "Item"
            loadProductData()
        }
        datePickerCellRef.delegate = self
        currentValueOfDays = Int(daySlider.value)
        alertDaysLabel.text = "Aviso \(currentValueOfDays!) dias antes do vencimento."
        // extension
        hideKeyboardWhenTappedAround()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        productImageView.layer.cornerRadius = productImageView.frame.size.height/2.0
        productImageView.layer.masksToBounds = true
        datePickerCellRef.leftLabel.text = "Data de validade"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !new {
            txfItemName.text = product.descricao
            txfItemPrice.text = product.vlUnit?.toMaskReais()
            txfItemUn.text = product.qtde?.description
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        }
    }

    func loadProductData() {
        let alert = product.alert?.boolValue ?? false
        datePickerCellRef.isHidden = !alert
        sliderCell.isHidden = !alert
        datePickerCellRef.date = product.alertDate ?? Date()
        addDateCellSwitch.setOn(alert, animated: true)
        let placeHolder = UIImage(named: "noimage")
        let image = getImage(localUrl: product?.imgUrl ?? "")

        if image == nil {
            let url = URL(string: product?.imgUrl ?? "")
            productImageView.kf.setImage(with: url,
                                         placeholder: placeHolder,
                                         options: nil,
                                         progressBlock: nil,
                                         completionHandler: nil)
        } else {
            productImageView.image = image
        }
    }

    func getImage(localUrl: String) -> UIImage? {

        let assetUrl = URL(string: "assets-library://asset/asset.JPG?id=\(localUrl)")
        let asset = PHAsset.fetchAssets(withALAssetURLs: [assetUrl!], options: nil)

        guard let result = asset.firstObject else {
            return nil
        }
        var assetImage: UIImage?
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: result,
                                              targetSize: UIScreen.main.bounds.size,
                                              contentMode: PHImageContentMode.aspectFill,
                                              options: options) { image, _ in
                                                assetImage = image
        }
        return assetImage
    }
    
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        dataStack = incomingDataStack
    }

    @IBAction func alertDaysChanged(_ sender: UISlider) {
        currentValueOfDays = Int(sender.value)
        alertDaysLabel.text = "Aviso \(currentValueOfDays!) dias antes do vencimento."
    }

    @IBAction func addDatePickerCell(_ sender: Any) {
        if alertProvider == nil {
            alertProvider = AlertProvider()
        }
        guard (alertProvider?.registerForLocalNotification(on: UIApplication.shared))! else {
            return
        }
        datePickerCellRef.isHidden = !addDateCellSwitch.isOn
        sliderCell.isHidden = !addDateCellSwitch.isOn
        let presentAlert = NSNumber(booleanLiteral: addDateCellSwitch.isOn)
        guard product != nil else { return }
        product.alert = presentAlert
        if addDateCellSwitch.isOn {
            addLocalNotification()
        }
    }

    func addLocalNotification() {
        guard alertProvider != nil else {
            return
        }
        let dictionary = [
            Constants.notificationIdentifierKey: remoteID ?? "" ,
            Constants.notificationProductNameKey: txfItemName.text!,
            Constants.notificationProductDateKey: datePickerCellRef.date.getDateStringShort()
        ]

        let minusDaysAgo = Calendar.current.date(byAdding: .day,
                                                 value: -(currentValueOfDays!),
                                                 to: datePickerCellRef.date)

        alertProvider?.dispatchlocalNotification(with: "Lista Rápida",
                                                 body: "O produto \(txfItemName.text!) ira vencer em \(datePickerCellRef.date.getDateStringShort())!",
            userInfo: dictionary,
            at: minusDaysAgo!)
    }

    @IBAction func choosePhoto(_ sender: Any) {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            guard let stronSelf = self else { return }
            if image != nil {
                stronSelf.productImageView.image = image
                stronSelf.product.imgUrl = asset?.localIdentifier
                stronSelf.assetLocalIdentifier = asset?.localIdentifier
            }
            stronSelf.dismiss(animated: true, completion: nil)
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
            var alertMsg: String? = nil
            if !(txfItemName.text?.isEmpty)! {
                _ = Item(withName: txfItemName.text!,
                         withImageUrl: assetLocalIdentifier!,
                         withVlUnit: txfItemPrice.decimalNumber,
                         withQTDE: (txfItemUn.text?.decimal.number)!,
                         withRemoteID: remoteID!,
                         withDate: datePickerCellRef.date,
                         withAlertPresent: addDateCellSwitch.isOn,
                         intoMainContext: dataStack.mainContext)
                dismiss(animated: true, completion: nil)
            } else if (txfItemName.text?.isEmpty)! {
                alertMsg = "Para criar um produto o campo Nome deve ser preenchido."
            }
            if let msg = alertMsg {
                let alert = UIAlertController(title: "Atenção!",
                                              message: msg,
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok",
                                              style: UIAlertActionStyle.default,
                                              handler: nil ))
                alert.addAction(UIAlertAction(title: "Cancelar",
                                              style: UIAlertActionStyle.default,
                                              handler: { [unowned self] (_: UIAlertAction!) in
                                                self.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
            }
        }
    }

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
        addLocalNotification()
        guard product != nil else { return }
        product.alertDate = date
    }
}
