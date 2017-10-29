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
import Fabric
import Crashlytics

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
    var isCreated: Bool = false
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

        currentValueOfDays = Int(daySlider.value)
        alertDaysLabel.text = "Aviso \(currentValueOfDays!) dias antes do vencimento."

        productImageView.layer.borderColor = UIColor.white.cgColor
        productImageView.layer.borderWidth = 2.0
        productImageView.layer.cornerRadius = productImageView.frame.size.height/2.0
        productImageView.layer.masksToBounds = true

        datePickerCellRef.delegate = self
        datePickerCellRef.leftLabel.text = "Data de validade"
        datePickerCellRef.dateStyle = .short
        datePickerCellRef.date = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        // extension
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !new {
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard isCreated == true else { return }
        if addDateCellSwitch.isOn {
            addLocalNotification()
        } else {
            alertProvider?.removeLocalNotificationByIdentifier(withID: remoteID)
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

        Answers.logContentView(withName: "Edit Item",
                               contentType: "Add Alarm",
                               contentId: "switch-0",
                               customAttributes: [:])
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
        isCreated = false
        dismiss(animated: true, completion: nil)
    }

    @IBAction func choosePhoto(_ sender: Any) {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            guard let stronSelf = self else { return }

            if image != nil {
                try! stronSelf.realm.write {
                    stronSelf.productImageView.image = image
                    stronSelf.assetLocalIdentifier = asset?.localIdentifier
                }
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
                if let qtde = Int(txfItemUn.text!) {
                    product.qtde = qtde
                }
                product.alert = addDateCellSwitch.isOn
                product.alertDate = datePickerCellRef.date
                product.alertDays = currentValueOfDays!
                product.imgUrl = assetLocalIdentifier
            }
            isCreated = true
            dismiss(animated: true, completion: nil)
        } else {
            if txfItemName.text != nil && txfItemName.text != "" {
                let item = Item()
                item.remoteID = remoteID
                item.descricao = txfItemName.text
                item.vlUnit = txfItemPrice.decimalNumber.doubleValue
                if let qtde = Int(txfItemUn.text!) {
                    item.qtde = qtde
                }
                item.present = true
                item.alertDays = currentValueOfDays ?? 0
                let alertDate = Calendar.current.date(byAdding: .day,
                                                     value: -(item.alertDays),
                                                     to: datePickerCellRef.date)
                item.alertDate = alertDate
                item.alert = addDateCellSwitch.isOn
                item.imgUrl = assetLocalIdentifier
                try! realm.write {
                    realm.add(item)
                }
                isCreated = true
                dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Atenção!",
                                              message: "Para criar um produto o campo Nome deve ser preenchido.",
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
