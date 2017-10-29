//
//  ItemViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-09-16.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class ItemViewController: UIViewController {

    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var lblDateDays: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblItemUnit: UILabel!
    @IBOutlet weak var lblItemPrice: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var lblItemName: UILabel!
    var product: Item!
    var alertProvider: AlertProvider? = AlertProvider()
    // swiftlint:disable force_try
    let realm = try! Realm()
    lazy var defaultDate = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        configImageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLabels()
        loadItemImage()
    }

    func loadLabels() {
        lblItemName.text = product.descricao
        lblItemUnit.text = "Quantidade (\(product.qtde.description))"
        lblItemPrice.text = NSNumber(value: product.vlUnit).maskToCurrency()
        lblDateDays.text = "Aviso \(product.alertDays) dias antes do vencimento."
        dateSwitch.setOn(product.alert, animated: true)

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short

        if let alertDate = product.alertDate {
            lblDate.text = dateFormatter.string(from: alertDate)
        } else {
            lblDate.text = dateFormatter.string(from: defaultDate)
        }
    }

    func configImageView() {
        itemImageView.layer.cornerRadius = itemImageView.frame.size.width / 2
        itemImageView.layer.masksToBounds = true
    }

    func loadItemImage() {
        var image: UIImage? = nil
        let placeHolder = UIImage(named: "noimage")
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            image = getImage(localUrl: product.imgUrl ?? "")
        }

        if image == nil {
            let url = URL(string: product.imgUrl ?? "")
            itemImageView.kf.setImage(with: url,
                                         placeholder: placeHolder,
                                         options: nil,
                                         progressBlock: nil,
                                         completionHandler: nil)
        } else {
            itemImageView.image = image
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

    @IBAction func changeActiveStateAlert(_ sender: Any) {
        if dateSwitch.isOn {
            let alertDate = product.alertDate ?? defaultDate
            let dictionary = [
                Constants.notificationIdentifierKey: product.remoteID ?? "" ,
                Constants.notificationProductNameKey: product.descricao ?? "",
                Constants.notificationProductDateKey: alertDate.getDateStringShort()
            ]

            let subtractDays = -(product.alertDays)

            let fireDate = Calendar.current.date(byAdding: .day,
                                                 value: subtractDays,
                                                 to: alertDate)

            guard (alertProvider?.registerForLocalNotification(on: UIApplication.shared))! else {
                return
            }

            alertProvider?.dispatchlocalNotification(with: "Lista Rápida",
                                                     body: "O produto \(product.descricao!) ira vencer em \(alertDate.getDateStringShort())!",
                userInfo: dictionary,
                at: fireDate!)
        } else {
            alertProvider?.removeLocalNotificationByIdentifier(withID: product.remoteID )
        }
        
        try! realm.write {
            if product.alertDate == nil {
                product.alertDate = defaultDate
            }
            product.alert = dateSwitch.isOn
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.ItemVC.ToEditSegue,
            let nav = segue.destination as? UINavigationController,
            let vc = nav.viewControllers.first as? NewItemViewController {
            vc.product = product
            vc.new = false
        }
    }

}
