//
//  DatabaseManager.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-11-04.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

class DatabaseManager: NSObject {
    static var realm: Realm {
        do {
            let realm = try Realm()
            return realm
        } catch {
            Crashlytics.sharedInstance().recordError(error)
        }
        return self.realm
    }

    public static func write(_ realm: Realm, writeClosure: () -> Void) {
        do {
            try realm.write {
                writeClosure()
            }
        } catch {
            Crashlytics.sharedInstance().recordError(error)
        }
    }
}
