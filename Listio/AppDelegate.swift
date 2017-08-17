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

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let userInfo = notification.userInfo
        let msg = "O produto \(userInfo![Constants.notificationProductNameKey]!) ira vencer em \(userInfo![Constants.notificationProductDateKey]!)"
        let alert = UIAlertController(title: "Atenção!", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let topWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.windowLevel = UIWindowLevelAlert + 1

        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertActionStyle.default,
                                      handler: { (_ action: UIAlertAction) -> Void in
            topWindow.isHidden = true
        }))
        topWindow.makeKeyAndVisible()
        topWindow.rootViewController?.present(alert, animated: true, completion: { _ in })
    }

}
