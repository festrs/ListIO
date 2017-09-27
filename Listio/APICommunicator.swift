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
import Keys

struct APICommunicator: APICommunicatorProtocol {

    func getReceipt(linkUrl: String, _ completion: @escaping (Error?, [String : AnyObject]?) -> Void) {
        let keys = ListioKeys()

        let headers = [
            "x-access-token": keys.listioAPISecret.JWTEncoded(withExpirationDate: Date().addingTimeInterval(30*60))
        ]
        let parameters = [
            "linkurl": linkUrl
            ] as [String : AnyObject]

        Alamofire.request(Constants.API.BaseURL + Constants.API.EndPointAllProducts,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON(completionHandler: { response in
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

    func getProduct(code: String, _ completion: @escaping (Error?, [String : AnyObject]?) -> Void) {

        Alamofire.request(Constants.API.ProductBaseURL+code).validate(statusCode: 200..<300).responseJSON { response in
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
        }
    }
}
