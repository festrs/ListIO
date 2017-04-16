//
//  AppDelegate.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-05-30.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import CoreData
import DATAStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var dataStack = DATAStack(modelName:"Listio")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let rootViewController = self.window?.rootViewController as? FPHandlesMOC {
            rootViewController.receiveDataStack(self.dataStack)
        }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data Saving support
    func saveContext () {
        if self.dataStack.mainContext.hasChanges {
            do {
                try self.dataStack.mainContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

