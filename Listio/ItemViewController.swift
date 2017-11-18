//
//  ItemViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-09-16.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import Photos

class ItemViewController: UIViewController {

    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var lblDateDays: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblItemUnit: UILabel!
    @IBOutlet weak var lblItemPrice: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var lblItemName: UILabel!
    var item: Item! {
        didSet {
            viewModel = ItemViewModel(item: item)
        }
    }
    var viewModel: ItemViewModelProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        configImageView()

        assert(viewModel != nil, "viewModel is not allowed to be nil at this point")
        bindingViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItemImage()
        viewModel.reloadItem()
    }

    func bindingViewModel() {
        viewModel.itemDidChange = { [weak self] viewModel in
            guard let strongSelf = self else {
                return
            }
            strongSelf.lblItemName.text = viewModel.itemName
            strongSelf.lblItemUnit.text = viewModel.itemUnit
            strongSelf.lblItemPrice.text = viewModel.itemPrice
            strongSelf.lblDateDays.text = viewModel.itemDaysToExpire
            strongSelf.dateSwitch.setOn(viewModel.hasExpireAlert, animated: true)
            strongSelf.lblDate.text = viewModel.dateDescr
        }
    }

    func configImageView() {
        itemImageView.layer.cornerRadius = itemImageView.frame.size.width / 2
        itemImageView.layer.masksToBounds = true
    }

    func loadItemImage() {
        guard let imageUrl = viewModel.itemImageUrl else {
            return
        }

        var image: UIImage? = nil
        let placeHolder = UIImage(named: "noimage")
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            image = getImage(localUrl: imageUrl)
        }

        if image == nil {
            let url = URL(string: imageUrl)
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
        viewModel.changeActiveStateOfAlert(dateSwitch.isOn)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.ItemVC.ToEditSegue,
            let nav = segue.destination as? UINavigationController,
            let vc = nav.viewControllers.first as? NewItemViewController {
            vc.product = item
            vc.new = false
        }
    }

}
