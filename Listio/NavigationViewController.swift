//
//  MyUINavigationController.swift
//  ToDoAssignment3
//
//  Created by Felipe Dias Pereira on 2016-04-08.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import DATAStack

class NavigationViewController: UINavigationController, FPHandlesMOC {
    
    var dataStack:DATAStack!
    
    func receiveDataStack(incomingDataStack: DATAStack) {
        if let child = self.viewControllers.first as? FPHandlesMOC{
            child.receiveDataStack(incomingDataStack)
        }
    }
 
}
