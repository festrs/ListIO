//
//  QRCodeViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-27.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import DATAStack
import MBProgressHUD

class QRCodeViewController: UIViewController {
    
    public var communicator: APICommunicatorProtocol = APICommunicator()
    var dataStack: DATAStack!
    var presented: Bool = false
    var HUD: MBProgressHUD!
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        readerVC.delegate = self
        readerVC.modalPresentationStyle = .formSheet
        
        HUD = MBProgressHUD(view: view)
        HUD.mode = .annularDeterminate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !presented {
            self.parent?.present(self.readerVC, animated: true, completion: {
                self.presented = true
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    fileprivate func saveContex() throws {
        do {
            try self.dataStack.mainContext.save()
        } catch {
            throw Errors.CoreDataError("Failure to save context: \(error)")
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createNewList() {
        let refreshAlert = UIAlertController(title: "Adicionado com sucesso", message: "Você deseja criar uma nova lista?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "toCreateList", sender: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            self.dismissWithTabBar()
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func dismissWithTabBar() {
        tabBarController?.selectedIndex = 0
        dismiss(animated: true, completion: {
            self.presented = false
        })
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FPHandlesMOC {
            vc.receiveDataStack(self.dataStack)
        }
        if let vc = segue.destination as? AddListItemViewController {
            vc.dataProvider = AddListItemDataProvider()
        }
    }

}

extension QRCodeViewController : FPHandlesMOC {
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        dataStack = incomingDataStack
    }
}

extension QRCodeViewController : QRCodeReaderViewControllerDelegate {
    // MARK: - QRCodeReaderViewController Delegate Methods
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()

        guard result.metadataType == AVMetadataObjectTypeQRCode else { return }
        HUD.show(animated: true)
        communicator.getReceipt(linkUrl: result.value) { (error, responseJSON) in
            self.HUD.hide(animated: true)
            guard error == nil else {
                self.showAlert("error", message: (error?.localizedDescription)!)
                return
            }
            do {
                try Receipt.createReceipt(self.dataStack.mainContext, json: responseJSON!)
                
                self.createNewList()
                
            } catch Errors.DoubleReceiptWithSameID() {
                print("mesmo")
            } catch {
                
            }
        }
        
        dismiss(animated: true, completion: {
            self.presented = false
        })
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        self.dismissWithTabBar()
    }
}
