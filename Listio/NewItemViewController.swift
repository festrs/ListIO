//
//  NewItemViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-06-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import ALCameraViewController

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
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            // Do something with your image here.

            // If cropping is enabled this image will be the cropped version
            
            self?.productImageView.image = image
            self?.dismiss(animated: true, completion: nil)
        }
        navigationController?.present(cameraViewController, animated: true, completion: nil)
        /// Provides an image picker wrapped inside a UINavigationController instance
//        let imagePickerViewController = CameraViewController.imagePickerViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
//
//            self?.productImageView.image = image
//            self?.dismiss(animated: true, completion: nil)
//        }

        //present(imagePickerViewController, animated: true, completion: nil)
    }

    @IBAction func doneAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
