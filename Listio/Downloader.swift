//
//  Downloader.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-03-26.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import Alamofire
import QRCodeReader

class Downloader {
    var core:InteligenceCore!
    var coreDataHandler:CoreDataHandler!
    
    init(core: InteligenceCore, withDataHandler coreDataHandler:CoreDataHandler!) {
        self.core = core
        self.coreDataHandler = coreDataHandler
    }
    
    struct Keys {
        static let BaseURL = "https://nfc-e-server.herokuapp.com"
        static let EndPointAllProducts = "/api/v1/qrdata"
    }
    
    func downloadData(result: QRCodeReaderResult, _ completion:@escaping (_ error: Error?) ->Void) {
        
        let headers = [
            "x-access-token": "SupperDupperSecret".JWTEncoded()
        ]
        let parameters = [
            "linkurl": result.value as AnyObject
        ] as [String : AnyObject]
        
        Alamofire.request(Keys.BaseURL + Keys.EndPointAllProducts, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {
            response in
            guard response.result.isSuccess else {
                print("Error while fetching tags: \(response.result.error)")
                completion(response.error)
                return
            }
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("Invalid tag information received from service")
                completion(response.error)
                return
            }
            // add new item
            if self.coreDataHandler.savingData(responseJSON) {
                //case document are add calculate the list
                self.core.calculate()
            }
            completion(nil)
        })
        
        
    }
    
}
