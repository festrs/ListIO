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
    struct Keys {
        static let BaseURL = "https://nfc-e-server.herokuapp.com"
        static let EndPointAllProducts = "/api/v1/qrdata"
        static let ProductBaseURL = "https://pod.opendatasoft.com/api/records/1.0/search/?dataset=pod_gtin&q=gtin_cd%3D"
    }

    func getReceipt(linkUrl: String, _ completion: @escaping (Error?, [String : AnyObject]?) -> Void) {
        let keys = ListioKeys()

        let headers = [
            "x-access-token": keys.listioAPISecret.JWTEncoded(withExpirationDate: Date().addingTimeInterval(30*60))
        ]
        let parameters = [
            "linkurl": linkUrl
            ] as [String : AnyObject]

        Alamofire.request(Keys.BaseURL + Keys.EndPointAllProducts,
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

        Alamofire.request(Keys.ProductBaseURL+code).validate(statusCode: 200..<300).responseJSON { response in
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
