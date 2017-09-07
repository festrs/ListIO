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
import RealmSwift

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
    var new: Bool = true
    var product: Item!
    var assetLocalIdentifier: String? = ""
    var alertProvider: AlertProvider? = AlertProvider()
    var currentValueOfDays: Int?
    var remoteID: String?
    // swiftlint:disable force_try
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        if new {
            let closeButton = UIBarButtonItem(image: UIImage(named: "close"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(closeAction(_:)))
            navigationItem.leftBarButtonItem  = closeButton
            title = "Novo Item"
            remoteID = UUID().uuidString
            productImageView.image = UIImage(named: "noimage")
        } else {
            title = "Item"
            remoteID = product.remoteID
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
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if addDateCellSwitch.isOn {
            addLocalNotification()
        }
    }

    func loadProductData() {
        let alert = product.alert
        datePickerCellRef.isHidden = !alert
        sliderCell.isHidden = !alert

        if let date = product.alertDate {
            datePickerCellRef.date = date
        } else {
            datePickerCellRef.date = Date()
        }
        txfItemName.text = product.descricao
        txfItemPrice.text = NSNumber(value: product.vlUnit).maskToCurrency()
        txfItemUn.text = product.qtde.description
        addDateCellSwitch.setOn(alert, animated: true)
        daySlider.setValue(Float(product.alertDays), animated: true)

        let placeHolder = UIImage(named: "noimage")
        let status = PHPhotoLibrary.authorizationStatus()
        var image: UIImage? = nil
        if status == PHAuthorizationStatus.authorized {
            image = getImage(localUrl: product.imgUrl ?? "")
        }

        if image == nil {
            let url = URL(string: product.imgUrl ?? "")
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

    @IBAction func alertDaysChanged(_ sender: UISlider) {
        currentValueOfDays = Int(sender.value)
        alertDaysLabel.text = "Aviso \(currentValueOfDays!) dias antes do vencimento."
    }

    @IBAction func addDatePickerCell(_ sender: Any) {
        guard (alertProvider?.registerForLocalNotification(on: UIApplication.shared))! else {
            return
        }
        datePickerCellRef.isHidden = !addDateCellSwitch.isOn
        sliderCell.isHidden = !addDateCellSwitch.isOn
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

        let subtractDays = -(currentValueOfDays!)

        let fireDate = Calendar.current.date(byAdding: .day,
                                             value: subtractDays,
                                             to: datePickerCellRef.date)

        alertProvider?.dispatchlocalNotification(with: "Lista Rápida",
                        body: "O produto \(txfItemName.text!) ira vencer em \(datePickerCellRef.date.getDateStringShort())!",
            userInfo: dictionary,
            at: fireDate!)
    }

    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func choosePhoto(_ sender: Any) {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            guard let stronSelf = self, image != nil else { return }

            try! stronSelf.realm.write {
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
            try! realm.write {
                product.descricao = txfItemName.text
                product.vlUnit = Double(txfItemPrice.decimalNumber)
                product.qtde = Int(txfItemUn.text!)!
                product.alert = addDateCellSwitch.isOn
                product.alertDate = datePickerCellRef.date
                product.alertDays = currentValueOfDays!
            }
            navigationController?.popViewController(animated: true)
        } else {
            var alertMsg: String? = nil
            if txfItemName.text?.isEmpty != nil {
                let item = Item()
                item.remoteID = remoteID
                item.descricao = txfItemName.text
                item.vlUnit = txfItemPrice.decimalNumber.doubleValue
                item.qtde = Int(txfItemUn.text!)!
                item.present = true
                item.alertDays = currentValueOfDays!
                item.alertDate = datePickerCellRef.date
                item.alert = addDateCellSwitch.isOn
                try! realm.write {
                    realm.add(item)
                }

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
    func datePickerCell(_ cell: DatePickerCell, didPickDate date: Date?) { }
}
