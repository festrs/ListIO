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

struct APICommunicator : APICommunicatorProtocol {
    struct Keys {
        static let BaseURL = "https://nfc-e-server.herokuapp.com"
        static let EndPointAllProducts = "/api/v1/qrdata"
    }
    
    func getReceipt(linkUrl: String, _ completion: @escaping (Error?, [String : AnyObject]?) -> Void) {
        
        let headers = [
            "x-access-token": "SupperDupperSecret".JWTEncoded()
        ]
        let parameters = [
            "linkurl": linkUrl
            ] as [String : AnyObject]
        
        Alamofire.request(Keys.BaseURL + Keys.EndPointAllProducts, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {
            response in
            guard response.result.isSuccess else {
                print("Error while fetching tags: \(String(describing: response.result.error))")
                completion(response.error, nil)
                return
            }
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("Invalid tag information received from service")
                completion(response.error, nil)
                return
            }
            
            completion(response.error, responseJSON)
            
        })
    }


    
}
