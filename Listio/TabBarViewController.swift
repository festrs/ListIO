//
//  TabBarViewController.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-27.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import DATAStack

class TabBarViewController: UITabBarController, FPHandlesMOC {
    
    func receiveDataStack(_ incomingDataStack: DATAStack) {
        
        for (_, value) in (self.viewControllers?.enumerated())! {
            if let child = value as? FPHandlesMOC {
                child.receiveDataStack(incomingDataStack)
            }

            if let child = value as? AddListItemViewController {
                let dataProvider = AddListItemDataProvider()
                child.dataProvider = dataProvider
            }
        }
    }

}
